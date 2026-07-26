# Tổng Quan Khóa Học System Design For Beginners (NeetCode)

**Video gốc:** https://www.youtube.com/watch?v=SE2KF-vxvS0&t=1011s  
**Giảng viên:** NeetCode (Navi - cựu kỹ sư Google)  
**Số bài:** 21 bài | **Thời lượng:** ~5h21p | **Cấp độ:** Từ mới bắt đầu  
**Xây dựng dự án thực tế:** Ứng dụng chia sẻ ảnh (giống Instagram/Imgur)

---

## 1. Mục Tiêu Khóa Học

- Hiểu cách lựa chọn thành phần phù hợp và đặt chúng vào vị trí đúng để giải quyết bài toán phần mềm
- Nắm vững kiến thức nền tảng về hệ thống phân tán (distributed systems)
- Thiết kế hệ thống có khả năng mở rộng (scalable) và hiệu quả
- Áp dụng thực tế qua bài tập xây dựng app chia sẻ ảnh cho hàng triệu người dùng

---

## 2. Tổng Quan Các Chủ Đề

| # | Chủ Đề | Nội Dung Chính |
|---|--------|----------------|
| 1 | **Kiến Trúc Máy Tính** | Disk (persistent, chậm) → RAM (nhanh, không persistent) → CPU (thực thi lệnh) → Cache (nhanh nhất, dung lượng nhỏ) |
| 2 | **Kiến Trúc Ứng Dụng** | Server → Storage → User Request → Response (HTML/CSS/JS). Vertical vs Horizontal Scaling |
| 3 | **Yêu Cầu Thiết Kế** | Functional Requirements, Non-functional Requirements, Capacity Estimation |
| 4 | **Proxy & Load Balancing** | Forward Proxy, Reverse Proxy, Load Balancer (Round Robin, Least Connections, IP Hash) |
| 5 | **Consistent Hashing** | Xử lý phân phối đều dữ liệu trên các node, tránh hotspot |
| 6 | **SQL** | Relational Database, ACID, Normalization, Indexing, Joins |
| 7 | **NoSQL** | Document Store, Key-Value, Column-Family, Graph DB. BASE model |
| 8 | **Replication & Sharding** | Primary-Replica replication, Horizontal sharding, Hotspot problem |
| 9 | **CAP Theorem** | Consistency + Availability + Partition Tolerance — chỉ chọn được 2/3 |
| 10 | **Object Storage** | Amazon S3, CDN integration, lưu trữ ảnh/video phi cấu trúc |
| 11 | **Message Queues** | Producer-Consumer pattern, Kafka, RabbitMQ, async processing |
| 12 | **MapReduce** | Xử lý dữ liệu lớn song song, batch processing |
| 13-21 | **Các chủ đề nâng cao** | CDNs, Caching strategies, Rate Limiting, Timeouts & Retries, Monitoring |

---

## 3. Hướng Dẫn Sử Dụng Chi Tiết

### 3.1 Mô hình bài học (photo-sharing app)

Mỗi bài học bắt đầu bằng một sự cố:
- Server bị chết → giới thiệu Load Balancer
- Query chạy 4 giây → giới thiệu Indexing
- Server logout hết user → giới thiệu Session Management

Sau đó giới thiệu thành phần giải quyết sự cố → rồi tạo ra vấn đề mới.

### 3.2 Các thành phần hệ thống cần thiết

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT (Web/Mobile)                  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                  API GATEWAY                            │
│         (Route, Auth, Rate Limiting)                    │
└──────┬──────────────┬──────────────┬────────────────────┘
       │              │              │
┌──────▼──────┐ ┌─────▼─────┐ ┌───│──▼─────┐
│ User Service│ │Pic Service│ │Notification│
│ (Auth/Prof) │ │(Upload/CR)│ │  Service   │
└──────┬──────┘ └─────┬─────┘ └──────┬─────┘
       │              │              │
┌──────▼──────────────▼──────────────▼────────────────────┐
│                    DATABASES                            │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐│
│  │SQL(Postgres)│  │NoSQL(MongoDB)│  │Object Storage(S3)││
│  │User/Meta    │  │Feed/Activity │  │   Images/Video   ││
│  └─────────────┘  └──────────────┘  └──────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### 3.3 Workflow tải ảnh lên

```
User Upload → API Gateway → Picture Service
    → Image Processing Service (resize/compress)
    → Object Storage (S3)
    → Metadata saved to Database
    → CDN Cache invalidated
    → Notify followers via Message Queue
```

### 3.4 Workflow hiển thị feed

```
User Request Feed → API Gateway → Feed Service
    → Cache Check (Redis/Memcached)
    → Cache HIT? → Return cached feed
    → Cache MISS? → Query Database (sharded)
    → Populate Cache → Return to user
```

---

## 4. Các Khó Khăn & Lưu Ý Quan Trọng

### 4.1 Khó khăn thường gặp

