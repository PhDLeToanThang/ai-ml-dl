# CLAUDE CODE - TỔNG QUAN A-Z

> Nguồn tham khảo: [Claude Code Full Course A-Z](https://www.youtube.com/watch?v=rLNXWIAONo0) + Tài liệu chính thức Anthropic  
> Cập nhật: Tháng 7, 2026

---

## MỤC LỤC

1. [Claude Code là gì?](#1-claude-code-là-gì)
2. [Cơ chế hoạt động - Lưu đồ](#2-cơ-chế-hoạt-động)
3. [Cài đặt & Cấu hình](#3-cài-đặt--cấu-hình)
4. [Các lệnh & Phím tắt](#4-các-lệnh--phím-tắt)
5. [Quy trình làm việc hàng ngày](#5-quy-trình-làm-việc-hàng-ngày)
6. [Tính năng nâng cao](#6-tính-năng-nâng-cao)
7. [Bảo mật & Quyền truy cập](#7-bảo-mật--quyền-truy-cập)
8. [Khó khăn thường gặp & Không nên làm](#8-khó-khăn-thường-gặp--không-nên-làm)
9. [Giải pháp sử dụng hiệu quả](#9-giải-pháp-sử-dụng-hiệu-quả)
10. [Lưu ý khi triển khai](#10-lưu-ý-khi-triển-khai)
11. [So sánh với đối thủ](#11-so-sánh-với-đối-thủ)

---

## 1. Claude Code là gì?

Claude Code là **công cụ lập trình AI dạng agent** của Anthropic, chạy trực tiếp trong terminal. Không phải autocompletion hay snippet suggestion — đây là **workflow partner** đọc toàn bộ codebase, chỉnh sửa file, chạy lệnh terminal, quản lý Git, và thực thi đa bước tự động qua ngôn ngữ tự nhiên.

### Đặc điểm chính

| Đặc điểm | Chi tiết |
|-----------|----------|
| **Môi trường** | Terminal + IDE + Web + Mobile |
| **Khả năng** | Đọc file, sửa code, chạy lệnh, tạo commit, tạo PR |
| **Model** | Claude Sonnet 4.6 / Opus 4.6 / Opus 4.7 / 4.8 |
| **Giá** | Pro ($20/tháng), Max ($100-200/tháng), Team, Enterprise |
| **Yêu cầu** | Node.js 18+, API key hoặc subscription Claude |

---

## 2. Cơ chế hoạt động

### Sơ đồ lưu đồ (Flowchart)

```
┌─────────────────────────────────────────────────────────────────┐
│                    NGƯỜI DÙNG (Terminal)                        │
│  "Thêm dark mode toggle cho app"                                │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────────────┐
│              CLAUDE CODE AGENT ENGINE                         │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐    │
│  │ 1. PHÂN TÍCH │  │ 2. LÊN KẾ    │  │ 3. THỰC HIỆN      │    │
│  │    YÊU CẦU   │──│    HOẠCH     │──│    TỪNG BƯỚC      │    │
│  │              │  │              │  │                   │    │
│  │ • Đọc CLAUDE │  │ • Chia task  │  │ • Edit file       │    │
│  │   .md        │  │ • Xác định   │  │ • Run bash cmd    │    │
│  │ • Quét code- │  │   file ảnh   │  │ • Git commit      │    │
│  │   base       │  │   hưởng      │  │ • Create PR       │    │
│  │ • Hiểu ngữ   │  │ • Đánh giá   │  │                   │    │
│  │   cảnh       │  │   rủi ro     │  │                   │    │
│  └──────────────┘  └──────────────┘  └───────────────────┘    │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 4. XÁC THỰC / DUYỆT                                      │ │
│  │ • Hiển thị diff trước khi áp dụng                        │ │
│  │ • Yêu cầu user approve nếu là lệnh nguy hiểm             │ │
│  │ • Kiểm tra permission theo settings.json                 │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 5. KIỂM TRA & BÁO CÁO                                    │ │
│  │ • Chạy tests nếu có                                      │ │
│  │ • Lint / Type check                                      │ │
│  │ • Hiển thị kết quả cho user                              │ │
│  └──────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CÔNG CỤ HỖ TRỢ                               │
│  • CLAUDE.md (config project)   • MCP Servers (mở rộng)         │
│  • Skills (plugin)              • Hooks (tự động hóa)           │
│  • Subagents (đa agent)         • Git Worktrees (song song)     │
└─────────────────────────────────────────────────────────────────┘
```

### Quy trình cơ chế chi tiết

```
Bước 1: Khởi tạo Session
    │
    ├── Đọc CLAUDE.md (nếu có)
    ├── Quét cấu trúc project (glob, grep)
    └── Xác định ngôn ngữ framework
    │
Bước 2: Phân tích yêu cầu
    │
    ├── Parse ngôn ngữ tự nhiên
    ├── Map sang thao tác kỹ thuật
    └── Xác định scope thay đổi
    │
Bước 3: Lên kế hoạch (Plan Mode)
    │
    ├── Liệt kê file cần sửa
    ├── Đánh giá dependencies
    ├── Đánh giá rủi ro
    └── Trình bày kế hoạch cho user
    │
Bước 4: Thực thi (Edit/Write/Bash)
    │
    ├── Đọc file gốc (Read before Edit)
    ├── Tạo diff
    ├── User approve → Áp dụng thay đổi
    └── Chạy lệnh liên quan
    │
Bước 5: Kiểm tra
    │
    ├── Chạy tests
    ├── Lint / Type check
    └── Báo cáo kết quả
```

---

## 3. Cài đặt & Cấu hình

### Cài đặt

```bash
# Cài đặt toàn cục
npm install -g @anthropic-ai/claude-code

# Kiểm tra phiên bản
claude --version

# Khởi chạy
cd my-project
claude
```

### Cập nhật

```bash
# npm
npm update -g @anthropic-ai/claude-code

# WinGet (Windows)
winget upgrade Anthropic.ClaudeCode

# Homebrew (macOS/Linux)
brew upgrade claude-code
```

### CLAUDE.md - File cấu hình quan trọng nhất

```markdown
# CLAUDE.md - Project Configuration

## Tech Stack
- Framework: Next.js 14 + TypeScript
- ORM: Prisma
- Testing: Vitest

## Code Style
- Functional components, hooks
- 2-space indent
- Avoid comments unless asked

## Git
- Conventional commits: feat(), fix(), refactor()
- Always create new branch for features

## Rules
- Run lint before committing
- Never commit secrets
- Use existing libraries (check package.json first)
```

> **CLAUDE.md quyết định chất lượng output.** 
Không có CLAUDE.md → Claude phỏng đoán. Có CLAUDE.md → Claude tuân thủ đúng chuẩn từ đầu.

---

## 4. Các lệnh & Phím tắt

### Chế độ khởi chạy

```bash
claude                    # Interactive mode
claude "task"             # Quick task (non-interactive)
claude --print "task"     # Print mode (output to stdout)
claude -p "task"          # Shorthand print mode
```

### Slash Commands quan trọng

| Command | Mục đích |
|---------|----------|
| `/init` | Tạo CLAUDE.md mẫu cho project |
| `/help` | Hiển thị trợ giúp |
| `/clear` | Xóa context session hiện tại |
| `/compact` | Tóm tắt conversation (tiết kiệm token) |
| `/cost` | Hiển thị chi phí session hiện tại |
| `/doctor` | Kiểm tra health hệ thống |
| `/memory` | Chỉnh sửa CLAUDE.md |
| `/plan` | Chuyển sang Plan Mode (chỉ đọc) |
| `/review` | Code review file/thay đổi |
| `/mcp` | Quản lý MCP servers |
| `/diff` | Xem diff của thay đổi chưa commit |
| `/teleport` | Chuyển session từ web sang terminal |
| `/desktop` | Mở trong Claude Desktop app |

### Phím tắt

| Phím | Chức năng |
|------|-----------|
| `Enter` | Gửi tin nhắn |
| `Shift+Enter` | Xuống dòng (multi-line) |
| `Escape` | Hủy task đang chạy |
| `?` | Hiển thị tất cả phím tắt |
| `Ctrl+C` | Thoát session |

---

## 5. Quy trình làm việc hàng ngày

### Workflow 1: Tạo code mới

```bash
# Mô tả yêu cầu chi tiết
> Tạo API endpoint POST /api/users với validation bằng zod,
> Prisma ORM, và error handling chuẩn. Trả về 201 với user object.
```

### Workflow 2: Debug lỗi

```bash
# Mô tả lỗi cụ thể
> Users đang report rằng dashboard load 15 giây.
> Kiểm tra API calls trên trang dashboard và tìm bottleneck.
```

### Workflow 3: Refactor code

```bash
# Chỉ rõ phạm vi
> Refactor file src/services/auth.ts sang functional pattern.
> Giữ nguyên interface. Chạy tests sau khi refactor.
```

### Workflow 4: Viết tests

```bash
> Viết unit tests cho hàm calculateTotal() trong src/utils/math.ts.
> Test edge cases: empty array, negative numbers, overflow.
```

### Workflow 5: Git & PR

```bash
> Tạo feature branch, commit thay đổi với message "feat: add user validation",
> và tạo pull request với mô tả chi tiết.
```

### Workflow 6: Code Review

```bash
/review src/api/endpoint.ts
# Hoặc review toàn bộ thay đổi chưa commit
/review
```

---

## 6. Tính năng nâng cao

### Plan Mode - Phân tích trước khi code

```
/plan
> Phân tích database schema và gợi ý tối ưu hóa
```

- **Chỉ đọc** — không edit file, không chạy lệnh
- Phù hợp: architecture review, security audit, performance analysis

### MCP (Model Context Protocol) - Mở rộng khả năng

Kết nối Claude với các công cụ bên ngoài:
- GitHub API (quản lý PR, issues)
- Database (query trực tiếp)
- Slack (giao tiếp team)
- Jira, Linear (quản lý task)
- Custom MCP server

### Subagents - Đa agent song song

Phân task lớn thành nhiều sub-agent chạy song song:
- Agent A: Viết backend API
- Agent B: Tạo frontend components
- Agent C: Viết tests

### Git Worktrees - Làm việc song song

Tạo nhiều worktree để làm nhiều feature cùng lúc mà không conflict:

```bash
# Claude tự động manage worktrees
EnterWorktree → Chuyển giữa các worktrees trong cùng session
```

### Headless Mode - CI/CD Integration

```bash
# Chạy trong pipeline
claude --print "Review PR #123 for security vulnerabilities"
claude -p "Run all tests and report failures"
```

### Hooks - Tự động hóa

```json
// settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "echo 'Running bash command...'"
      }
    ]
  }
}
```

### Extended Thinking Mode

Kích hoạt suy nghĩ sâu hơn cho các task phức tạp:
- Phân tích architecture
- Debug logic phức tạp
- Đánh giá trade-offs

### Remote Control - Đa thiết bị

```
1. Bắt đầu task trên claude.ai/code (web/mobile)
2. Gõ /teleport trong terminal
3. Session chuyển sang terminal với full context
```

---

## 7. Bảo mật & Quyền truy cập

### Permission Model

```
┌─────────────────────────────────────────┐
│           PERMISSION LEVELS             │
├─────────────────────────────────────────┤
│                                         │
│  ✅ ALLOW (tự động)                     │
│  • Đọc file                             │
│  • Search code (grep/glob)              │
│  • Xem git status                       │
│                                         │
│  ⚠️ APPROVE (cần user đồng ý)           │
│  • Viết/Sửa file                        │
│  • Chạy shell commands                  │
│  • Git commit/push                      │
│  • Truy cập MCP servers                 │
│                                         │
│  ❌ DENY (bị chặn)                      │
│  • Truy cập file nhạy cảm               │
│  • Lệnh phá hủy hệ thống                │
│  • Truy cập secrets/credentials         │
│                                         │
└─────────────────────────────────────────┘
```

### Auto Mode

- Giảm "approval fatigue" — tự động approve hành động thấp rủi ro
- Hành động cao rủi ro vẫn cần approve thủ công
- **Cẩn thận**: Không bật ở production environment

### Sandbox

- **Filesystem isolation**: Giới hạn thư mục truy cập
- **Network isolation**: Giới hạn kết nối mạng
- **Phù hợp**: Dev containers, VMs cô lập

---

## 8. Khó khăn thường gặp & KHÔNG NÊN LÀM

### Khó khăn thường gặp

| Khó khăn | Mô tả |
|-----------|-------|
| **Context window đầy** | Session dài → Claude quên context đầu → Dùng `/compact` thường xuyên |
| **Cost vượt budget** | Token usage cao → Theo dõi `/cost`, dùng `/compact` |
| **Approval fatigue** | Quá nhiều popup xác nhận → Dùng Auto Mode cẩn thận |
| **Sai scope** | Claude hiểu sai yêu cầu → Mô tả chi tiết hơn, dùng Plan Mode trước |
| **Hallucination** | Claude "bịa" API/library không tồn tại → Kiểm tra package.json trước |
| **Debug chậm** | Task phức tạp quá → Chia nhỏ task, dùng subagents |
| **File conflict** | Sửa cùng lúc nhiều file → Dùng Git worktrees |
| **Memory giữa session** | Claude không nhớ session trước → Dùng CLAUDE.md + `/memory` |

### KHÔNG NÊN LÀM

```
❌ KHÔNG BAO GIỜ LÀM:

1. KHÔNG dùng --dangerously-skip-permissions ở production
   → Bỏ qua toàn bộ security layer
   → Chỉ dùng trong dev containers/VMs cô lập

2. KHÔNG để Claude truy cập secrets/credentials
   → API keys, database passwords, tokens
   → Dùng environment variables hoặc vault

3. KHÔNG approve blindly
   → Luôn đọc diff trước khi approve
   → Kiểm tra lệnh bash trước khi chạy

4. KHÔNG dùng CLAUDE.md quá chung chung
   → "Write clean code" = vô dụng
   → Chỉ include project-specific instructions

5. KHÔNG chạy Claude Code với quyền root
   → Luôn chạy ở user-space
   → Dùng least-privilege access

6. KHÔNG ignore lint/type errors
   → Luôn chạy lint + typecheck sau mỗi task
   → Claude có thể引入 subtle bugs

7. KHÔNG trust 100% output
   → AI có thể hallucinate
   → Review critical code paths thủ công

8. KHÔNG auto-install packages mới
   → Kiểm tra trước khi thêm dependency
   → Dùng allowlist/trusted registries

9. KHÔNG để MCP servers chạy tự do
   → Audit MCP servers định kỳ
   → Disable unused connectors

10. KHÔNG dùng trong shared/production environments
    → Devcontainers hoặc VMs riêng biệt
    → Không bao giờ trên production servers
```

### Những rủi ro bảo mật cần lưu ý

| Rủi ro | Mô tả | Giải pháp |
|--------|-------|-----------|
| **Prompt injection** | Malicious input thao túng Claude | Sandboxing + permission layer |
| **Code injection** | Claude viết code độc hại (accidental) | Review diff trước khi approve |
| **Data exfiltration** | Claude gửi data ra ngoài | Network isolation |
| **Secrets leak** | Secrets xuất hiện trong code | Secrets management (vault) |
| **Dependency risk** | Claude đề xuất package độc hại | Manual approval cho packages |
| **Audit gap** | Không có cross-session audit trail | Enable telemetry + logging |

---

## 9. Giải pháp sử dụng hiệu quả

### Prompting Strategies

```
✅ TỐT:
> "Thêm rate limiter cho API endpoints ở src/api/middleware/.
> Dùng sliding window algorithm. Kiểm tra edge cases và race conditions."

❌ TỆ:
> "Fix the API"
```

### Context Management

```
1. Dùng /compact thường xuyên (sau mỗi 10-15 exchange)
2. Bắt đầu session mới cho task riêng biệt
3. Ghi rõ context trong CLAUDE.md
4. Dùng @file để reference cụ thể
```

### Cost Optimization

```
1. Theo dõi /cost thường xuyên
2. Dùng Sonnet cho task đơn giản, Opus cho phức tạp
3. Dùng /compact để giảm context size
4. Batch các task nhỏ trong 1 session
5. Dùng Headless mode cho CI/CD (token tiết kiệm hơn)
```

### Best Practices cho Team

```
1. Shared CLAUDE.md trong repo
2. Custom slash commands cho workflow chung
3. Managed settings.json cho security policies
4. Telemetry + logging tập trung
5. Branch protection rules + code review
6. Dev containers cho development environment
```

---

## 10. Lưu ý khi triển khai

### Checklist trước khi triển khai

```
□ Cài đặt CLAUDE.md chi tiết cho project
□ Cấu hình permission levels (settings.json)
□ Setup secrets management (vault/env vars)
□ Configure MCP servers cần thiết
□ Enable telemetry + logging
□ Test trong devcontainer trước
□ Đào tạo team về usage guidelines
□ Định nghĩa approval workflow
□ Setup cost monitoring
□ Audit security periodically
```

### Quy trình triển khai cho team

```
┌─────────────────────────────────────────────────────────┐
│              TRIỂN KHAI CLAUDE CODE CHO TEAM            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Giai đoạn 1: Chuẩn bị (1-2 tuần)                       │
│  ├── Setup shared CLAUDE.md                             │
│  ├── Cấu hình managed settings.json                     │
│  ├── Setup secrets vault                                │
│  └── Định nghĩa security policies                       │
│                                                         │
│  Giai đoạn 2: Pilot (2-4 tuần)                          │
│  ├── Chọn 2-3 developers test                           │
│  ├── Theo dõi cost + feedback                           │
│  ├── Fine-tune CLAUDE.md + permissions                  │
│  └── Document best practices                            │
│                                                         │
│  Giai đoạn 3: Rollout (2-4 tuần)                        │
│  ├── Đào tạo team-wide                                  │
│  ├── Deploy managed settings                            │
│  ├── Enable telemetry monitoring                        │
│  └── Establish review workflows                         │
│                                                         │
│  Giai đoạn 4: Vận hành (liên tục)                       │
│  ├── Monitor cost + performance                         │
│  ├── Audit security định kỳ                             │
│  ├── Update CLAUDE.md khi project thay đổi              │
│  └── Community sharing + improvement                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Enterprise Deployment Options

| Phương án | Mô tả | Phù hợp |
|-----------|-------|---------|
| **Anthropic Console** | Direct API | Individual/Small team |
| **Amazon Bedrock** | AWS managed | Enterprise (AWS) |
| **Google Vertex AI** | GCP managed | Enterprise (GCP) |
| **Microsoft Foundry** | Azure managed | Enterprise (Azure) |

---

## 11. So sánh với đối thủ

| Tính năng | Claude Code | Cursor | GitHub Copilot | Windsurf | Aider |
|-----------|-------------|--------|----------------|----------|-------|
| **Môi trường** | Terminal + IDE + Web | IDE (VS Code fork) | IDE plugin | IDE (VS Code fork) | Terminal |
| **Agentic editing** | ✅ Full | ✅ Full | ✅ Agent mode | ✅ Full | ✅ Full |
| **Multi-file edits** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Terminal commands** | ✅ Native | ✅ Integrated | ✅ In IDE | ✅ Integrated | ✅ Native |
| **Git automation** | ✅ Full workflow | ⚠️ Basic | ⚠️ Basic | ⚠️ Basic | ✅ Good |
| **MCP support** | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Custom commands** | ✅ Skills system | ✅ Rules | ⚠️ Limited | ✅ Rules | ❌ |
| **CI/CD mode** | ✅ Headless | ❌ | ✅ Copilot CLI | ❌ | ✅ |
| **Desktop app** | ✅ | N/A | N/A | N/A | ❌ |
| **Web interface** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Mobile access** | ✅ Remote Control | ❌ | ❌ | ❌ | ❌ |
| **Free tier** | ❌ | ✅ Limited | ✅ Limited | ✅ Limited | ✅ (BYOK) |

### Khi nào dùng Claude Code

- ✅ Cần terminal-native workflow
- ✅ Multi-file + multi-step tasks
- ✅ Git automation phức tạp
- ✅ MCP integration
- ✅ CI/CD pipeline
- ✅ Cross-device workflow

### Khi nào dùng đối thủ

- ✅ Cursor: IDE-first workflow, cần visual
- ✅ Copilot: Đã dùng VS Code, cần autocomplete
- ✅ Aider: Cần BYOK, terminal preference
- ✅ Windsurf: Cần IDE tích hợp

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│               CLAUDE CODE QUICK REFERENCE               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  CÀI ĐẶT:  npm install -g @anthropic-ai/claude-code     │
│  KHỞI ĐỘNG: cd project && claude                        │
│  HELP:      ? (trong session)                           │
│                                                         │
│  LỆNH QUAN TRỌNG:                                       │
│  /init      → Tạo CLAUDE.md                             │
│  /plan      → Plan mode (chỉ đọc)                       │
│  /compact   → Tóm tắt context                           │
│  /cost      → Xem chi phí                               │
│  /review    → Code review                               │
│  /clear     → Xóa context                               │
│  /memory    → Chỉnh sửa CLAUDE.md                       │
│                                                         │
│  PHÍM TẮT:                                              │
│  Enter      → Gửi tin nhắn                              │
│  Escape     → Hủy task                                  │
│  ?          → Tất cả phím tắt                           │
│                                                         │
│  QUY TẮC VÀNG:                                          │
│  1. Luôn có CLAUDE.md chi tiết                          │
│  2. Đọc diff trước khi approve                          │
│  3. Dùng /compact thường xuyên                          │
│  4. Chạy lint + typecheck sau mỗi task                  │
│  5. Không dùng ở production                             │
│  6. Theo dõi /cost                                      │
│  7. Dùng Plan Mode cho task phức tạp                    │
│  8. Không approve blind                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

> **Tài liệu này được tổng hợp từ video tutorial và tài liệu chính thức Anthropic.**  
> Luôn tham khảo https://code.claude.com/docs để biết thông tin mới nhất.
