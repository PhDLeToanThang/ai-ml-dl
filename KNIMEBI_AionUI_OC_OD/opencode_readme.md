# OpenCode - Tổng Hợp Hướng Dẫn Sử Dụng Toàn Diện

> Tổng hợp từ 5 video hướng dẫn và nhiều nguồn tham khảo chính thức

---

## Mục Lục

1. [Tổng Quan OpenCode](#1-tổng-quan-opencode)
2. [Cơ Chế Hoạt Động (Agentic Loop)](#2-cơ-chế-hoạt-động-agentic-loop)
3. [Cài Đặt và Khởi Tạo](#3-cài-đặt-và-khởi-tạo)
4. [Cấu Hình Provider và Model](#4-cấu-hình-provider-và-model)
5. [Cấu Hình Local LLM](#5-cấu-hình-local-llm)
6. [Skills - Hệ Thống Kỹ Năng](#6-skills---hệ-thống-kỹ-năng)
7. [MCP Servers - Kết Nối Công Cụ Bên Ngoài](#7-mcp-servers---kết-nối-công-cụ-bên-ngoài)
8. [Commands và Agents](#8-commands-và-agents)
9. [Sơ Đồ Lưu Đồ Thực Hiện](#9-sơ-đồ-lưu-đồ-thực-hiện)
10. [So Sánh Với Đối Thủ](#10-so-sánh-với-đối-thủ)
11. [Khó Khăn và Giới Hạn](#11-khó-khăn-và-giới-hạn)
12. [Những Điều Không Nên Làm](#12-những-điều-không-nên-làm)
13. [Lưu Ý Khi Triển Khai](#13-lưu-ý-khi-triển-khai)
14. [Giải Pháp Sử Dụng](#14-giải-pháp-sử-dụng)
15. [Tài Liệu Tham Khảo](#15-tài-liệu-tham-khảo)

---

## 1. Tổng Quan OpenCode

### OpenCode là gì?

OpenCode là một **AI coding agent mã nguồn mở** hoạt động trên terminal, được xây dựng bằng ngôn ngữ Go với giao diện Bubble Tea TUI. Hiện có hơn **172K GitHub stars** - là dự án open-source lớn nhất trong lĩnh vực AI coding agent.

### Khả năng chính

- Đọc, sửa, tạo file trực tiếp trên hệ thống
- Thực thi lệnh terminal và theo dõi kết quả
- Tìm kiếm, phân tích toàn bộ codebase
- **Tự động fix lỗi** (closed-loop development)
- Hỗ trợ **75+ LLM providers** bao gồm cả model local
- Kết nối công cụ bên ngoài qua **MCP (Model Context Protocol)**
- Chạy nhiều **sub-agent song song** cho dự án lớn

### Tại sao chọn CLI thay vì Web Chat?

| Khía Cạnh        | OpenCode CLI               | Web LLM Chat              |
|------------------|---------------------------|---------------------------|
| Vai trò          | **Người thực thi** - thay đổi file, chạy lệnh | **Người tư vấn** - chỉ trả lời văn bản |
| Tương tác        | Đọc/Sửa file trực tiếp    | Copy-paste thủ công       |
| Context          | Hiểu toàn bộ repository  | Chỉ trong 1 session       |
| Closed-loop      | Tự phát hiện và fix lỗi  | Phải feedback thủ công    |
| Bảo mật          | Chạy local được           | Dữ liệu gửi lên cloud     |
| Tích hợp Git     | Tạo commit, branch trực tiếp | Không có tích hợp        |

### Lệnh Tiện Ích

| Lệnh              | Chức năng                    | Phím tắt   |
|--------------------|-------------------------------|------------|
| `/init`           | Khởi tạo dự án               | `Ctrl+X I` |
| `/models`         | Xem/danh sách/chuyển model   | `Ctrl+X M` |
| `/connect`        | Kết nối nhà cung cấp model   | -          |
| `/undo`           | Hoàn tác thao tác cuối       | `Ctrl+X U` |
| `/redo`           | Làm lại thao tác đã hoàn tác | `Ctrl+X R` |
| `/share`          | Chia sẻ phiên làm việc       | `Ctrl+X S` |
| `/new`            | Bắt đầu phiên mới            | `Ctrl+X N` |
| `/sessions`       | Danh sách các phiên          | `Ctrl+X L` |
| `/compact`        | Rút gọn context phiên        | `Ctrl+X C` |
| `/exit`           | Thoát chương trình           | `Ctrl+X Q` |

```bash
# Các lệnh terminal bổ sung
opencode models              # Liệt kê tất cả model khả dụng
opencode auth login          # Đăng nhập nhà cung cấp
opencode auth logout         # Đăng xuất
```

### Hai chế độ Agent mặc định

| Chế độ | Chức năng | Cách chuyển |
|--------|-----------|-------------|
| **Build** | Toàn quyền chỉnh sửa file, chạy lệnh | Mặc định |
| **Plan** | Chỉ đọc, phân tích - không thay đổi gì | Nhấn `Tab` |

---

## 2. Cơ Chế Hoạt Động (Agentic Loop)

### Nguyên lý ReAct Loop (Think-Act-Observe)

Mọi tác vụ trong OpenCode đều tuân theo vòng lặp 3 bước lặp đi lặp lại:

```
┌─────────────────────────────────────────────────────────────┐
│                      VÒNG LẶP AGENTIC                       │
│                                                             │
│    ┌────────────┐      ┌────────────┐      ┌────────────┐   │
│    │  PERCEIVE  │─────>│   THINK    │─────>│    ACT     │   │
│    │  (Thu thập │      │  (Suy luận │      │  (Thực thi │   │
│    │   context) │      │   kế hoạch)│      │   thao tác)│   │
│    └────────────┘      └────────────┘      └─────┬──────┘   │
│          ^                                       │          │
│          │            ┌────────────┐             │          │
│          └────────────│  OBSERVE   │<────────────┘          │
│                       │ (Kiểm tra  │                        │
│                       │  kết quả)  │                        │
│                       └──────┬─────┘                        │
│                              │                              │
│                     ┌────────┴────────┐                     │
│                     │  Đã hoàn thành? │                     │
│                     │    Có  │  Không │                     │
│                     └────────┴────────┘                     │
│                       │        │                            │
│                       v        └──> Quay lại THINK          │
│                  ┌─────────┐                                │
│                  │  OUTPUT │                                │
│                  └─────────┘                                │
└─────────────────────────────────────────────────────────────┘
```

### 5 lớp kiến trúc trong hệ thống

```
┌─────────────────────────────────────────────────────────────┐
│                   KIẾN TRÚC HE THỐNG                        │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 1. PROMPT ASSEMBLY                                   │   │
│  │    - System prompt + lịch sử hội thoại               │   │
│  │    - Schema các công cụ có sẵn                       │   │
│  │    - Thông tin runtime (model, temperature, quyền)   │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          v                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 2. TOOL ECOSYSTEM                                    │   │
│  │    - File I/O: đọc/ghi/sửa file trực tiếp            │   │
│  │    - Shell: chạy lệnh terminal                       │   │
│  │    - Search: tìm kiếm code và nội dung               │   │
│  │    - Browser: tương tác web (qua MCP)                │   │
│  │    - MCP Tools: công cụ kết nối bên ngoài            │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          v                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 3. PERMISSION MODEL                                  │   │
│  │    - Quyền truy cập file và thư mục                  │   │
│  │    - Quyền chạy lệnh shell                           │   │
│  │    - Xác nhận trước khi thực hiện hành động nguy hiểm│   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          v                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 4. HOOKS (Bộ lọc chất lượng)                         │   │
│  │    - Trước khi thực thi: kiểm tra an toàn            │   │
│  │    - Sau khi thực thi: xác nhận kết quả              │   │
│  │    - Đảm bảo code đúng chuẩn và không phá vỡ logic   │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          v                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 5. SUBAGENTS                                         │   │
│  │    - Agent phụ thực hiện tác vụ song song            │   │
│  │    - Phân chia công việc cho dự án lớn               │   │
│  │    - Quản lý context và kết quả riêng biệt           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Quy trình thực hiện chi tiết một task

```
Người dùng nhập prompt
        │
        v
┌─────────────────────────────┐
│ BƯỚC 1: TỔNG HỢP CONTEXT    │
│ • Đọc system prompt         │
│ • Scan cấu trúc project     │
│ • Đọc AGENTS.md / CLAUDE.md │
│ • Liệt kê các tool có sẵn   │
└──────────────┬──────────────┘
               v
┌─────────────────────────────┐
│ BƯỚC 2: LẬP KẾ HOẠCH        │
│ • Phân tích yêu cầu         │
│ • Chia thành bước cụ thể    │
│ • Chọn tool phù hợp mỗi bước│
│ • Ước lượng độ phức tạp     │
└──────────────┬──────────────┘
               v
┌─────────────────────────────┐
│ BƯỚC 3: THỰC HIỆN           │
│ • Gọi tool (đọc/sửa file)   │
│ • Chạy lệnh terminal        │
│ • Gọi MCP server nếu cần    │
│ • Chạy test, lint           │
└──────────────┬──────────────┘
               v
┌───────────────────────────────┐
│ BƯỚC 4: XÁC NHẬN KẾT QUẢ      │
│ • So sánh với mục tiêu ban đầu│
│ • Chạy verification (test)    │
│ • Nếu lỗi → quay lại BƯỚC 2   │
│ • Nếu thành công → tiếp tục   │
└──────────────┬────────────────┘
               v
┌────────────────────────────────┐
│ BƯỚC 5: TRÌNH BÀY KẾT QUẢ      │
│ • Tóm tắt thay đổi đã thực hiện│
│ • Tạo commit (nếu được phép)   │
│ • Đợi yêu cầu tiếp theo        │
└────────────────────────────────┘
```

---

## 3. Cài Đặt và Khởi Tạo

### Các phương thức cài đặt

```bash
# Phương thức 1: Script chính thức (khuyến nghị)
curl -fsSL https://opencode.ai/install | bash

# Phương thức 2: Homebrew (macOS/Linux)
brew install opencode

# Phương thức 3: npm
npm install -g @opencode-ai/cli

# Phương thức 4: Từ nguồn
git clone https://github.com/opencode-ai/opencode
cd opencode && npm install && npm run build && npm link
```

### Xác minh cài đặt

```bash
opencode --version
opencode --help
```

### Khởi chạy lần đầu

```bash
cd /duong/dan/du-an-cua-ban
opencode
```

### Ví dụ thực tế

```bash
# Hỏi về kiến trúc dự án
"Hãy giải thích cách xác thực (authentication) được triển khai trong dự án này?"

# Tạo hàm mới
"Tạo một hàm Python kiểm tra địa chỉ email bằng regex, có exception handling"

# Refactor code
"Refactor hàm trong @src/utils/helpers để dùng async/await"

# Debug lỗi
"Hàm login đang trả về lỗi 500. Hãy kiểm tra log và tìm nguyên nhân gốc."
```

---

## 4. Cấu Hình Provider và Model

### Vị trí file cấu hình

| Hệ điều hành | Đường dẫn |
|---------------|-----------|
| Windows | `%USERPROFILE%\.config\opencode\opencode.json` |
| macOS | `~/.config/opencode/opencode.json` |
| Linux | `~/.config/opencode/opencode.json` |

### Cấu hình cơ bản

```json
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "opencode",
  "model": "anthropic/claude-sonnet-4-5",
  "autoupdate": true
}
```

### Cấu hình đa model

```json
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "opencode",
  "provider": {
    "default": "glm-5-free",
    "github": {
      "type": "github_copilot",
      "enabled": true
    },
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama Local",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": {
          "_launch": true,
          "name": "Qwen3:8b"
        }
      }
    }
  }
}
```

### Model miễn phí khả dụng

| Model | Ưu điểm | Phù hợp cho |
|-------|---------|-------------|
| Minimax M2.5 Free | Cân bằng tốt | Nhiệm vụ tổng quát |
| Trinity Large Preview | Phản hồi nhanh | Task đơn giản |
| Big Pickle | Hiểu code tốt | Tạo và refactor code |

### Khuyến nghị model theo phần cứng

| RAM | GPU | Model khuyến nghị | Ghi chú |
|-----|-----|-------------------|---------|
| 16GB | RTX 3060 | qwen2.5-coder:7b | Cơ bản |
| 32GB | RTX 4060 | qwen3:8b | Ổn |
| 32GB+ | RTX 5060 Laptop+ | qwen3:8b | **Khuyến nghị** |
| 48GB+ | RTX 4090 | qwen2.5-coder:32b | Tối ưu |

---

## 5. Cấu Hình Local LLM

### Phương án 1: Ollama (Đơn giản nhất)

**Bước 0: Cài đặt Ollama**

Tải và cài đặt từ https://ollama.com

**Bước 1: Tải model**

```bash
# Khuyến nghị cho cấu hình 32GB RAM + RTX 5060
ollama run qwen3:8b

# Hoặc model khác tùy phần cứng
ollama run qwen2.5-coder:7b
```

**Bước 2: Cấu hình OpenCode**

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama Local",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": {
          "_launch": true,
          "name": "Qwen3:8b"
        }
      }
    }
  }
}
```

> **Lưu ý quan trọng:** Ollama baseURL **BẮT BUỘC** phải có hậu tố `/v1`

### Phương án 2: LM Studio

```json
{
  "provider": {
    "lmstudio": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LM Studio Local",
      "options": {
        "baseURL": "http://localhost:1234/v1"
      },
      "models": {
        "qwen2.5-coder-32b": {
          "name": "Qwen 2.5 Coder 32B (local)",
          "limit": { "context": 8192, "output": 4096 }
        }
      }
    }
  }
}
```

### Phương án 3: vLLM

```json
{
  "provider": {
    "vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "vLLM Local",
      "options": {
        "baseURL": "http://localhost:8000/v1"
      },
      "models": {
        "qwen2.5-coder-7b": {
          "name": "Qwen 2.5 Coder 7B",
          "limit": { "context": 32768, "output": 8192 }
        }
      }
    }
  }
}
```

### Phương án 4: LiteLLM Proxy (Nhiều model)

```json
{
  "provider": {
    "litellm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LiteLLM (Local)",
      "options": {
        "baseURL": "http://localhost:4000/v1",
        "apiKey": "{env:LITELLM_API_KEY}"
      },
      "models": {
        "qwen-coder-fast": {
          "name": "Qwen 2.5 Coder 7B (FREE)",
          "limit": { "context": 32768, "output": 8192 }
        },
        "claude-sonnet": {
          "name": "Claude 3.5 Sonnet (Bedrock)",
          "limit": { "context": 200000, "output": 8192 }
        }
      }
    }
  }
}
```

### Sử dụng model khi chạy

```bash
opencode -m ollama/qwen3:8b
opencode -m litellm/qwen-coder-fast
```

---

## 6. Skills - Hệ Thống Kỹ Năng

### Skills là gì?

Skills là **các file markdown** chứa hướng dẫn chi tiết, lặp lại được để thực hiện một loại tác vụ cụ thể. Khi một skill khớp với yêu cầu, OpenCode sẽ tự động tải toàn bộ nội dung hướng dẫn để thực hiện theo.

### Cấu trúc thư mục

```
.opencode/
  skills/
    my-skill/
      SKILL.md
```

### Định dạng SKILL.md

```markdown
---
name: ten-skill
description: Mô tả ngắn gọn về skill
---

# Hướng Dẫn Thực Hiện

1. Bước 1: ...
2. Bước 2: ...
3. Bước 3: ...

## Ví dụ cụ thể
...
```

### Các vị trí tìm kiếm Skills

OpenCode tự động tìm skills tại:
- `.opencode/skills/` (quy mô dự án - ưu tiên)
- `~/.config/opencode/skills/` (quy mô toàn cục)
- `.claude/skills/` (tương thích Claude)
- `.agents/skills/`

### 5 Skills quan trọng nhất nên cài

#### 1. Graphify - Chuyển Đổi Tài Liệu
Chuyển đổi bất kỳ file nào thành dữ liệu có cấu trúc. Hữu ích cho xử lý dữ liệu và tích hợp hệ thống.

#### 2. Awesome Design.md - Quy Tắc Thiết Kế UI/UX
Bộ quy tắc thiết kế UI được chuẩn hóa, đảm bảo giao diện đồng nhất và không bị "generic AI style".

#### 3. Get Shit Done - Quản Lý Context
Xử lý tình trạng "context rot" (mất context khi làm việc quá dài), giúp phiên làm việc luôn hiệu quả.

#### 4. Everything Claude Code - Production Harness
Bộ công cụ đầy đủ cho môi trường production: test, review, deploy workflow.

#### 5. UI UX Pro Max - Thiết Kế Chuyên Nghiệp
Thiết kế giao diện chuyên nghiệp, bắt buộc AI chọn phong cách thiết kế trước khi viết code.

### Cách cài đặt Skills

**Cách 1: Thủ công**
```bash
mkdir -p .opencode/skills/ten-skill
# Tạo file SKILL.md với nội dung hướng dẫn
```

**Cách 2: Dùng lệnh npx**
```bash
npx skills add https://github.com/anthropics/skills --skill skill-creator
```

**Cách 3: Qua plugin**
```json
{
  "plugin": ["opencode-skills"]
}
```

### Kho Skills hơn 1300+

Kho Antigravity Awesome Skills chứa hơn **1300+ skill** miễn phí, tự động phát hiện stack công nghệ và chọn skill phù hợp.

```bash
# Cài đặt kho skills
npx @opencode-skills-registry/install
```

### Sử dụng Skills

```bash
# Qua slash command
/refactor
/document

# Qua ngôn ngữ tự nhiên - OpenCode tự chọn skill phù hợp
"Hãy giúp tôi brainstorm ý tưởng thiết kế REST API"
```

---

## 7. MCP Servers - Kết Nối Công Cụ Bên Ngoài

### MCP là gì?

MCP (Model Context Protocol) là giao thức chuẩn giúp OpenCode kết nối và tương tác với các hệ thống bên ngoài. Thay vì chỉ trả lời văn bản, model có thể duyệt web, đọc kho code, tương tác với công cụ thiết kế, và tự động hóa workflow.

### Nguyên lý hoạt động

```
┌────────────┐      ┌────────────────┐      ┌────────────────┐
│   Model    │─────>│  OpenCode      │─────>│   MCP Server   │
│ (Claude /  │      │  MCP Client    │      │ (GitHub /      │
│  GPT /...) │      │  (Quản lý      │      │  Browser /     │
│            │      │   kết nối)     │      │  Figma /...)   │
└────────────┘      └────────────────┘      └────────────────┘
       ^                                          │
       └──────────────────────────────────────────┘
                   Kết quả trả về
```

### Cấu hình Local MCP Server

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "may-chenh-cua-ban": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": {
        "BIEN_MOI_TRUONG": "gia-tri"
      }
    }
  }
}
```

### Cấu hình Remote MCP Server

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    },
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```

### Các MCP Server phổ biến nhất

| Server | Chức năng | Loại |
|--------|-----------|------|
| Playwright | Tự động hóa trình duyệt, testing | Local |
| GitHub | Truy cập repo, quản lý code | Remote |
| Figma | Kiểm tra file thiết kế | Remote |
| n8n | Tự động hóa workflow | Local/Remote |
| Context7 | Tìm kiếm tài liệu | Remote |
| Sentry | Theo dõi lỗi | Remote |

### Quản lý MCP Server

```bash
# Thêm server mới
opencode mcp add

# Kiểm tra lỗi kết nối
opencode mcp debug <ten-server>

# Xác thực OAuth
opencode mcp auth <ten-server>

# Liệt kê tất cả server
opencode mcp list

# Xóa thông tin xác thực
opencode mcp logout <ten-server>
```

### Điều khiển chi tiết MCP Tools

```json
{
  "tools": {
    "github_*": false,
    "slack_*": false
  }
}
```

---

## 8. Commands và Agents

### Slash Commands đầy đủ

| Lệnh | Chức năng | Phím tắt |
|-------|-----------|----------|
| `/init` | Khởi tạo dự án OpenCode | `Ctrl+X I` |
| `/models` | Xem/danh sách/chuyển model | `Ctrl+X M` |
| `/connect` | Kết nối nhà cung cấp model | - |
| `/undo` | Hoàn tác thao tác cuối | `Ctrl+X U` |
| `/redo` | Làm lại thao tác đã hoàn tác | `Ctrl+X R` |
| `/share` | Chia sẻ phiên làm việc | `Ctrl+X S` |
| `/new` | Tạo phiên mới | `Ctrl+X N` |
| `/sessions` | Danh sách các phiên | `Ctrl+X L` |
| `/compact` | Rút gọn context phiên | `Ctrl+X C` |
| `/exit` | Thoát chương trình | `Ctrl+X Q` |

### Terminal Commands

```bash
opencode models              # Liệt kê tất cả model khả dụng
opencode auth login          # Kết nối nhà cung cấp
opencode auth logout         # Xóa thông tin nhà cung cấp
```

### Hai chế độ Agent

| Chế độ | Mô tả | Khi nào dùng |
|--------|-------|---------------|
| **Build** | Toàn quyền: đọc, sửa, tạo file; chạy lệnh terminal | Mặc định, khi cần thực thi |
| **Plan** | Chỉ đọc: phân tích, lên kế hoạch, không thay đổi gì | Bắt đầu task phức tạp |

**Cách chuyển:** Nhấn `Tab` để chuyển giữa Build và Plan.

---

## 9. Sơ Đồ Lưu Đồ Thực Hiện

### Sơ đồ tổng quan hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                      HỆ THỐNG OpenCode                          │
│                                                                 │
│  ┌────────────┐   ┌────────────┐   ┌────────────┐               │
│  │  Terminal  │   │    IDE     │   │  Desktop   │               │
│  │    CLI     │   │ Extension  │   │    App     │               │
│  └─────┬──────┘   └─────┬──────┘   └─────┬──────┘               │
│        │                │                │                      │
│        └────────────────┼────────────────┘                      │
│                         │                                       │
│                         v                                       │
│  ┌───────────────────────────────────────────────────────┐      │
│  │                  OpenCode Core                        │      │
│  │                                                       │      │
│  │  ┌────────────────────────────────────────────┐       │      │
│  │  │           Agentic Loop                     │       │      │
│  │  │   ┌─────────┐  ┌─────────┐  ┌─────────┐    │       │      │
│  │  │   │  Plan   │→ │  Build  │→ │ Verify  │    │       │      │
│  │  │   │  Mode   │  │  Mode   │  │         │    │       │      │
│  │  │   └─────────┘  └─────────┘  └─────────┘    │       │      │
│  │  └────────────────────────────────────────────┘       │      │
│  │                                                       │      │
│  │  ┌────────────┐   ┌────────────┐                      │      │
│  │  │   Skills   │   │   Agents   │                      │      │
│  │  │  (Hướng    │   │  (Plan +   │                      │      │
│  │  │   dẫn)     │   │   Build)   │                      │      │
│  │  └────────────┘   └────────────┘                      │      │
│  └──────────────────────────┬────────────────────────────┘      │
│                             │                                   │
│        ┌────────────────────┼────────────────────┐              │
│        │                    │                    │              │
│        v                    v                    v              │
│  ┌───────────┐      ┌─────────────┐      ┌───────────┐          │
│  │ File I/O  │      │   Shell     │      │    MCP    │          │
│  │ Đọc/Gửa   │      │  Commands   │      │  Servers  │          │
│  │ /Sửa file │      │  Chạy lệnh  │      │  Kết nối  │          │
│  └───────────┘      └─────────────┘      └───────┬───┘          │
│                                                  │              │
│                              ┌───────────────────┼───────┐      │
│                              │                   │       │      │
│                              v                   v       v      │
│                       ┌──────────┐         ┌────────┐ ┌───────┐ │
│                       │  GitHub  │         │ Sentry │ │Figma  │ │
│                       │  repos   │         │ errors │ │design │ │
│                       └──────────┘         └────────┘ └───────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Quy trình phát triển tính năng (Feature Development)

```
┌─────────────────────────────────────────────────────────┐
│            QUY TRÌNH PHÁT TRIỂN TÍNH NĂNG               │
│                                                         │
│  1. YÊU CẦU                                             │
│     │  • Mô tả tính năng cần thực hiện                  │
│     │  • Xác định phạm vi thay đổi                      │
│     v                                                   │
│  2. PLAN MODE (Tab)                                     │
│     │  • Phân tích codebase hiện tại                    │
│     │  • Xác định các file bị ảnh hưởng                 │
│     │  • Lập kế hoạch thực hiện từng bước               │
│     │  • Chọn approach phù hợp                          │
│     v                                                   │
│  3. BUILD MODE (Tab)                                    │
│     │  • Viết code mới / sửa code hiện tại              │
│     │  • Tạo unit test và integration test              │
│     │  • Cập nhật tài liệu                              │
│     │  • Chạy lint và type check                        │
│     v                                                   │
│  4. XÁC NHẬN (VERIFY)                                   │
│     │  • Chạy toàn bộ test suite                        │
│     │  • Kiểm tra type safety                           │
│     │  • Nếu lỗi → quay lại BƯỚC 2                      │
│     v                                                   │
│  5. REVIEW                                              │
│     │  • Người kiểm tra code review                     │
│     │  • Đưa ra phản hồi                                │
│     │  • Agent xử lý phản hồi                           │
│     v                                                   │
│  6. COMMIT                                              │
│     │  • Tạo Git commit với thông điệp mô tả            │
│     │  • Push lên remote                                │
│     v                                                   │
│  7. HOÀN THÀNH                                          │
│     • Tóm tắt những thay đổi đã thực hiện               │
│     • Ghi nhận kiến thức mới vào AGENTS.md              │
└─────────────────────────────────────────────────────────┘
```

---

## 10. So Sánh Với Đối Thủ

### Tổng quan so sánh nhanh

| Tiêu chí | OpenCode | Claude Code | Cursor | Aider |
|-----------|----------|-------------|--------|-------|
| **Giá** | Miễn phí + API costs | $20/tháng (Claude Pro) | $20/tháng (Pro) | Miễn phí + API costs |
| **Mã nguồn mở** | Có (MIT) | Không | Không (VS Code fork) | Có (Apache 2.0) |
| **Đa model** | 75+ providers | Chỉ Claude | Nhiều (nhưng có hạn chế) | Nhiều providers |
| **Giao diện** | Terminal TUI (Bubble Tea) | Terminal CLI | IDE (VS Code fork) | Terminal CLI đơn giản |
| **Model local** | Có (Ollama, vLLM...) | Không | Giới hạn | Có (Ollama, vLLM...) |
| **Tích hợp Git** | Cơ bản | Cơ bản | Visual diffs | **Tốt nhất** (auto-commit) |
| **Hỗ trợ LSP** | Có (tự cấu hình) | Không | Có | Không |
| **Hỗ trợ MCP** | Có | Có | Có | Không |
| **Plugin system** | Có | Không | Có (marketplace) | Không |
| **GitHub Stars** | ~172K | - | - | ~46K |

### So sánh chi tiết theo từng đối thủ

#### OpenCode vs Claude Code

| Khía cạnh | OpenCode | Claude Code |
|-----------|----------|-------------|
| **Giá thành** | Miễn phí tool, chỉ tốn phí API hoặc dùng model local | $20/tháng tối thiểu, $100/tháng cho power user |
| **Linh hoạt model** | Chuyển model tự do giữa Claude, GPT, Gemini, local... | Chỉ dùng được Claude models |
| **Mã nguồn** | Open source, có thể tùy chỉnh toàn bộ | Đóng nguồn, phụ thuộc Anthropic |
| **Cộng đồng** | 172K+ stars, 640+ contributors | Official từ Anthropic |
| **Agent Teams** | Sub-agent song song (đang phát triển) | **Tốt hơn** - Agent Teams đã trưởng thành |
| **Token efficiency** | Tiêu tốn nhiều token hơn (scan toàn bộ project) | **Ít hơn 5.5x** token so với các tool khác |
| **Refactor lớn** | Tốt nhưng cần nhiều token | **Xuất sắc** - best-in-class cho refactor phức tạp |
| **Điểm yếu** | Thiếu official support, phụ thuộc community | Không có model khác, không开源 |

**Khi nào chọn OpenCode:**
- Muốn kiểm soát hoàn toàn model sử dụng
- Cần chạy model local vì lý do bảo mật
- Muốn tool miễn phí và có thể tùy chỉnh
- Thích workflow terminal hơn IDE

**Khi nào chọn Claude Code:**
- Cần hiệu suất refactor phức tạp nhất hiện nay
- Đã có subscription Claude Pro/Max
- Không quan tâm đến model khác ngoài Claude

#### OpenCode vs Cursor

| Khía cạnh | OpenCode | Cursor |
|-----------|----------|--------|
| **Giao diện** | Terminal TUI | IDE đầy đủ (VS Code fork) |
| **Đường cong học tập** | Cao (terminal-based) | **Thấp** (quen thuộc nếu dùng VS Code) |
| **Visual diffs** | Không | **Có** - xem thay đổi trực quan |
| **Inline editing** | Không | **Có** - Cmd+K editing |
| **Tab completion** | Không | **Có** - AI autocomplete |
| **Multi-file editing** | Qua terminal | **Visual** - xem thay đổi trên nhiều file |
| **Chi phí** | $0 + API costs | $20/tháng Pro, $40/tháng Business |
| **1.300+ Skills** | **Có** - kho skills lớn | Không |
| **Phù hợp cho team** | Terminal workflow | **Tốt hơn** - có team features |

**Khi nào chọn OpenCode:**
- Thích terminal workflow
- Muốn miễn phí hoàn toàn
- Cần 1300+ skills
- Đang dùng SSH nhiều

**Khi nào chọn Cursor:**
- Thích giao diện đồ họa
- Đang dùng VS Code
- Cần visual diffs và inline editing
- Team cần unified tooling

#### OpenCode vs Aider

| Khía cạnh | OpenCode | Aider |
|-----------|----------|-------|
| **Giao diện** | TUI phong phú (Bubble Tea) | CLI đơn giản |
| **Git integration** | Cơ bản | **Xuất sắc** - auto-commit mỗi thay đổi |
| **Token efficiency** | Kém hơn (scan toàn bộ) | **Tốt hơn** - repo map nén |
| **LSP Support** | **Có** - tự cấu hình | Không |
| **MCP Support** | **Có** | Không |
| **Plugin system** | **Có** | Không |
| **Session persistence** | **Có** - session sống sót khi mất kết nối | Không |
| **Architect Mode** | Không | **Có** - chia model thành 2 giai đoạn |
| **Chi phí hàng ngày** | $4-7/ngày | **$2-4/ngày** |

**Khi nào chọn OpenCode:**
- Cần LSP support cho TypeScript/complex languages
- Cần MCP integration
- SSH vào máy từ xa thường xuyên
- Cần persistent sessions

**Khi nào chọn Aider:**
- Muốn kiểm soát chi phí API chặt chẽ
- Đề cao lịch sử Git sạch đẹp
- Refactor có hệ thống trên nhiều file
- Team không muốn học TUI phức tạp

### Bảng so sánh theo kiến trúc

```
Mức độ tự chủ tăng dần →

Plugin → Extension  → Fork     → Terminal    → Cloud         → Autonomous
Copilot  Cline       Cursor    Claude Code   Codex App        Devin
         Roo Code    Windsurf  Amp           Jules (Google)   Cascade
         Kilo Code   Zed       OpenCode
                                Aider
```

| Kiến trúc | Vai trò của người dùng | Tool đại diện |
|-----------|------------------------|---------------|
| Plugin | Trợ lý phản ứng | Copilot |
| Extension | Người giám sát agent trong IDE | Cline, Roo Code |
| Fork IDE | Collaborator sâu trong IDE | Cursor, Windsurf, Zed |
| Terminal | Đối tác lý luận trong terminal | **Claude Code, OpenCode, Aider** |
| Cloud | Quản lý worker AI bất đồng bộ | Codex App, Jules |
| Autonomous | Người giám sát AI tự chủ | Devin, Cascade |

### Khuyến nghị kết hợp

Theo kinh nghiệm thực tế từ cộng đồng developer 2026:

| Nhu cầu | Khuyến nghị |
|----------|-------------|
| **Solo developer, tiết kiệm** | OpenCode (miễn phí, linh hoạt) |
| **Startup team** | Cursor Pro (dễ dùng, team features) |
| **Senior engineer, refactor lớn** | Claude Code Max (hiệu suất tốt nhất) |
| **Kết hợp tối ưu** | **Cursor ($20) + Claude Code ($20) = $40/tháng** - bao phủ 90% nhu cầu |
| **Kết hợp free** | OpenCode + Aider - cả hai miễn phí |

---

## 11. Khó Khăn và Giới Hạn

### Vấn đề kỹ thuật thường gặp

#### 1. Hiệu suất Local LLM

- **Vấn đề:** Model local (PC cá nhân) **kém hiệu quả đáng kể khi context lớn**
- **Nguyên nhân:** Khi input context tăng, thời gian suy luận tăng theo cấp số nhân
- **Độ trễ:** Model 8B có thể mất 30-60 giây cho mỗi phản hồi khi context > 32K tokens
- **Giải pháp:** Chỉ dùng local model cho task đơn giản, dùng cloud model cho task phức tạp

#### 2. Chat Template Breaking

- **Vấn đề:** Chat template bị vô hiệu hóa khi sử dụng tool-calling
- **Nguyên nhân:** Không phải model nào cũng hỗ trợ tool-calling đúng cách
- **Ảnh hưởng:** Agent không thể gọi tool, chỉ trả về văn bản thuần
- **Giải pháp:** Chọn model đã được test kỹ với tool-calling: Qwen, Claude, GPT

#### 3. Context Window Limit

- **Vấn đề:** Context window bị đầy khi làm việc với codebase lớn
- **Nguyên nhân:** Mỗi lần gọi tool tiêu tốn thêm context; MCP server thêm 10K+ tokens chỉ để mô tả tool
- **Dấu hiệu:** Phản hồi chậm dần, lỗi "context window exceeded"
- **Giải pháp:** Dùng `/compact` thường xuyên; tắt MCP server không cần thiết

#### 4. GPU Memory Overflow

- **Vấn đề:** Không đủ VRAM cho model lớn
- **Yêu cầu:** Model 7B cần ~6GB VRAM; Model 32B cần 24GB+ VRAM
- **Dấu hiệu:** Chương trình bị crash hoặc chạy rất chậm
- **Giải pháp:** Chọn model phù hợp với phần cứng; dùng quantization (Q4_K_M)

#### 5. Token Cost Spikes

- **Vấn đề:** Chi phí API tăng bất ngờ
- **Nguyên nhân:** OpenCode có thể gửi toàn bộ project context trong một số phiên bản
- **Ví dụ:** Câu hỏi đơn giản "tech stack là gì?" có thể tiêu tốn 13,000+ tokens
- **Giải pháp:** Theo dõi dashboard API; dùng `/compact`; giới hạn `maxFiles`

### Giới hạn hiện tại

- Không có official support từ công ty - phụ thuộc cộng đồng
- Các tính năng Agent Teams chưa trưởng thành bằng Claude Code
- Hiệu quả phụ thuộc hoàn toàn vào LLM được chọn
- Chưa có visual diffs như Cursor
- Một số MCP server thêm quá nhiều token vào context

---

## 12. Những Điều Không Nên Làm

### KHÔNG NÊN bật Auto-Commit

```json
{
  "git": {
    "autoCommit": false  // LUÔN ĐỂ FALSE
  }
}
```

**Lý do:** Agent có thể commit những thay đổi sai, phá vỡ logic hiện có mà bạn không kiểm tra kịp. Mỗi commit cần được review bởi người thật.

### KHÔNG NÊN bỏ qua xác nhận lệnh Shell

```json
{
  "shell": {
    "confirmCommands": true,
    "allowedCommands": ["npm", "yarn", "pnpm", "git", "make"]
  }
}
```

**Lý do:** Agent có thể chạy lệnh nguy hiểm như `rm -rf`, `DROP TABLE`, hoặc các lệnh phá hủy dữ liệu.

### KHÔNG NÊN bật quá nhiều MCP Server

```json
{
  "mcp": {
    "server_a": { "enabled": true },
    "server_b": { "enabled": true },
    "server_c": { "enabled": true },
    "server_d": { "enabled": true }
  }
}
```

**Lý do:** Mỗi MCP server thêm 10K+ tokens vào context chỉ để mô tả tool. Quá nhiều server làm giảm hiệu suất và tăng chi phí.

### KHÔNG NÊN để context tăng không giới hạn

**Lý do:** Token cost tăng theo cấp số nhân, performance giảm nghiêm trọng.

**Giải pháp:** Luôn dùng `/compact` sau mỗi 5-10 lượt hội thoại.

### KHÔNG NÊN dùng local model cho production code

**Lý do:** Chất lượng output thấp hơn đáng kể so với cloud model. Có thể tạo ra bugs tiềm ẩn khó phát hiện.

### KHÔNG NÊN bỏ qua Type Checking

```bash
# LUÔN CHẠY TRƯỚC KHI COMMIT
npm run typecheck
npm run lint
npm test
```

**Lý do:** Code sai type có thể gây bugs nghiêm trọng trong production, rất khó debug.

### KHÔNG NÊN tin tưởng Skills từ nguồn không rõ

**Lý do:** Skills có thể chứa code độc hại, truy cập dữ liệu nhạy cảm, hoặc chạy lệnh nguy hiểm.

**Giải pháp:** Luôn đọc SKILL.md trước khi cài đặt; dùng `excludedRiskLevels` để lọc.

### KHÔNG NÊN bỏ qua Background Sessions

**Lý do:** Agent có thể thay đổi code khi bạn không để ý, đặc biệt nguy hiểm trong phiên chạy dài.

**Giải pháp:** Luôn theo dõi session; tắt auto-mode khi không cần thiết.

---

## 13. Lưu Ý Khi Triển Khai

### Bảo mật

#### 1. Quản lý API Keys

```bash
# LUÔN lưu API key trong biến môi trường, KHÔNG trong code
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
```

#### 2. Cấu hình MCP Server an toàn

```json
{
  "mcp": {
    "server-an-toan": {
      "type": "remote",
      "url": "...",
      "oauth": false,
      "headers": {
        "Authorization": "Bearer {env:MY_API_KEY}"
      }
    }
  }
}
```

#### 3. Bảo mật Skills

- **Luôn kiểm tra SKILL.md** trước khi cài đặt
- **Không cài Skills** từ nguồn không rõ ràng
- Dùng bộ lọc rủi ro:

```json
{
  "excludedRiskLevels": ["offensive"],
  "excludedSkills": ["windows-privilege-escalation"]
}
```

### Hiệu suất

#### 1. Quản lý Context hiệu quả

- Dùng `/compact` khi context quá lớn
- Tắt MCP server không cần thiết
- Giới hạn số file scan:

```json
{
  "context": {
    "maxFiles": 50,
    "ignorePatterns": ["node_modules", ".git", "dist"]
  }
}
```

#### 2. Chiến lược chọn Model

| Loại task | Model khuyến nghị | Lý do |
|-----------|-------------------|-------|
| Task đơn giản | Model 7B (local) | Nhanh, tiết kiệm |
| Task phức tạp | Model 14B-32B | Cần lý luận sâu |
| Production code | Claude/GPT (cloud) | Đảm bảo chất lượng |
| Refactor lớn | Claude Sonnet/Opus | Hiệu quả nhất |

#### 3. Kiểm soát chi phí

- Theo dõi dashboard API thường xuyên
- Dùng model miễn phí cho task đơn giản
- Giới hạn context size và số file

### Workflow hiệu quả nhất

#### 1. Luôn bắt đầu với Plan Mode

```bash
# Bước 1: Chuyển sang Plan Mode (chỉ đọc)
Tab

# Bước 2: Phân tích và lên kế hoạch
"Phân tích codebase và tạo kế hoạch chi tiết cho..."

# Bước 3: Khi đã có kế hoạch, chuyển sang Build Mode
Tab

# Bước 4: Thực hiện theo kế hoạch
```

#### 2. Sử dụng AGENTS.md

```markdown
# AGENTS.md

## Quy tắc
- LUÔN chạy tests trước khi commit
- Dùng TypeScript strict mode
- Tuân theo code style hiện có

## Lệnh thường dùng
- `npm run lint` - Kiểm tra code style
- `npm run typecheck` - Kiểm tra type
- `npm test` - Chạy toàn bộ test
```

#### 3. Version Control đúng cách

```bash
# Luôn tạo branch mới cho mỗi task
git checkout -b feature/ten-tinh-nang

# Chạy OpenCode trên branch này
opencode

# Sau khi hoàn thành, review và merge
```

---

## 14. Giải Pháp Sử Dụng

### Giải pháp 1: Cloud Model (Khuyến nghị cho chất lượng)

```json
{
  "model": "anthropic/claude-sonnet-4-5"
}
```

| Ưu điểm | Nhược điểm |
|----------|------------|
| Chất lượng cao nhất | Cần API key, tốn phí |
| Nhanh, ổn định | Phụ thuộc internet |
| Ít lỗi nhất | Dữ liệu gửi lên cloud |

### Giải pháp 2: Local Model (Tốt nhất cho bảo mật)

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": { "name": "Qwen3:8b" }
      }
    }
  }
}
```

| Ưu điểm | Nhược điểm |
|----------|------------|
| Miễn phí hoàn toàn | Yêu cầu phần cứng mạnh |
| Bảo mật tuyệt đối | Chất lượng thấp hơn cloud |
| Không cần internet | Kém khi context lớn |

### Giải pháp 3: Hybrid (Cân bằng tốt nhất)

```json
{
  "provider": {
    "fast": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "qwen3:8b": { "name": "Fast Local" } }
    },
    "quality": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "qwen2.5-coder:32b": { "name": "Quality Local" } }
    },
    "cloud": {
      "type": "anthropic",
      "models": { "claude-sonnet-4-5": { "name": "Claude Sonnet" } }
    }
  }
}
```

| Ưu điểm | Nhược điểm |
|----------|------------|
| Linh hoạt, chuyển model theo task | Phức tạp hơn khi cấu hình |
| Cân bằng chi phí/chất lượng | Cần quản lý nhiều model |

### Giải pháp 4: LiteLLM Proxy (Cho doanh nghiệp)

```bash
# Chạy LiteLLM server
litellm --model ollama/qwen3:8b --port 4000