| Khó Khăn | Mô Tả | Giải Pháp |
|----------|--------|-----------|
| **Hotspot trên database** | Một số partition nhận quá nhiều truy vấn | Consistent Hashing, Vertical Sharding |
| **Cascading Failure** | Server này chết → server khác quá tải → chết dây chuyền | Circuit Breaker, Timeouts, Retries with backoff |
| **Cache Invalidation** | Dữ liệu thay đổi nhưng cache chưa cập nhật | Write-through, Write-back, TTL |
| **Thundering Herd** | Nhiều request cùng lúc sau khi cache hết hạn | Request coalescing, Lock-based caching |
| **Data Inconsistency** | Dữ liệu giữa primary và replica không đồng bộ | Eventual Consistency, Quorum reads/writes |

### 4.2 Không nên làm

- **KHÔNG** đặt toàn bộ dữ liệu trong một database đơn lẻ — sẽ bottleneck khi scale
- **KHÔNG** dùng synchronous call cho mọi service — sẽ tạo cascading timeout
- **KHÔNG** bỏ qua rate limiting — hệ thống sẽ bị abuse và crash
- **KHÔNG** cache mọi thứ — cache invalidation là một trong 2 vấn đề khó nhất trong CS
- **KHÔNG** dùng JOIN phức tạp trên table lớn — sẽ chậm nghiêm trọng
- **KHÔNG** thiết kế hệ thống mà không tính failure scenario

### 4.3 Lưu ý khi triển khai

1. **Luôn có monitoring & alerting** — biết khi nào hệ thống sắp hỏng trước khi hỏng
2. **Test failure scenarios** — kill container, simulate network partition
3. **Capacity planning** — ước tính traffic trước khi thiết kế
4. **Backup & Recovery** — luôn có plan B cho dữ liệu quan trọng
5. **Security by default** — Authentication, Authorization, Encryption ở mọi lớp
6. **Start simple, scale later** — đừng over-engineering từ đầu

---

## 5. Flow Sơ Đồ Tổng Quát

### 5.1 Quy Trình Thiết Kế Hệ Thống

```
┌──────────────────┐
│ 1. Xác định      │
│ Requirements     │
│ (Functional +    │
│  Non-functional) │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ 2. Capacity      │
│ Estimation       │
│ (QPS, Storage,   │
│  Bandwidth)      │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ 3. High-Level    │
│ Design           │
│ (Vẽ sơ đồ tổng   │
│  quát các thành  │
│  phần chính)     │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ 4. Deep Dive     │
│ (Chọn 1-2 thành  │
│  phần để design  │
│  chi tiết)       │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ 5. Trade-offs &  │
│ Bottlenecks      │
│ (Nhận diện điểm  │
│  yếu & giải pháp)│
└──────────────────┘
```

### 5.2 Cơ Chế Scaling

```
                    TRAFFIC TĂNG
                         │
          ┌──────────────┴──────────────┐
          │                             │
┌─────────▼─────────┐       ┌───────────▼─────────┐
│ VERTICAL SCALING  │       │ HORIZONTAL SCALING  │
│ (Nâng cấp server  │       │ (Thêm nhiều server  │
│  mạnh hơn)        │       │  chạy song song)    │
│                   │       │                     │
│ - Đơn giản        │       │ - Phức tạp hơn      │
│ - Có giới hạn     │       │ - Không giới hạn    │
│ - Đắt             │       │ - Cần Load Balancer │
│ - Single Point    │       │ - Cần Sync data     │
│   of Failure      │       │                     │
└───────────────────┘       └─────────────────────┘
```

### 5.3 Cơ Chế Database Scaling

```
DATABASE SCALING
       │
       ├──→ READ REPLICAS (Replication)
       │      └── Tăng read capacity
       │      └── Dùng cho: feed, search, analytics
       │
       ├──→ SHARDING (Partitioning)
       │      └── Tăng write capacity
       │      └── Chia data theo user_id hoặc geo
       │      └── Vấn đề: cross-shard queries
       │
       └──→ CACHING LAYER
              └── Cache hot data trong Redis/Memcached
              └── Giảm load cho database chính
```

---

## 6. Giải Pháp Theo Từng Component

| Component | Giải Pháp Khuyên Dùng | Lý Do |
|-----------|----------------------|-------|
| **Load Balancer** | Nginx, HAProxy, AWS ELB | Phân phối traffic đều, health check |
| **Cache** | Redis, Memcached | Giảm latency, giảm load DB |
| **Database** | PostgreSQL (SQL), MongoDB (NoSQL) | SQL cho relational data, NoSQL cho flexible schema |
| **Object Storage** | AWS S3, Google Cloud Storage | Lưu trữ ảnh/video phi cấu trúc |
| **Message Queue** | Kafka, RabbitMQ, SQS | Xử lý async, decouple services |
| **CDN** | Cloudflare, AWS CloudFront | Cache content tĩnh ở edge locations |
| **Search** | Elasticsearch | Full-text search, analytics |
| **Session Store** | Redis | Session dataistributed, fast read/write |

---

## 7. So Sánh Với Đối Thủ

