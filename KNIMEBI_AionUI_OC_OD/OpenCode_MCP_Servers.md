# OpenCode MCP Servers: Kết nối BẤT KỲ công cụ nào với AI Agent

> Nguồn tham khảo: [YouTube - OpenCode MCP Servers: Connect ANY Tool to Your AI Agent](https://www.youtube.com/watch?v=nUCwPxMgz_8&t=664s)

---

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Kiến trúc & Cơ chế hoạt động](#2-kiến-trúc--cơ-chế-hoạt-động)
3. [Các loại MCP Server](#3-các-loại-mcp-server)
4. [Hướng dẫn cấu hình chi tiết](#4-hướng-dẫn-cấu-hình-chi-tiết)
5. [Sơ đồ lưu đồ thực hiện](#5-sơ-đồ-lưu-đồ-thực-hiện)
6. [Quy trình triển khai](#6-quy-trình-triển-khai)
7. [Điểm lưu ý & Khó khăn](#7-điểm-lưu-ý--khó-khăn)
8. [Những điều KHÔNG nên cho phép](#8-những-điều-không-nên-cho-phép)
9. [Giải pháp & Tối ưu hóa](#9-giải-pháp--tối-ưu-hóa)
10. [So sánh với đối thủ cạnh tranh](#10-so-sánh-với-đối-thủ-cạnh-tranh)
11. [Tối ưu theo mô hình cụ thể](#11-tối-ưu-theo-mô-hình-cụ-thể)
12. [Ví dụ thực tế](#12-ví-dụ-thực-tế)

---

## 1. Tổng quan

### MCP là gì?

**Model Context Protocol (MCP)** là giao thức chuẩn mở cho phép AI assistant tương tác với các công cụ và dịch vụ bên ngoài. MCP cung cấp:

- **Giao diện chuẩn** để khám phá và thực thi công cụ
- **Nhiều loại truyền tải**: stdio (subprocess), SSE (Server-Sent Events), HTTP
- **Đăng ký công cụ động** tại runtime
- **Mô hình quyền duy nhất** cho tất cả công cụ

### OpenCode hỗ trợ MCP như thế nào?

OpenCode là một **MCP client đầy đủ**, hỗ trợ:

| Khả năng | Chi tiết |
|---|---|
| **Truyền tải** | stdio, SSE, HTTP |
| **Xác thực** | OAuth tự động, Dynamic Client Registration (RFC 7591) |
| **Công cụ** | Chuyển đổi MCP tools thành internal AI tools |
| **Tài nguyên** | Truy cập MCP resources và prompts |
| **Quản lý** | CLI commands: `mcp add`, `mcp list`, `mcp auth`, `mcp debug` |
| **Bảo mật** | Permission system, sandboxing, input validation |

### Tại sao sử dụng MCP với OpenCode?

- **Mở rộng khả năng**: Kết nối GitHub, Sentry, databases, APIs, v.v.
- **Kết nối bất kỳ dịch vụ nào**: Gmail, Supabase, Jira, Linear, v.v.
- **Tách biệt trách nhiệm*Agent tập trung coding, MCP xử lý tích hợp bên ngoài
- **Bảo mật**: Permission system kiểm soát quyền truy cập từng công cụ

---

## 2. Kiến trúc & Cơ chế hoạt động

### Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenCode Runtime                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────────┐   │
│  │  AI Agent   │  │  MCP Catalog │  │  Permission System│   │
│  │  (LLM)      │──│ (convertTool)│──│  (approve/deny)   │   │
│  └─────────────┘  └──────┬───────┘  └───────────────────┘   │
│                          │                                  │
│  ┌───────────────────────┼───────────────────────────────┐  │
│  │              MCP Client Layer                         │  │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────────────┐      │  │
│  │  │  stdio  │  │   SSE    │  │      HTTP        │      │  │
│  │  │ (local) │  │ (remote) │  │   (remote)       │      │  │
│  │  └────┬────┘  └────┬─────┘  └────────┬─────────┘      │  │
│  └───────┼────────────┼─────────────────┼────────────────┘  │
└──────────┼────────────┼─────────────────┼───────────────────┘
           │            │                 │
     ┌─────▼─────┐ ┌────▼───┐  ┌──────────▼───────┐
     │MCP Server │ │MCP     │  │  MCP Server      │
     │(Local)    │ │Server  │  │  (Remote + OAuth)│
     │subprocess │ │(SSE)   │  │                  │
     └───────────┘ └────────┘  └──────────────────┘
```

### Quy trình thực thi tool

```
┌──────────┐     ┌───────────┐     ┌──────────────┐     ┌─────────────┐
│  LLM     │───▶│ Agent     │────▶│ Permission   │───▶│ MCP Client  │
│  quyết   │     │ chọn tool │     │ System       │     │ thực thi    │
│  định    │     │           │     │ (approve?)   │     │             │
└──────────┘     └───────────┘     └──────┬───────┘     └──────┬──────┘
                                          │                    │
                                          ▼                    ▼
                                    ┌──────────┐        ┌──────────┐
                                    │ Denied / │        │ MCP      │
                                    │ Asked    │        │ Server   │
                                    └──────────┘        │ trả về   │
                                                        │ kết quả  │
                                                        └──────────┘
```

### Cơ chế chuyển đổi tool (Adapter Pattern)

OpenCode sử dụng `McpCatalog.convertTool()` để chuyển đổi MCP tools thành internal tools:

1. **Chuẩn hóa schema**: Force `type: "object"`, disable unexpected properties
2. **Gói thực thi**: Wrap execution trong `client.callTool(...)`
3. **Mapping kết quả**: Chuyển `CallToolResult` (content + structuredContent) sang format agent xử lý được

### Khởi tạo MCP Server

Quá trình khởi tạo chạy **bên trong goroutine bất đồng bộ**:

- Timeout 30 giây cho tool discovery
- Panic recovery để tránh crash
- Khởi tạo sớm cho cả interactive và non-interactive mode
- Tránh block application startup

---

## 3. Các loại MCP Server

### 3.1 Local Server (stdio)

Sử dụng subprocess, giao tiếp qua standard input/output.

```json
{
  "mcp": {
    "my-local-mcp": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command"],
      "args": ["--option", "value"],
      "environment": {
        "API_KEY": "xxx"
      },
      "enabled": true,
      "timeout": 5000
    }
  }
}
```

| Thuộc tính | Loại | Bắt buộc | Mô tả |
|---|---|---|---|
| `type` | String | Có | `"local"` |
| `command` | Array | Có | Đường dẫn executable |
| `args` | Array | Không | Arguments dòng lệnh |
| `environment` | Object | Không | Biến môi trường |
| `enabled` | Boolean | Không | Bật/tắt khi khởi động |
| `timeout` | Number | Không | Timeout ms (mặc định 5000) |

### 3.2 Remote Server (HTTP/SSE)

Kết nối đến server từ xa qua HTTP, hỗ trợ OAuth.

```json
{
  "mcp": {
    "my-remote-mcp": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer TOKEN",
        "X-API-Key": "your-api-key"
      },
      "oauth": {
        "clientId": "optional-client-id",
        "clientSecret": "optional-client-secret",
        "scope": "read write"
      },
      "enabled": true,
      "timeout": 10000
    }
  }
}
```

| Thuộc tính | Loại | Bắt buộc | Mô tả |
|---|---|---|---|
| `type` | String | Có | `"remote"` |
| `url` | String | Có | URL của remote MCP server |
| `enabled` | Boolean | Không | Bật/tắt |
| `headers` | Object | Không | HTTP headers |
| `oauth` | Object/false | Không | Cấu hình OAuth hoặc `false` để tắt auto-detect |
| `timeout` | Number | Không | Timeout ms (mặc định 5000) |

### 3.3 So sánh stdio vs SSE vs HTTP

| Tiêu chí | stdio | SSE | HTTP |
|---|---|---|---|
| **Loại kết nối** | Subprocess | Server-Sent Events | REST/HTTP |
| **Phù hợp** | Local tools | Streaming data | API calls |
| **Bảo mật** | cao (local only) | trung bình | tùy cấu hình |
| **Hiệu suất** | nhanh | nhanh | phụ thuộc network |
| **Complexity** | thấp | trung bình | thấp |

---

## 4. Hướng dẫn cấu hình chi tiết

### 4.1 Cài đặt MCP Server qua CLI

```bash
# Thêm MCP server tương tác
opencode mcp add

# Liệt kê các MCP server đã cấu hình
opencode mcp list

# Xác thực OAuth cho remote MCP
opencode mcp auth <server-name>

# Debug kết nối MCP
opencode mcp debug <server-name>
```

### 4.2 Cấu hình trực tiếp trong opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "github": {
      "type": "remote",
      "url": "https://mcp.github.com/sse",
      "enabled": true
    },
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/sse",
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/sse",
      "enabled": true
    },
    "local-db": {
      "type": "local",
      "command": ["bun", "x", "@modelcontextprotocol/server-sqlite", "--db-path", "./data.db"],
      "enabled": true
    }
  }
}
```

### 4.3 Cấu hình Per-Agent (cho nhiều MCP servers)

Khi có nhiều MCP servers, có thể tắt globally và chỉ bật cho agent cụ thể:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command"],
      "enabled": true
    }
  },
  "tools": {
    "my-mcp*": false
  },
  "agent": {
    "my-agent": {
      "tools": {
        "my-mcp*": true
      }
    }
  }
}
```

### 4.4 Cấu hình Permission

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "mymcp_*": "ask"
  }
}
```

Các chế độ permission:
- `"ask"` - Hỏi người dùng trước khi thực thi
- `true` - Luôn cho phép (cẩn thận!)
- `false` - Luôn từ chối

### 4.5 Ví dụ: Kết nối Composio MCP Gateway

```bash
# Bước 1: Thêm server
opencode mcp add
# Name: composio
# Type: remote
# URL: https://connect.composio.dev/mcp
# Require OAuth: Yes

# Bước 2: Xác thực
opencode mcp auth composio

# Bước 3: Kiểm tra
opencode mcp list
```

Hoặc cấu hình trực tiếp:

```json
{
  "mcp": {
    "composio": {
      "type": "remote",
      "url": "https://connect.composio.dev/mcp",
      "enabled": true
    }
  }
}
```

### 4.6 Cấu hình OAuth

```json
{
  "mcp": {
    "oauth-server": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "oauth": {
        "clientId": "my-client-id",
        "clientSecret": "my-client-secret",
        "scope": "read write"
      }
    }
  }
}
```

**Tắt OAuth tự động** (dùng API key thay thế):

```json
{
  "mcp": {
    "api-key-server": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_KEY"
      },
      "oauth": false
    }
  }
}
```

### 4.7 Tổ chức theo Workspace (Enterprise)

Organizations có thể cung cấp MCP servers qua `.opencode-known/` directory, servers này sẽ được load tự động.

---

## 5. Sơ đồ lưu đồ thực hiện

### 5.1 Lưu đồ khởi tạo MCP Server

```
┌─────────────────────┐
│    OpenCode Start   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Đọc opencode.json   │
│ (MCP config)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Với mỗi MCP server  │──── Có 0 servers? ────▶ Kết thúc
│ trong config        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ type == "local"?    │──── Có ────▶ Spawn subprocess
│                     │                │
└──────────┬──────────┘                ▼
           │                 ┌─────────────────┐
           │ Không           │ Giao tiếp stdio │
           ▼                 │ Discover tools  │
┌─────────────────────┐      └────────┬────────┘
│ type == "remote"?   │               │
│                     │◀─────────────┘
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ HTTP/SSE connect    │
│ Detect OAuth?       │
└──────────┬──────────┘
           │
     ┌─────┴──────┐
     │            │
  Cần OAuth   Không cần
     │            │
     ▼            ▼
┌──────────┐ ┌──────────────┐
│ OAuth    │ │ Direct       │
│ Flow     │ │ Connect      │
│ (browser)│ │ Discover     │
└────┬─────┘ │ Tools        │
     │       └──────┬───────┘
     │              │
     ▼              ▼
┌─────────────────────────┐
│ Register tools với Agent│
│ (McpCatalog.convertTool)│
└─────────────────────────┘
```

### 5.2 Lưu đồ thực thi MCP Tool

```
┌──────────────┐
│ Agent nhận   │
│ user request │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ LLM quyết    │
│ định gọi     │
│ MCP tool     │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ Permission Check │
│(ask/approve/deny)│
└──────┬───────────┘
       │
  ┌────┴────┐
  │         │
Approved  Denied
  │         │
  ▼         ▼
┌───────────┐ ┌──────────┐
│ Gọi MCP   │ │ Trả về   │
│ client.   │ │ lỗi cho  │
│ callTool()│ │ user     │
└─────┬─────┘ └──────────┘
      │
      ▼
┌──────────────────┐
│ MCP Server       │
│ thực thi         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Trả về kết quả   │
│ (content +       │
│structuredContent)│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Agent xử lý      │
│ và trả lời user  │
└──────────────────┘
```

### 5.3 Lưu đồ OAuth Flow

```
┌──────────────────┐
│ Gọi remote MCP   │
│ server           │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Nhận 401         │
│ Unauthorized     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Initiate OAuth   │
│ flow             │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Dynamic Client   │
│ Registration     │
│ (RFC 7591)       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Mở browser       │
│ /authorize       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ User xác thực    │
│ trong browser    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Callback server  │
│ (port 19876)     │
│ nhận auth code   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Token exchange   │
│ (access + refresh│
│  tokens)         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Lưu tokens vào   │
│ mcp-auth.json    │
│ (~/.local/share/ │
│  opencode/)      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Gọi MCP tool     │
│ thành công       │
└──────────────────┘
```

---

## 6. Quy trình triển khai

### Bước 1: Lựa chọn MCP Server

Xác định nhu cầu:
- **Database access** → SQLite/PostgreSQL MCP server
- **GitHub integration** → GitHub MCP server
- **Issue tracking** → Sentry, Jira, Linear MCP server
- **Documentation** → Context7 MCP server
- **Code search** → Grep by Vercel MCP server
- **Multi-tool gateway** → Composio MCP gateway

### Bước 2: Cấu hình trong opencode.json

```bash
# Cách 1: Sử dụng CLI (tương tác)
opencode mcp add

# Cách 2: Chỉnh sửa trực tiếp opencode.json
```

### Bước 3: Xác thực (nếu cần)

```bash
# Remote server cần OAuth
opencode mcp auth <server-name>

# Debug nếu có vấn đề
opencode mcp debug <server-name>
```

### Bước 4: Kiểm tra

```bash
# Liệt kê servers và trạng thái
opencode mcp list
```

Trạng thái có thể thấy:
- `connected` - Đã kết nối thành công
- `needs authentication` - Cần xác thực

### Bước 5: Sử dụng trong prompts

```
use the context7 tool to search documentation for React hooks
use the gh_grep tool to search code on GitHub
```

### Bước 6: Triển khai cho Production

```bash
# Khởi chạy headless server
opencode serve

# Hoặc sử dụng opencode-mcp bridge
npx opencode-mcp
```

---

## 7. Điểm lưu ý & Khó khăn

### 7.1 Vấn đề Context Window (quan trọng nhất)

> **Mỗi MCP server thêm vào context sẽ tiêu tốn tokens.** Ví dụ: GitHub MCP server alone có thể tiêu ~20K tokens. Thêm Jira, Linear, Supabase sẽ gần như "bóp nghẹt" context window của model.

**Giải pháp:**
- Sử dụng **MCP Gateway** (như Composio) thay vì wire từng server một
- Chỉ enable MCP server cần thiết cho task hiện tại
- Sử dụng per-agent MCP configuration

### 7.2 Multi-tenant Serving

Vấn đề: Khi chạy `opencode serve` cho nhiều users, tất cả sessions chia sẻ cùng cấu hình MCP static. MCP server không thể phân biệt user nào đang request.

**Giải pháp hiện tại:**
- Chưa có per-session MCP auth headers (đang phát triển)
- Cần đợi feature `mcpAuth` trong session creation

### 7.3 Timeout & Reliability

- MCP server có thể chậm, không phản hồi
- Subprocess có thể crash
- Network issues với remote servers

**Giải pháp:**
- Config timeout hợp lý (mặc định 5000ms)
- Panic recovery đã được tích hợp sẵn
- Retry logic cần implement ở application level

### 7.4 Khó khăn với OAuth

- Dynamic Client Registration không phải server nào cũng hỗ trợ
- Token refresh có thể fail
- Callback server sử dụng port cố định (19876) có thể conflict

### 7.5 Tool Discovery overhead

- Server có thể expose hàng trăm tools
- Pagination cần được xử lý đúng
- Schema normalization có thể bỏ lỡ edge cases

### 7.6 Không hỗ trợ per-session MCP servers (REST API)

Hiện tại, REST API `POST /session` chưa hỗ trợ `mcpServers` parameter (chỉ ACP SDK hỗ trợ). Đây là limitation đang được thảo luận trong community.

---

## 8. Những điều KHÔNG nên cho phép

### 8.1 KHÔNG enable tất cả MCP servers cùng lúc

```json
// SAI - Không làm thế này!
{
  "mcp": {
    "github": { "type": "remote", "url": "...", "enabled": true },
    "sentry": { "type": "remote", "url": "...", "enabled": true },
    "jira": { "type": "remote", "url": "...", "enabled": true },
    "linear": { "type": "remote", "url": "...", "enabled": true },
    "slack": { "type": "remote", "url": "...", "enabled": true },
    "notion": { "type": "remote", "url": "...", "enabled": true },
    "supabase": { "type": "remote", "url": "...", "enabled": true }
  }
}
// → Bóp nghẹt context window, LLM sẽ poorly perform
```

### 8.2 KHÔNG set permission `"true"` cho production

```json
// NGUY HIỂM - Không làm thế này!
{
  "permission": {
    "mymcp_*": true
  }
}
// → MCP tools sẽ execute mà không cần approval
// → Rủi ro bảo mật cao
```

### 8.3 KHÔNG hardcode secrets trong config

```json
// SAI
{
  "mcp": {
    "my-server": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer sk_live_REAL_SECRET_KEY_HERE"
      }
    }
  }
}
// → Secret sẽ bị expose trong file config
```

**Nên làm:** Sử dụng environment variables hoặc vault system.

### 8.4 KHÔNG disable OAuth cho server yêu cầu OAuth

```json
// SAI
{
  "mcp": {
    "protected-server": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "oauth": false
    }
  }
}
// → Không thể xác thực, request sẽ fail
```

### 8.5 KHÔNG chạy MCP server subprocess trong production không có monitoring

- Subprocess có thể crash mà không log
- Không có auto-restart mechanism
- Resource leak nếu không cleanup đúng cách

### 8.6 KHÔNG truyền API keys qua command line arguments

```bash
# SAI - API key sẽ lộ trong process list
opencode mcp add --header "Authorization: Bearer SECRET_KEY"

# Nên dùng environment variables hoặc config file
```

### 8.7 KHÔNG sử dụng HTTP transport không có HTTPS trong production

```json
// SAI cho production
{
  "mcp": {
    "my-server": {
      "type": "remote",
      "url": "http://api.example.com/mcp"  // HTTP, không phải HTTPS
    }
  }
}
// → Data truyền không được mã hóa
```

### 8.8 KHÔNG bỏ qua security audit cho custom MCP servers

- Kiểm tra command injection vulnerabilities
- Verify path traversal protections
- Audit dependencies regularly
- Implement rate limiting cho HTTP transport

---

## 9. Giải pháp & Tối ưu hóa

### 9.1 Sử dụng MCP Gateway Pattern

Thay vì wire từng MCP server trực tiếp, sử dụng gateway:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│ OpenCode    │───▶ │ MCP Gateway  │───▶│ MCP Server A    │
│ Agent       │     │ (Composio)   │     │ MCP Server B    │
│             │     │              │     │ MCP Server C    │
│ Chỉ thấy    │     │ Meta-tools:  │     │ ...             │
│ few tools   │     │ Search       │     │ MCP Server 1000 │
└─────────────┘     │ Planner      │     └─────────────────┘
                    │ Workbench    │
                    └──────────────┘
```

**Lợi ích:**
- Context window sạch, chỉ thấy few meta-tools
- Tool discovery happening tại gateway layer
- Authentication managed centrally
- Large artifacts stored in file system, không dump vào context

### 9.2 Per-Agent MCP Configuration

```json
{
  "mcp": {
    "github": { "type": "remote", "url": "...", "enabled": true },
    "sentry": { "type": "remote", "url": "...", "enabled": true },
    "database": { "type": "local", "command": [...], "enabled": true }
  },
  "tools": {
    "github*": false,
    "sentry*": false,
    "database*": false
  },
  "agent": {
    "code-reviewer": {
      "tools": {
        "github*": true,
        "sentry*": true
      }
    },
    "data-analyst": {
      "tools": {
        "database*": true
      }
    }
  }
}
```

### 9.3 Lazy Tool Loading (Composio Pattern)

- Expose chỉ few meta tools (Search, Planner, Remote Workbench)
- Search tool fetches only relevant tools khi agent cần
- Large artefacts được store trong file system
- Fetch results only as needed

### 9.4 Permission Strategy

```json
{
  "permission": {
    "github_*": "ask",
    "sentry_*": "ask",
    "database_*": false,
    "context7_*": true
  }
}
```

**Chiến lược:**
- `ask` cho tools có quyền đọc/ghi (GitHub, Jira)
- `true` cho tools read-only (Context7, Grep)
- `false` cho tools nguy hiểm (database write operations)

### 9.5 Timeout & Retry Configuration

```json
{
  "mcp": {
    "fast-server": {
      "type": "remote",
      "url": "...",
      "timeout": 3000
    },
    "slow-server": {
      "type": "remote",
      "url": "...",
      "timeout": 30000
    }
  }
}
```

### 9.6 Monitoring & Debugging

```bash
# Debug kết nối
opencode mcp debug <server-name>

# Kiểm tra trạng thái
opencode mcp list

# Xem log chi tiết
OPENCODE_LOG_LEVEL=debug opencode
```

---

## 10. So sánh với đối thủ cạnh tranh

### 10.1 Tổng quan so sánh

| Tiêu chí | OpenCode | Claude Code | Goose | Cline | Aider |
|---|---|---|---|---|---|
| **License** | MIT | Proprietary | Apache 2.0 | Apache 2.0 | Apache 2.0 |
| **Host surface** | CLI/TUI | CLI + IDE plugins | CLI + Desktop | VS Code extension | Python CLI |
| **MCP support** | Native + LSP | Native (reference) | Native, 70+ extensions | Native, custom tools | Không có |
| **Provider lock-in** | Không | Anthropic only | Không | Không | Không |
| **Providers** | 75+ | Anthropic only | Nhiều | Nhiều | Nhiều |
| **Best at** | TUI, MIT, provider freedom | First-party Claude experience | Broad MCP, neutral OSS | Permission-gated in VS Code | Codebase-aware pair programming |

### 10.2 OpenCode vs Claude Code - Chi tiết

| Tiêu chí | OpenCode | Claude Code |
|---|---|---|
| **MCP Protocol Coverage** | Rất tốt (breadth) | Xuất sắc (depth) |
| **Transport types** | stdio, SSE, HTTP | stdio, SSE, HTTP, WS, SDK, in-process |
| **OAuth** | Cơ bản (auto-detect) | Nâng cao (discovery, refresh, revoke, XAA) |
| **Per-agent MCP** | Có | Có + channel permissions |
| **Elicitation** | Không | Có (structured user input) |
| **Official Registry** | Không | Có (Anthropic registry) |
| **Claude.ai Integration** | Không | Có (proxy MCP configs) |
| **In-process MCP** | Không | Có (InProcessTransport) |
| **Code Intelligence** | MCP + LSP | MCP + Claude tuning |

**Nhận xét:**
- **OpenCode = Breadth**: Mở rộng, linh hoạt, MIT license, 75+ providers
- **Claude Code = Depth**: Sâu, product-grade, governed, first-party Anthropic

### 10.3 OpenCode vs Goose

| Tiêu chí | OpenCode | Goose |
|---|---|---|
| **MCP** | Native + LSP | Native, 70+ extensions |
| **License** | MIT | Apache 2.0 |
| **Provider** | 75+ providers | Nhiều providers |
| **UI** | TUI | CLI + Desktop |
| **Extension** | MCP, plugins | MCP, extensions |

### 10.4 OpenCode vs Aider

| Tiêu chí | OpenCode | Aider |
|---|---|---|
| **MCP** | Native | **Không có** |
| **LSP** | Có | Không |
| **UI** | TUI | CLI |
| **Provider** | 75+ | Nhiều |

**Lưu ý:** Aider không có native MCP support. Nếu cần MCP, phải dùng wrapper scripts.

### 10.5 Ba tầng của MCP Support

1. **Protocol Coverage**: Transports, tool calls, resources, prompts, auth → OpenCode xuất sắc
2. **Product Integration**: Permissions, UI, state, recovery, governance → Claude Code xuất sắc
3. **Extensibility Design**: Plugins, skills, user migration paths → OMO (Oh-My-OpenCode) sáng tạo nhất

---

## 11. Tối ưu theo mô hình cụ thể

### 11.1 Claude Models (claude-sonnet-4-5, claude-opus-4)

```json
{
  "mcp": {
    "github": { "type": "remote", "url": "...", "enabled": true },
    "context7": { "type": "remote", "url": "...", "enabled": true }
  },
  "tools": {
    "github*": "ask",
    "context7*": true
  }
}
```

**Tối ưu:**
- Context window lớn (200K tokens) → Có thể enable nhiều MCP servers
- Sử dụng LSP integration để có code intelligence
- Kết hợp AGENTS.md với MCP tools

### 11.2 GPT-4o / GPT-4.1

```json
{
  "mcp": {
    "essential-mcp": {
      "type": "remote",
      "url": "...",
      "enabled": true,
      "timeout": 5000
    }
  }
}
```

**Tối ưu:**
- Context window 128K → Hạn chế số MCP servers
- Timeout ngắn hơn vì GPT models thường respond nhanh
- Sử dụng per-agent MCP để control

### 11.3 Local Models (Ollama, LM Studio)

```json
{
  "mcp": {
    "local-db": {
      "type": "local",
      "command": ["bun", "x", "sqlite-server"],
      "enabled": true,
      "timeout": 10000
    }
  }
}
```

**Tối ưu:**
- Chỉ dùng local MCP servers (stdio)
- Context window nhỏ → Rất ít MCP servers
- Timeout dài hơn vì local models có thể chậm
- Phù hợp cho development/testing

### 11.4 Gemini Models

```json
{
  "mcp": {
    "github": { "type": "remote", "url": "...", "enabled": true },
    "sentry": { "type": "remote", "url": "...", "enabled": true }
  }
}
```

**Tối ưu:**
- Context window 1M tokens → Có thể enable nhiều MCP servers
- Phù hợp cho complex multi-tool workflows
- Sử dụng Gemini's native multimodal capabilities kết hợp MCP tools

### 11.5 DeepSeek Models

```json
{
  "mcp": {
    "essential-only": {
      "type": "remote",
      "url": "...",
      "enabled": true,
      "timeout": 8000
    }
  }
}
```

**Tối ưu:**
- Context window 64K → Rất tiết kiệm MCP servers
- Chọn essential tools only
- DeepSeek giá rẻ → Phù hợp production high-volume

### 11.6 Bảng tối ưu theo Context Window

| Model Family | Context Window | MCP Servers tối đa khuyến nghị | Strategy |
|---|---|---|---|
| Claude 3.5 Sonnet | 200K | 5-7 | Balanced |
| Claude Opus 4 | 200K | 5-7 | Balanced |
| GPT-4o | 128K | 3-5 | Conservative |
| GPT-4.1 | 1M | 10-15 | Aggressive |
| Gemini 1.5 Pro | 1M | 10-15 | Aggressive |
| DeepSeek V3 | 64K | 2-3 | Minimal |
| Local (Llama) | 8-32K | 1 | Minimal |

---

## 12. Ví dụ thực tế

### Ví dụ 1: Code Review Agent

```json
{
  "mcp": {
    "github": { "type": "remote", "url": "https://mcp.github.com/sse", "enabled": true },
    "sentry": { "type": "remote", "url": "https://mcp.sentry.dev/sse", "enabled": true }
  },
  "agent": {
    "code-reviewer": {
      "tools": {
        "github*": true,
        "sentry*": true
      }
    }
  }
}
```

Prompt: `Review the latest PR for bugs and check Sentry for related errors`

### Ví dụ 2: Data Pipeline Agent

```json
{
  "mcp": {
    "supabase": {
      "type": "remote",
      "url": "https://connect.composio.dev/mcp",
      "enabled": true
    },
    "database": {
      "type": "local",
      "command": ["bun", "x", "@modelcontextprotocol/server-sqlite"],
      "enabled": true
    }
  }
}
```

Prompt: `use the supabase tool to create a database schema for vehicle parking management`

### Ví dụ 3: Documentation Agent

```json
{
  "mcp": {
    "context7": { "type": "remote", "url": "https://mcp.context7.com/sse", "enabled": true },
    "grep": { "type": "remote", "url": "https://mcp.grep.dev/sse", "enabled": true }
  }
}
```

Prompt: `use the context7 tool to find React hooks documentation and the gh_grep tool to find examples`

---

## Tóm tắt

| Khía cạnh | Đánh giá |
|---|---|
| **Ease of Setup** | ⭐⭐⭐⭐ (CLI đơn giản, config trực tiếp) |
| **Protocol Support** | ⭐⭐⭐⭐⭐ (stdio, SSE, HTTP, OAuth) |
| **Security** | ⭐⭐⭐⭐ (permission system, nhưng cần hardening) |
| **Scalability** | ⭐⭐⭐ (context window là bottleneck chính) |
| **Documentation** | ⭐⭐⭐⭐ (tốt, nhưng còn thiếu một số edge cases) |
| **Community** | ⭐⭐⭐⭐⭐ (MIT, active development) |
| **Production Readiness** | ⭐⭐⭐ (cần thêm monitoring, multi-tenant support) |

> **Lời khuyên:** Bắt đầu với 1-2 MCP servers cần thiết, sử dụng per-agent configuration, và gradually thêm khi cần. Luôn monitor context window usage và implement permission strategy phù hợp.
