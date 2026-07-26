# OpenCode - Hướng Dẫn Sử Dụng Đầy Đủ

> **Nguồn tham khảo**: Video YouTube "OpenCode Full Tutorial: Free Models, Skills & MCPs" (07/2026), tài liệu chính thức opencode.ai, và các nguồn so sánh từ computingforgeeks, nxcode, trendscan, zbuild, v.v.

---

## 1. Tổng Quan

**OpenCode** là một công cụ AI coding agent mã nguồn mở (open-source) chạy trên terminal, được phát triển bởi **Anomaly** và hiện đang được tiếp tục phát triển bởi **Charmbracelet** (Go-based CLI). OpenCode hỗ trợ hơn **75+ nhà cung cấp LLM** thông qua một giao diện duy nhất, cho phép các nhà phát triển tương tác với AI trực tiếp từ terminal để viết code, debug, refactor, và tự động hóa quy trình lập trình.

### Các Hình Thức Sử Dụng
| Hình thức | Mô tả |
|---|---|
| **Terminal TUI** | Giao diện terminal tương tác (Bubble Tea framework) |
| **CLI** | Lệnh dòng cho scripting và tự động hóa |
| **Web/Server** | Giao diện web qua `opencode serve` |
| **IDE Extension** | Plugin cho VS Code, Neovim, v.v. |

---

## 2. Các Mục Chính

### 2.1 Cài Đặt

```bash
# Cách nhanh nhất (curl)
curl -fsSL https://opencode.ai/install | bash

# npm
npm install -g opencode-ai

# Homebrew (macOS/Linux)
brew install anomalyco/tap/opencode

# Windows
choco install opencode
scoop install opencode

# Arch Linux
sudo pacman -S opencode

# Docker
docker run -it --rm ghcr.io/anomalyco/opencode
```

**Yêu cầu**: Terminal hiện đại (WezTerm, Alacritty, Ghostty, Kitty). Trên Windows nên dùng **WSL** để có hiệu suất tốt nhất.

### 2.2 Cấu Hình Provider

OpenCode hỗ trợ nhiều nhà cung cấp LLM:

| Nhà cung cấp | Ví dụ model | Chi phí |
|---|---|---|
| **OpenCode Zen** (tích hợp sẵn) | `opencode/big-pickle`, `opencode/grok-code` | Miễn phí (có giới hạn quota/IP) |
| **Anthropic** | `anthropic/claude-sonnet-4-20250514` | Trả phí theo API key |
| **Google** | `google/gemini-2.5-pro` | Trả phí theo API key |
| **OpenAI** | `openai/gpt-4o` | Trả phí theo API key |
| **Google Vertex AI** | `google-vertex/gemini-2.5-pro` | Trả phí theo API key |
| **Ollama (local)** | Model cục bộ | Miễn phí hoàn toàn |
| **AWS Bedrock** | Claude qua AWS | Trả phí theo AWS |
| **Azure OpenAI** | GPT-4o qua Azure | Trả phí theo Azure |
| **Groq** | Model trên Groq | Có tier miễn phí |
| **OpenRouter** | Đa model | Trả phí theo API |

**Cấu hình cơ bản** (`opencode.json`):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

**Đăng nhập OpenCode Zen** (tích hợp sẵn miễn phí):
```
/connect  →  Chọn opencode  →  Truy cập opencode.ai/auth  →  Nhập API key
```

### 2.3 Khởi Tạo Dự Án

```bash
cd /path/to/project
opencode
/init    # Tạo file AGENTS.md mô tả dự án
```

File `AGENTS.md` nên được commit vào Git để OpenCode hiểu cấu trúc dự án.

### 2.4 Sử Dụng Cơ Bản

| Thao tác | Cách thực hiện |
|---|---|
| Hỏi về code | `How is authentication handled in @packages/functions/src/api/index.ts` |
| Thêm tính năng | Chuyển sang **Plan mode** (Tab) → Mô tả yêu cầu → Kiểm duyệt plan → Chuyển sang **Build mode** (Tab) |
| Sửa đổi trực tiếp | `We need to add authentication to the /settings route...` |
| Hoàn tác | `/undo` (có thể chạy nhiều lần) |
| Làm lại | `/redo` |
| Chia sẻ cuộc trò chuyện | `/share` |