| Tiêu Chí | NeetCode System Design | Grokking System Design (Educative) | ByteByteGo | System Design Interview (Alex Xu) |
|-----------|----------------------|-------------------------------------|------------|-----------------------------------|
| **Giá** | Free (YouTube) + Pro ($25/tháng) | $79 (one-time) | $39/tháng | Sách $25-40 |
| **Số bài** | 21 bài | 30+Chương | 20+ chủ đề | 15 chủ đề |
| **Độ sâu** | Cơ bản → Trung bình | Sâu, chi tiết | Trung bình | Sâu |
| **Thực hành** | Có lab thực hành (kill container, indexing) | Có bài tập | Không có | Không có |
| **Phù hợp** | Mới bắt đầu | Chuẩn bị phỏng vấn senior | Nhanh, tổng quan | Đọc khi rảnh |
| **Điểm mạnh** | Free, practical labs, dễ hiểu | Chi tiết nhất, có mock interview | Visual tốt, dễ theo | Sách hay, ngắn gọn |
| **Điểm yếu** | Chưa cover microservices, K8s | Đắt, text-heavy | Không có hands-on | Ít bài tập |

---

## 8. Tối Ưu Theo Các Mô Hình

### 8.1 Mô Hình CAP Theorem

```
        CONSISTENCY
           /\
          /  \
         / CP \
        /  (ZK)\
       /________\
      /    CA    \
     /  (Postgres)\
    /______________\
   AP               AP
  (Cassandra)    (DynamoDB)

CP: Consistent + Partition Tolerant → MongoDB, ZooKeeper
CA: Consistent + Available → PostgreSQL (single node)
AP: Available + Partition Tolerant → Cassandra, DynamoDB
```

### 8.2 Mô Hình Caching Strategy

```
WRITE-THROUGH:
  Write → Cache → DB (đồng bộ, đảm bảo consistency)
  Ưu: Dữ liệu luôn mới
  Nhược: Write chậm hơn

WRITE-BACK:
  Write → Cache → DB (async, ghi cache trước, DB sau)
  Ưu: Write nhanh
  Nhược: Có thể mất data nếu cache crash

WRITE-AROUND:
  Write → DB trực tiếp (bỏ qua cache)
  Ưu: Tránh cache pollution
  Nhược: Cache miss lần đầu tiên
```

### 8.3 Mô Hình Rate Limiting

```
ALGORITHM         | ĐẶC ĐIỂM
──────────────────┼──────────────────────────
Token Bucket      | linh hoạt, phổ biến nhất
Sliding Window    | chính xác hơn, dùng nhiều memory
Fixed Window      | đơn giản, có burst ở biên
Leaky Bucket      | ổn định, đều đặn

KHÔNG BAO GIỜ bỏ qua rate limiting cho production system.
```

### 8.4 Mô Hình Microservices cho Photo App

```
┌─────────────────────────────────────────────────┐
│                 API GATEWAY                     │
│         (Kong / AWS API Gateway)                │
└───┬──────┬──────┬──────┬──────┬─────────────────┘
    │      │      │      │      │
┌───▼──┐┌──▼───┐┌─▼────┐┌▼────┐┌▼──────────┐
│Auth  ││Image ││Feed  ││Notif││Analytics  │
│Svc   ││Svc   ││Svc   ││Svc  ││Svc        │
│      ││      ││      ││     ││           │
│JWT   ││S3+CDN││Redis ││Kafka││Elastic-   │
│Token ││+Proc ││Cache ││Queue││search     │
└───┬──┘└──┬───┘└──┬───┘└──┬──┘└──┬────────┘
    │      │      │      │      │
┌───▼──────▼──────▼──────▼──────▼──────────────┐
│           SERVICE DISCOVERY                  │
│        (Consul / Eureka / K8s DNS)           │
└──────────────────────────────────────────────┘
```

---

## 9. Checklist Triển Khai Production

- [ ] Load Balancer configured (health check, failover)
- [ ] Database replication (primary + replicas)
- [ ] Caching layer (Redis/Memcached) với eviction policy
- [ ] CDN cho static assets
- [ ] Message queue cho async processing
- [ ] Rate limiting tại API Gateway
- [ ] Monitoring (Prometheus + Grafana / Datadog)
- [ ] Logging centralized (ELK Stack / CloudWatch)
- [ ] Alerting (PagerDuty / Slack notifications)
- [ ] Backup & Disaster Recovery plan
- [ ] Security: HTTPS, JWT auth, input validation
- [ ] Capacity planning & auto-scaling rules

---

## 10. Tổng Kết

Khóa học này cung cấp **nền tảng vững chắc** cho việc thiết kế hệ thống, đặc biệt phù hợp cho:
- Developers muốn hiểu cách thức hoạt động của các hệ thống lớn
- Chuẩn bị cho **System Design Interview** ở các công ty tech
- Xây dựng tư duy về **trade-offs** và **scalability**

**Hạn chế:** Không cover microservices architecture, Docker/Kubernetes, CI/CD — cần học thêm từ các nguồn nâng cao hơn.

---

*Tài liệu tổng hợp từ khóa học System Design For Beginners - NeetCode (2026)*
