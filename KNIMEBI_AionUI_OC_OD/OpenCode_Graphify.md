# OpenCode + Graphify: Hướng dẫn Setup Tổng quát & Chi tiết

> Nguồn tham khảo: [YouTube - OpenCode + Graphify: Step-by-Step Setup Guide](https://www.youtube.com/watch?v=ViAjzGvbdhQ)
> Ngày cập nhật: 26/07/2026

---

## 1. Tổng quan

**Graphify** là một công cụ mã nguồn mở (MIT License) chuyển đổi bất kỳ thư mục nào (code, docs, PDF, hình ảnh, video) thành **Knowledge Graph có thể truy vấn**, giúp AI coding assistant hiểu cấu trúc dự án thay vì đọc toàn bộ source code.

**OpenCode** là một AI coding assistant hỗ trợ Graphify thông qua `AGENTS.md` + `tool.execute.before` plugin.

**Kết quả chính:**
- Giảm token usage tới **71.5x** so với cách đọc file truyền thống
- Query thay vì grep — AI tra cứu đồ thị thay vì lục tung source code
- 100% local cho code (Tree-sitter AST), không gửi code ra ngoài

---

## 2. Các bước Setup Chi tiết

### Yêu cầu hệ thống

| Thành phần | Phiên bản tối thiểu | Kiểm tra |
|---|---|---|
| Python | 3.10+ | `python --version` |
| uv (khuyến nghị) | bất kỳ | `uv --version` |
| OpenCode | phiên bản mới nhất | `opencode --version` |
| Quyền truy cập repo | đọc/ghi | Kiểm tra thư mục project |

### Bước 1: Cài đặt Package

```bash
# Khuyến nghị: uv tự động đưa graphify vào PATH
uv tool install graphifyy

# Hoặc alternatives
pipx install graphifyy
pip install graphifyy    # có thể cần cấu hình PATH thủ công
```

**Lưu ý quan trọng:** Tên package trên PyPI là `graphifyy` (double-y), nhưng lệnh CLI là `graphify`. Các package khác có tên `graphify*` đều **KHÔNG** liên quan đến dự án này.

### Bước 2: Đăng ký với OpenCode

```bash
graphify install --platform opencode
```

Hoặc nếu đang trên Windows:
```bash
graphify install --platform opencode
# hoặc
graphify install --platform windows
```

Thao tác này sẽ:
- Tạo file `AGENTS.md` trong project root
- Cài đặt `tool.execute.before` plugin tại `.opencode/plugins/graphify.js`
- Đăng ký plugin trong `opencode.json`

### Bước 3: Khởi tạo Knowledge Graph

Mở OpenCode trong thư mục project, rồi chạy:

```bash
/graphify .
# hoặc chỉ định đường dẫn cụ thể
/graphify ./path/to/your/codebase
```

**Lưu ý cho PowerShell:** Dấu `/` ở đầu có thể bị hiểu sai là path separator. Nếu gặp lỗi, bỏ dấu `/`:
```bash
graphify .
graphify ./path/to/your/codebase
```

### Bước 4: Kích hoạt Always-On Mode

```bash
graphify opencode install
```

Sau lệnh này, mỗi khi bạn đặt câu hỏi về codebase trong OpenCode, assistant sẽ tự động ưu tiên query knowledge graph thay vì đọc file thô.

### Bước 5: Kiểm tra kết quả

Sau khi hoàn tất, thư mục `graphify-out/` sẽ chứa:
```
graphify-out/
├── graph.html          # Trực quan hóa đồ thị tương tác
├── graph.json          # Dữ liệu đồ thị thô (dùng cho query)
├── GRAPH_REPORT.md     # Báo cáo kiến trúc: god nodes, communities, surprising connections
└── .graphify_cache/    # Cache trích xuất (tăng tốc incremental)
```

### Bước 6: Các lệnh Query

```bash
# Query BFS — ngữ cảnh rộng
/graphify query "luồng xác thực hoạt động như thế nào?"

# Query DFS — truy vết đường đi cụ thể
/graphify query "kết nối giữa auth và payment" --dfs

# Giới hạn token cho câu trả lời
/graphify query "cấu trúc module" --budget 1500

# Tìm đường đi ngắn nhất giữa hai khái niệm
/graphify path "AuthModule" "Database"

# Giải thích một node
/graphify explain "SwinTransformer"
```

---

## 3. Cơ chế Hoạt động — 3 Pass Xử lý

```
┌─────────────────────────────────────────────────────────┐
│                    GRAPHIFY PIPELINE                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Pass 1: Structural (MIỄN PHÍ, LOCAL)                   │
│  ┌──────────────────────────────────────────┐           │
│  │ Tree-sitter AST → classes, functions,    │           │
│  │ imports, call graphs, docstrings         │           │
│  │ ~40 ngôn ngữ hỗ trợ                      │           │
│  └──────────────┬───────────────────────────┘           │
│                 ▼                                       │
│  Pass 2: Media (MIỄN PHÍ, LOCAL)                        │
│  ┌──────────────────────────────────────────┐           │
│  │Faster Whisper → transcription video/audio│           │
│  │ Xử lý cục bộ, không gửi ra ngoài         │           │
│  └──────────────┬───────────────────────────┘           │
│                 ▼                                       │
│  Pass 3: Semantic (Tốn API tokens)                      │
│  ┌───────────────────────────────────────────┐          │
│  │ Subagents trích xuất concepts từ:         │          │
│  │ docs, PDFs, hình ảnh, whiteboard          │          │
│  │ Gắn nhãn: EXTRACTED / INFERRED / AMBIGUOUS│          │
│  └──────────────┬────────────────────────────┘          │
│                 ▼                                       │
│  ┌───────────────────────────────────────────┐          │
│  │         NETWORKX GRAPH BUILD              │          │
│  │  Merge tất cả nodes/edges → graph.json    │          │
│  └──────────────┬────────────────────────────┘          │
│                 ▼                                       │
│  ┌──────────────────────────────────────────┐           │
│  │     LEIDEN COMMUNITY DETECTION           │           │
│  │  Cluster nodes theo edge density         │           │
│  │  Không cần embeddings / vector store     │           │
│  └──────────────┬───────────────────────────┘           │
│                 ▼                                       │
│  ┌───────────────────────────────────────────┐          │
│  │  EXPORT: HTML / JSON / GRAPH_REPORT.md    │          │
│  │  + Neo4j / Obsidian / Wiki / SVG          │          │
│  └───────────────────────────────────────────┘          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Chi tiết từng Pass:

| Pass | Nội dung | Chi phí | Phương pháp |
|---|---|---|---|
| Pass 1 | Code (.py, .ts, .js, .go, .rs, .java...) | **Miễn phí** | Tree-sitter AST (deterministic, không LLM) |
| Pass 2 | Video/Audio (.mp4, .mp3, .wav...) | **Miễn phí** | Faster Whisper (local transcription) |
| Pass 3 | Docs, PDFs, Images, Whiteboard | **Tốn token** | LLM subagents trích xuất semantic |

### Gắn nhãn mối quan hệ (Edge Labels):

| Nhãn | Ý nghĩa |
|---|---|
| `EXTRACTED` | Tìm thấy trực tiếp trong source (function call, import) |
| `INFERRED` | Suy luận bởi AI, có `confidence_score` |
| `AMBIGUOUS` | Không chắc chắn, cần review thủ công |

---

## 4. Quy trình Cơ chế Tích hợp OpenCode

```
┌──────────────────────────────────────────────────────┐
│           OPENCODE + GRAPHIFY WORKFLOW               │
├──────────────────────────────────────────────────────┤
│                                                      │
│  1. User đặt câu hỏi trong OpenCode                  │
│     "Luồng auth hoạt động thế nào?"                  │
│              ▼                                       │
│  2. tool.execute.before plugin KÍCH HOẠT             │
│     Kiểm tra graphify-out/graph.json có tồn tại?     │
│              ├── KHÔNG → fallback grep/glob          │
│              └── CÓ → Chuyển sang bước 3             │
│              ▼                                       │
│  3. Plugin inject graph reminder vào tool output     │
│     "Đọc GRAPH_REPORT.md trước khi search file thô"  │
│              ▼                                       │
│  4. OpenCode query graphify query "luồng auth"       │
│     → Trả về subgraph liên quan (ít node, chính xác) │
│              ▼                                       │
│  5. Nếu graph đủ thông tin → Trả lời                 │
│     Nếu không đủ → Fallback grep/glob (bình thường)  │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### So sánh: Không có Graphify vs Có Graphify

| Tiêu chí | Không Graphify | Có Graphify |
|---|---|---|
| Phương pháp | Grep toàn bộ source files | Query knowledge graph |
| Token sử dụng | Rất nhiều (đọc cả file) | Giảm tới 71.5x |
| Độ chính xác | Fuzzy matching | Deterministic (Tree-sitter) |
| Hiểu kiến trúc | Không | God nodes, communities |
| Chi phí API | Cao | Pass 1+2 miễn phí, Pass 3 tối thiểu |
| Thời gian | Chậm (đọc nhiều file) | Nhanh (query graph nhỏ) |

---

## 5. Lưu ý quan trọng — Khó khăn & Hạn chế

### 5.1. Những khó khăn thường gặp

| Vấn đề | Nguyên nhân | Giải pháp |
|---|---|---|
| `graphify: command not found` | PATH không đúng hoặc dùng pip thông thường | Dùng `uv tool install` hoặc `pipx install` |
| OpenCode tìm Claude subagent thay vì dùng LLM hiện tại | Graphify mặc định tìm Claude cho Pass 3 | Thêm note: *"Use current OpenCode session sub-agents instead of Claude"* |
| Plugin không hoạt động | Chưa chạy `graphify opencode install` | Chạy lại lệnh install và restart OpenCode |
| Graph cũ khi code thay đổi | Chưa setup auto-rebuild | Dùng `graphify hook install` hoặc `--watch` |
| PowerShell lỗi dấu `/` | Dấu `/` bị hiểu là path separator | Bỏ dấu `/`, dùng `graphify .` thay vì `/graphify .` |
| Graph quá lớn, chậm | Repo rất lớn | Dùng `--update` (incremental) thay vì rebuild toàn bộ |
| Pass 3 tốn token cao | Có nhiều docs/PDF/hình ảnh | Dùng `--no-viz` bỏ qua visualization, hoặc limit files với `.graphifyignore` |

### 5.2. NHỮNG ĐIỀU KHÔNG NÊN CHO PHÉP

| Không nên | Lý do |
|---|---|
| **Không commit API keys/secrets vào graph** | Graph lưu cấu trúc, không lưu secret — nhưng cần đảm bảo `.graphifyignore` loại trừ file config chứa secrets |
| **Không dùng `pip install graphify`** | Đó là package khác, KHÔNG liên quan. Chỉ dùng `graphifyy` |
| **Không chạy Pass 3 trên code nhạy cảm** | Pass 3 gửi nội dung docs/hình ảnh lên LLM API — cần kiểm tra dữ liệu nhạy cảm |
| **Không dùng Graphify cho codebase < 50 files nhỏ** | Hiệu quả token không đáng kể, graph value là structural clarity |
| **Không force rebuild toàn bộ mỗi lần** | Dùng `--update` hoặc `--watch` thay vì `/graphify .` lại từ đầu |
| **Không игнорировать `.graphifyignore`** | Luôn cấu hình để loại trừ generated code, node_modules, build output |
| **Không chạy song song nhiều instances graphify** | Có thể gây conflict cache và corrupt graph.json |
| **Không dùng cho production deployment** | Graphify là development tool, không phải runtime dependency |

### 5.3. Những lưu ý khi Triển khai Teams

1. **Commit `graphify-out/` vào git** — Everyone cùng dùng graph chung
2. **Setup git hooks** với `graphify hook install` — Tự động rebuild sau mỗi commit
3. **Git merge driver** được cấu hình sẵn — `graph.json` tự union-merge khi conflict
4. **Mỗi developer chạy `graphify opencode install`** — Everyone có config giống nhau
5. **Dùng `.graphifyignore`** thay vì `.gitignore` riêng — Priority override khi cả hai tồn tại

---

## 6. Tự động hóa & Cập nhật

### Git Hooks (Khuyến nghị cho Teams)

```bash
graphify hook install
```

Tạo 2 hooks:
- **post-commit**: Rebuild graph sau mỗi commit (chỉ AST, không tốn token)
- **post-checkout**: Rebuild khi switch branch

### Watch Mode (Real-time)

```bash
graphify . --watch
```

- Code files: Rebuild ngay lập tức (AST only, không LLM)
- Docs/Images: Ghi flag `needs_update`, thông báo chạy `--update`

### Incremental Update

```bash
graphify . --update
```

Chỉ trích xuất lại files đã thay đổi.

### Các Export tùy chọn

```bash
pip install "graphifyy[pdf]"       # Hỗ trợ PDF
pip install "graphifyy[office]"    # Hỗ trợ .docx, .xlsx
pip install "graphifyy[video]"     # Video/audio transcription
pip install "graphifyy[sql]"       # SQL schema extraction
pip install "graphifyy[ollama]"    # Local inference qua Ollama
pip install "graphifyy[neo4j]"     # Push graph lên Neo4j
pip install "graphifyy[mcp]"       # MCP server integration
pip install "graphifyy[all]"       # Tất cả
```

---

## 7. So sánh với Đối thủ

| Tiêu chí | Graphify | RAG/Vector DB | CodeGraph | Sourcetrail |
|---|---|---|---|---|
| **Phương pháp** | Knowledge Graph (Tree-sitter AST) | Vector Embeddings | SQLite AST | Static Analysis |
| **Deterministic** | ✅ Có (AST) | ❌ Không (fuzzy matching) | ✅ Có | ✅ Có |
| **Multi-modal** | ✅ Code + Docs + PDF + Video + Image | ⚠️ Text mainly | ❌ Code only | ❌ Code only |
| **Token reduction** | tới 71.5x | Không có ý nghĩa | Không có ý nghĩa | N/A |
| **Community detection** | ✅ Leiden algorithm | ❌ Không | ❌ Không | ❌ Không |
| **God nodes** | ✅ Có | ❌ Không | ❌ Không | Partial |
| **Local-first** | ✅ Pass 1+2 local | ❌ Cần cloud embedding | ✅ Local | ✅ Local |
| **Edge labels** | ✅ EXTRACTED/INFERRED | ❌ Không | ❌ Không | ❌ Không |
| **AI integration** | ✅ 20+ platforms | ⚠️ Tùy framework | ⚠️ Limited | ❌ Standalone |
| **Query language** | Natural language → Graph | Semantic similarity | SQL | UI-based |
| **MCP support** | ✅ Có | ⚠️ Tùy framework | ❌ Không | ❌ Không |
| **Incremental update** | ✅ Có | ⚠️ Cần re-embed | ❌ Không | ❌ Không |
| **Giá** | OSS (MIT) | Tùy provider | OSS | OSS (discontinued) |

### Strengths so với đối thủ:
- **Deterministic vs Fuzzy**: Tree-sitter parse chính xác, không "đoán" dependencies
- **Multi-modal unified graph**: Cùng một graph cho code + docs + video
- **Edge provenance**: Biết rõ thông tin nào được extract vs infer
- **Zero-config**: Không cần setup vector DB, embedding pipeline
- **71.5x token reduction**: Số liệu benchmark cụ thể (Karpathy 52 files corpus)

### Weaknesses:
- Pass 3 vẫn tốn API tokens
- Đang trong giai đoạn phát triển tích cực (breaking changes có thể xảy ra)
- Không thay thế hoàn toàn grep cho mọi use case
- Cần Python 3.10+ environment

---

## 8. Tối ưu theo Mô hình cụ thể

### 8.1. OpenCode + Graphify (Mô hình hiện tại)

```bash
# Setup
uv tool install graphifyy
graphify install --platform opencode
graphify opencode install    # Always-on mode

# Khuyến nghị cho OpenCode
graphify . --watch           # Real-time updates
graphify hook install        # Git hooks auto-rebuild
```

**Lưu ý riêng cho OpenCode:**
- Viết `AGENTS.md` + `tool.execute.before` plugin (không phải PreToolUse hook)
- Luôn thêm note khi run `/graphify .`: *"Instead of Claude, use current OpenCode session sub-agents"*
- Plugin inject graph reminder trước mỗi bash tool call

### 8.2. Claude Code + Graphify

```bash
graphify install    # Auto-detect platform
graphify claude install  # Always-on mode
```

**Khác biệt với OpenCode:**
- Sử dụng `CLAUDE.md` + `PreToolUse` hook trong `settings.json`
- Hook fires trước mỗi `Glob` và `Grep` call
- Hỗ trợ `--strict` mode: block raw source read đầu tiên mỗi session
- Hỗ trợ `additionalContext` field trong hook

### 8.3. Codex + Graphify

```bash
graphify install --platform codex
graphify codex install
```

**Lưu ý:**
- Cần `multi_agent = true` trong `~/.codex/config.toml` cho parallel extraction
- Hỗ trợ PreToolUse hooks trong `.codex/hooks.json`
- Dùng `$graphify` (không phải `/graphify`) trong Codex

### 8.4. Cursor + Graphify

```bash
graphify cursor install
```

**Lưu ý:**
- Viết vào `.cursor/rules/graphify.mdc` với `alwaysApply: true`
- Cursor tự động load rules trong mọi conversation
- Không có PreToolUse hook — dùng rules file

### 8.5. Tối ưu cho lượng file lớn Codebase (>10,000 files)

```bash
# Bước 1: Tạo .graphifyignore loại trừ generated files
echo "node_modules/" >> .graphifyignore
echo "dist/" >> .graphifyignore
echo "build/" >> .graphifyignore
echo "*.min.js" >> .graphifyignore
echo ".git/" >> .graphifyignore

# Bước 2: Chạy incremental thay vì full rebuild
graphify . --update

# Bước 3: Dùng watch mode cho development
graphify . --watch

# Bước 4: Setup git hooks
graphify hook install
```

### 8.6. Tối ưu cho Privacy/Nhạy cảm

```bash
# Dùng Ollama local cho Pass 3 (không gửi data lên cloud)
pip install "graphifyy[ollama]"

# Hoặc limit semantic extraction chỉ cho docs cần thiết
# Sử dụng .graphifyignore để loại trừ files nhạy cảm
```

---

## 9. Sơ đồ Lưu đồ Tổng hợp

```
┌──────────────────────────────────────────────────────────────┐
│                    TRIỂN KHAI OPENCODE + GRAPHIFY            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  [1] CÀI ĐẶT                                                 │
│  ├── uv tool install graphifyy                               │
│  ├── graphify install --platform opencode                    │
│  └── graphify opencode install                               │
│              ▼                                               │
│  [2] KHỞI TẠO GRAPH                                          │
│  ├── /graphify .  (hoặc graphify . trong PowerShell)         │
│  ├── Pass 1: Tree-sitter AST (miễn phí)                      │
│  ├── Pass 2: Whisper transcription (miễn phí)                │
│  └── Pass 3: LLM semantic extraction (tốn token)             │
│              ▼                                               │
│  [3] XUẤT ĐỒ THỊ                                             │
│  ├── graph.html (trực quan hóa)                              │
│  ├── graph.json (query data)                                 │
│  └── GRAPH_REPORT.md (báo cáo kiến trúc)                     │
│              ▼                                               │
│  [4] TỰ ĐỘNG HÓA                                             │
│  ├── graphify hook install (git hooks)                       │
│  ├── graphify . --watch (real-time)                          │
│  └── graphify . --update (incremental)                       │
│              ▼                                               │
│  [5] SỬ DỤNG HÀNG NGÀY                                       │
│  ├── OpenCode tự động query graph trước khi grep             │
│  ├── graphify query "câu hỏi"                                │
│  ├── graphify path "A" "B"                                   │
│  └── graphify explain "concept"                              │
│              ▼                                               │
│  [6] ĐỘI NHÓM                                                │
│  ├── Commit graphify-out/ vào git                            │
│  ├── Mỗi member chạy graphify opencode install               │
│  └── Git merge driver tự union-merge graph.json              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 10. Checklist Triển khai

- [ ] Cài đặt Python 3.10+
- [ ] Cài đặt uv hoặc pipx
- [ ] `uv tool install graphifyy` (kiểm tra: `graphify --help`)
- [ ] `graphify install --platform opencode`
- [ ] Chạy `/graphify .` trong project
- [ ] Kiểm tra `graphify-out/` đã tạo
- [ ] Mở `graph.html` trong browser kiểm tra
- [ ] `graphify opencode install` (Always-on mode)
- [ ] Test: Đặt câu hỏi trong OpenCode, kiểm tra graph được query trước
- [ ] Tạo `.graphifyignore` loại trừ generated files
- [ ] `graphify hook install` (Git auto-rebuild)
- [ ] (Teams) Commit `graphify-out/` vào git
- [ ] (Teams) Mỗi member chạy `graphify opencode install`

---

> **Lưu ý cuối:** Graphify là tool đang phát triển tích cực. Luôn kiểm tra phiên bản mới nhất và README tại [github.com/safishamsi/graphify](https://github.com/safishamsi/graphify) trước khi triển khai.