### 2.5 Agent Skills (Kỹ Năng Agent)

Skills là các hướng dẫn có thể tái sử dụng được định nghĩa qua file `SKILL.md`.

**Vị trí tìm kiếm**:
- `.opencode/skills/<tên>/SKILL.md` (dự án)
- `~/.config/opencode/skills/<tên>/SKILL.md` (toàn cục)
- `.claude/skills/<tên>/SKILL.md` (tương thích Claude)

**Cấu trúc SKILL.md**:
```yaml
---
name: git-release
description: Tạo release và changelog nhất quán
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
---

## Tôi làm gì
- Draft release notes từ merged PR
- Đề xuất version bump

## Khi nào sử dụng
Dùng khi chuẩn bị release có tag.
```

**Quy tắc đặt tên skill**:
- 1-64 ký tự, chữ thường + số, phân tách bằng dấu gạch ngang đơn
- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

**Quyền hạn skill** (`opencode.json`):
```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

### 2.6 MCP Servers (Model Context Protocol)

MCP cho phép OpenCode kết nối với các công cụ bên ngoài thông qua giao thức chuẩn.

**Các loại MCP server phổ biến**:
- **Playwright MCP** - Tự động hóa trình duyệt
- **GitHub MCP** - Truy cập repository
- **Figma MCP** - Kiểm tra file thiết kế
- **Filesystem MCP** - Đọc/ghi file
- **Brave Search / Tavily Search** - Tìm kiếm web
- **Postgres** - Kết nối database
- **Context7** - Tài liệu framework

**Cấu hình MCP**:
```json
{
  "mcp": {
    "filesystem": { "enabled": true },
    "github": { "enabled": true },
    "playwright": { "enabled": true }
  }
}
```

**Lệnh quản lý**:
```bash
opencode mcp add        # Thêm server tương tác
opencode mcp list       # Danh sách server
```

### 2.7 Agent (Tác Tử)

OpenCode có 3 agent mặc định:
- **build** (primary): Agent chính, full quyền truy cập tool
- **compaction** (primary): Tóm tắt và nén session dài
- **explore** (subagent): Chỉ đọc, dùng để khám phá code

**Tạo agent tùy chỉnh**:
```bash
opencode agent create \
  --description "review terraform plans for safety" \
  --mode primary \
  --permissions "bash,read,grep,glob,webfetch,task"
```

### 2.8 Lệnh CLI Quan Trọng

| Lệnh | Mô tả |
|---|---|
| `opencode` | Khởi chạy TUI |
| `opencode run "prompt"` | Chạy prompt non-interactive |
| `opencode agent list/list` | Quản lý agent |
| `opencode session list/delete` | Quản lý session |
| `opencode stats` | Thống kê token và chi phí |
| `opencode export` | Xuất cuộc trò chuyện |
| `opencode pr <số>` | Checkout và chạy OpenCode trên PR |
| `opencode db path` | Đường dẫn database |
| `opencode debug config` | Xem cấu hình đã merge |
| `opencode upgrade` | Cập nhật phiên bản |
| `opencode uninstall` | Gỡ cài đặt |

### 2.9 Biến Môi Trường Quan Trọng

| Biến | Mục đích |
|---|---|
| `OPENCODE_CONFIG` | Đường dẫn cấu hình tùy chỉnh |
| `GOOGLE_CLOUD_PROJECT` | GCP project cho Vertex AI |
| `GOOGLE_APPLICATION_CREDENTIALS` | Đường dẫn service account JSON |
| `VERTEX_LOCATION` | Vùng Vertex AI |
| `OPENCODE_EXPERIMENTAL` | Bật tất cả tính năng thử nghiệm |
| `OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS` | Timeout mặc định cho bash |
| `OPENCODE_EXPERIMENTAL_PLAN_MODE` | Bật plan mode |

---

## 3. Sơ Đồ Lưu Đồ Thực Hiện

```
┌─────────────────────────────────────────────────────────┐
│                    NGƯỜI DÙNG                           │
│           (Terminal / TUI / Web / IDE)                  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              OPENCODE TUI / CLI                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Giao diện tương tác (Bubble Tea Framework)     │    │
│  │  - Chat mode (viết code trực tiếp)              │    │
│  │  - Plan mode (phân tích + lên kế hoạch)         │    │
│  │  - Session management                           │    │
│  └─────────────────────────────────────────────────┘    │
└──────────┬────────────┬────────────┬────────────────────┘
           │            │            │
           ▼            ▼            ▼