# Cấu hình OpenCode kết nối
opencode -m litellm/qwen-coder-fast
```

| Ưu điểm | Nhược điểm |
|----------|------------|
| Quản lý nhiều model集中 | Cấu hình phức tạp |
| Load balancing tự động | Cần server proxy riêng |
| Theo dõi usage chi tiết | Chi phí hạ tầng bổ sung |

### Giải pháp 5: Kết hợp nhiều tool (Hiệu quả nhất theo thực tế)

- **OpenCode** cho task khám phá, research codebase
- **Aider** cho refactor có hệ thống với Git history sạch
- **Cursor** (nếu có) cho visual editing hàng ngày

---

## 15. Tài Liệu Tham Khảo

### Official

- OpenCode Docs: https://opencode.ai/docs
- GitHub: https://github.com/anomalyco/opencode
- MCP Protocol: https://modelcontextprotocol.io

### Video hướng dẫn

1. Configuring OpenCode for a Local LLM: https://www.youtube.com/watch?v=95Gc8-kuUxE
2. OpenCode Full Tutorial: https://www.youtube.com/watch?v=0xKE1UHpSfk
3. Top 5 OpenCode Skills: https://www.youtube.com/watch?v=iYpHOxgZjUE
4. Supercharge OpenCode With 1300+ Free Skills: https://www.youtube.com/watch?v=baGKgnbQUq8
5. OpenCode MCP Servers: https://www.youtube.com/watch?v=nUCwPxMgz_8

### So sánh & Đánh giá

- OpenCode vs Claude Code vs Cursor: https://saasmaster.net/blog/opencode-vs-claude-code-vs-cursor-ai-agents-2026
- OpenCode vs Aider: https://tech.breakingcube.com/2026/03/24/opencode-vs-aider-ai-coding-agent-comparison
- AI Coding Agents 2026: https://codersera.com/blog/ai-coding-agents-complete-guide-2026/

### Skills Resources

- Awesome OpenCode Skills: https://github.com/TheArchitectit/awesome-opencode-skills
- Anthropic Skills: https://github.com/anthropics/skills
- Agent Skills Plugin: https://github.com/joshuadavidthomas/opencode-agent-skills

### MCP Resources

- Official MCP Servers: https://github.com/modelcontextprotocol/servers
- MCP Registry: https://registry.modelcontextprotocol.io/
- Context7: https://context7.com

---

> **Lưu ý:** Document này được tổng hợp từ nhiều nguồn tham khảo khác nhau. Mỗi trường hợp cụ thể có thể cần cấu hình khác nhau tùy theo phần cứng, yêu cầu, và mục tiêu sử dụng. Luôn kiểm tra tài liệu chính thức tại opencode.ai/docs để có thông tin mới nhất.