┌───────────────┐ ┌──────────────┐ ┌──────────────────────┐
│LLM PROVIDER   │ │   SKILLS     │ │   MCP SERVERS        │
│(75+ providers)│ │ (SKILL.md)   │ │ (Model Context       │
│ - OpenCode Zen│ │ - Tái sử dụng│ │  Protocol)           │
│  - Anthropic  │ │ - Workflow   │ │ - Playwright         │
│  - Google     │ │ - Quy tắc    │ │ - GitHub             │
│  - OpenAI     │ │ - Command    │ │ - Filesystem         │
│  - Ollama     │ │              │ │ - Brave/Tavily       │
│  - Groq       │ │              │ │ - Postgres           │
│  - Vertex AI  │ │              │ │ - Figma              │
└──────┬────────┘ └──────┬───────┘ └──────────┬───────────┘
       │                 │                    │
       ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────┐
│                  QUY TRÌNH THỰC HIỆN                    │
│                                                         │
│  1. User nhập yêu cầu (text/image)                      │
│  2. Agent phân tích và chọn skill phù hợp (nếu có)      │
│  3. Agent gọi LLM để lên kế hoạch / viết code           │
│  4. Agent gọi MCP tools nếu cần tương tác bên ngoài     │
│  5. Agent thực hiện thay đổi file                       │
│  6. User duyệt / undo / redo                            │
│  7. Session được lưu vào SQLite DB                      │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Quy Trình Cơ Chế Và Giải Pháp Sử Dụng

### 4.1 Quy Trình Plan → Build

```
┌──────────────┐    ┌──────────────────┐    ┌────────────────┐
│   PLAN MODE  │──▶ │  ITERATE PLAN   │───▶│   BUILD MODE   │
│  (Tab key)   │    │  (phản hồi/thêm  │    │  (Tab key)     │
│              │    │   chi tiết)      │    │                │
└──────────────┘    └──────────────────┘    └────────────────┘
       │                    │                       │
       ▼                    ▼                       ▼
  Agent phân tích     User feedback          Agent thực thi
  + đưa ra plan       + bổ sung context      thay đổi file
```

### 4.2 Quy Trình Skill Discovery

```
┌─────────────────────┐
│ User nhập yêu cầu   │
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ Agent kiểm tra      │
│ available_skills    │
└──────────┬──────────┘
           ▼
    ┌──────┴──────┐
    │ Có skill    │
    │ phù hợp?    │
    └──────┬──────┘
      Yes  │  No
      │---------│
      ▼         ▼
┌──────────┐ ┌──────────────────┐
│ Load     │ │ Thực hiện trực   │
│ SKILL.md │ │ tiếp bằng LLM    │
└────┬─────┘ └──────────────────┘
     │
     ▼
┌──────────────────┐
│ Thực hiện theo   │
│ workflow trong   │
│ SKILL.md         │
└──────────────────┘
```

### 4.3 Giải Pháp Cho Các Trường Hợp Thường Gặp

| Tình huống | Giải pháp |
|---|---|
| **Code mới từ đầu** | Plan mode → Mô tả chi tiết → Build mode |
| **Fix bug** | Mô tả lỗi + file liên quan (dùng `@` để chọn file) |
| **Refactor** | Yêu cầu refactor + chỉ rõ logic hiện tại cần tham khảo |
| **Code review** | Dùng skill `code-review` hoặc mô tả yêu cầu review |
| **Tự động hóa CI/CD** | `opencode run "prompt"` trong script |
| **Phân tích codebase lớn** | Dùng `explore` agent (subagent) để đọc trước |

---

## 5. Điểm Lưu Ý

### 5.1 Khó Khăn Thường Gặp

| Khó khăn | Mô tả | Giải pháp |
|---|---|---|
| **Token rate limiting** | API bị throttle khi gọi liên tục | Stagger các parallel calls, dùng retry logic |
| **Context window** | Codebase lớn vượt quá context | Dùng `explore` agent + compact session (`/compact`) |
| **MCP server không phản hồi** | Server bị timeout hoặc crash | Kiểm tra `opencode mcp list`, restart server |
| **Skill không load** | File sai tên hoặc thiếu frontmatter | Kiểm tra: `SKILL.md` phải HOA, có `name` + `description` |
| **Model không hiểu project** | Thiếu context | Tạo `AGENTS.md` tốt, dùng `@` để chỉ file cụ thể |
| **Windows compatibility** | Một số feature không hoạt động đầy đủ | Dùng **WSL** thay vì terminal Windows gốc |
| **AVX support** | Một số VM không hỗ trợ AVX → crash | Đổi CPU type thành `host` hoặc dùng VPS có AVX2 |

### 5.2 Những Điều Không Nên / Không Cho Phép

| Không nên | Lý do |
|---|---|
| **Không commit API keys vào Git** | Bảo mật tuyệt đối, dùng env vars |
| **Không chạy `opencode` trên production server** | Chỉ dùng cho development |
| **Không để agent chạy tự do không giám sát** | Luôn review changes trước khi commit |
| **Không dùng free tier cho production** | Free tier bị throttle, nên dùng paid API |
| **Không tắt permission system** | Luôn giữ quyền hạn tối thiểu cần thiết |
| **Không dùng model không verify** | Chọn model đã test từ OpenCode Zen hoặc danh sách verified |
| **Không share AGENTS.md chứa secrets** | File này nên commit nhưng không chứa sensitive info |

### 5.3 Lưu Ý Khi Triển Khai

1. **AGENTS.md**: Luôn commit file này, nhưng KHÔNG chứa secrets
2. **opencode.json**: Dùng project-level config (không dùng global cho production)
3. **MCP servers**: Test connectivity trước khi dùng production
4. **Skills**: Đặt tên đúng quy tắc, viết description rõ ràng cho agent
5. **Permissions**: Luôn set permission tối thiểu cần thiết, không dùng `"*": "allow"` trong production
6. **Backup**: Dùng Git để backup mọi thay đổi trước khi dùng OpenCode
7. **Team**: Dùng `/share` để chia sẻ cuộc trò chuyện với team
8. **Cost tracking**: Dùng `opencode stats` để theo dõi chi phí token

---

## 6. So Sánh Với Đối Thủ

### 6.1 Bảng So Sánh Tổng Quan (2026)

| Tính năng | OpenCode | Claude Code | Cursor | GitHub Copilot |
|---|---|---|---|---|
| **Giá** | **Miễn phí** (+ API costs) | $20/tháng | $20/tháng | $10/tháng |
| **Loại** | Terminal TUI | Terminal CLI | IDE (VS Code fork) | Extension |
| **Mã nguồn** | ✅ Open source | ❌ Đóng | ❌ Đóng | ❌ Đóng |
| **Stars GitHub** | 172K+ | N/A | N/A | N/A |
| **Nhà cung cấp LLM** | 75+ providers | Anthropic only | Đa provider | OpenAI only |
| **Model miễn phí** | ✅ (OpenCode Zen) | ❌ | ❌ | ❌ |
| **MCP Support** | ✅ | ✅ | ❌ | ❌ |
| **Agent Skills** | ✅ | ✅ (CLAUDE.md) | ❌ | ❌ |
| **Plan/Build mode** | ✅ | ✅ | ❌ | ❌ |
| **Tự động hóa** | ✅ `run` command | ✅ `-p` flag | Hạn chế | Hạn chế |
| **Local models** | ✅ (Ollama) | ❌ | ❌ | ❌ |
| **Self-hosted** | ✅ | ❌ | ❌ | ❌ |
| **Privacy** | ✅ Code local | ⚠️ Code upload | ⚠️ Code upload | ⚠️ Code upload |

### 6.2 Hiệu Suất Thực Tế

| Metric | OpenCode | Claude Code | Cursor |
|---|---|---|---|
| **Token/task (benchmark)** | Tùy model | ~33,000 | ~181,000 |
| **Error rate** | Tùy model | 0 errors | Cao hơn |
| **Token efficiency** | Tùy provider | **5.5x hiệu quả hơn** | Baseline |
| **SWE-bench score** | Tùy model | 88.6% | N/A |
| **Tốc độ (task đơn giản)** | **Nhanh nhất** | Trung bình | Chậm hơn |
| **Multi-file refactor** | Terminal | Terminal | **Visual diffs tốt nhất** |

### 6.3 Ai Nên Dùng Gì?

| Loại developer | Công cụ phù hợp | Lý do |
|---|---|---|
| **Solo developer** | OpenCode | Miễn phí + linh hoạt + 75+ models |
| **Startup team** | Cursor | Dễ dùng + team features |
| **Senior engineer** | Claude Code | Complex reasoning + efficiency |
| **Budget-conscious** | OpenCode + Ollama | Hoàn toàn miễn phí |
| **Frontend developer** | Cursor | Visual diff + inline annotations |
| **DevOps** | OpenCode + Claude Code | Terminal-native + tự động hóa |
| **Hybrid workflow** | Cursor + Claude Code | Best of both worlds ($40/tháng) |

---

## 7. Tối Ưu Theo Mô Hình Cụ Thể

### 7.1 Với Anthropic Claude (Sonnet/Opus)

```json
{
  "model": "anthropic/claude-sonnet-4-20250514",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

- **Tối ưu**: Token efficiency cao nhất (5.5x hơn Cursor), lý tưởng cho complex refactoring
- **Lưu ý**: Chi phí token có thể thấp hơn subscription $20/tháng nếu dùng vừa phải
- **Best for**: Code review, multi-file refactor, debugging phức tạp

### 7.2 Với Google Gemini

```json
{
  "model": "google/gemini-2.5-pro"
}
```

- **Tối ưu**: Context window lớn, xử lý codebase lớn
- **Lưu ý**: Có thể chậm hơn Claude trên task đơn giản
- **Best for**: Phân tích codebase lớn, hiểu hệ thống phức tạp

### 7.3 Với OpenCode Free Tier

```json
{
  "model": "opencode/grok-code"
}
```

- **Tối ưu**: Miễn phí hoàn toàn, không cần API key
- **Lưu ý**: Quota bị throttle theo IP, không phù hợp production
- **Best for**: Learning, thử nghiệm, task đơn giản

### 7.4 Với Ollama (Local)

```json
{
  "model": "ollama/deepseek-coder",
  "ollama": {
    "api": "http://localhost:11434"
  }
}
```

- **Tối ưu**: Miễn phí, privacy tuyệt đối, offline
- **Lưu ý**: Cần máy đủ mạnh (RAM 16GB+), model kém hơn cloud
- **Best for**: Privacy-sensitive, learning, development offline

### 7.5 Tối Ưu Chi Phí

| Chiến lược | Chi phí/tháng | Hiệu quả |
|---|---|---|
| **Free all** (OpenCode Zen + Ollama) | $0 | Thấp - trung bình |
| **Budget** (OpenCode + API key) | $5-20 | Trung bình - cao |
| **Pro** (Claude Code hoặc Cursor) | $20 | Cao |
| **Hybrid** (Cursor + Claude Code) | $40 | Cao nhất |

---

## 8. Bảng Lệnh Nhanh

```
/opencode          # Khởi chạy TUI
/init              # Khởi tạo AGENTS.md
/connect           # Kết nối provider
/undo              # Hoàn tác thay đổi
/redo              # Làm lại
/compact           # Nén session dài
/share             # Chia sẻ cuộc trò chuyện
/model             # Đổi model
/quit              # Thoát
Tab                # Chuyển Plan/Build mode
@                  # Fuzzy search file
```

---

## 9. Kết Luận

OpenCode là lựa chọn tối ưu cho developers muốn:
- **Miễn phí hoặc chi phí thấp** với 75+ providers và free tier
- **Mã nguồn mở** với cộng đồng lớn (172K+ GitHub stars)
- **Linh hoạt** với MCP servers và Agent Skills
- **Terminal-native** cho scripting và tự động hóa
- **Privacy** với local model support (Ollama)

Nhược điểm: Learning curve cao hơn Cursor, không có visual diff, phụ thuộc vào chất lượng model được chọn.

**Chiến lược tốt nhất**: Kết hợp OpenCode (free/linh hoạt) với Cursor (visual) hoặc Claude Code (reasoning) tùy theo nhu cầu cụ thể.

---

*Tài liệu này được tạo ngày 26/07/2026, dựa trên thông tin mới nhất từ opencode.ai và các nguồn so sánh.*
