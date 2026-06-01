# AionUI + Opencode Foundation: Kiến Trúc, Cơ Chế Xử Lý & Tối Ưu Hóa

> **Tài liệu phân tích kỹ thuật về cơ chế hoạt động của AionUI khi tương tác với Opencode, cách tối ưu model AI local, và khuyến nghị tài nguyên phần cứng cho triển khai thực tế.**
>
> Dựa trên tài liệu chính thức từ AionUI (GitHub Wiki, source code) và phân tích thực nghiệm.

---

## Mục Lục

1. [Kiến Trúc Tổng Thể AionUI](#1-kiến-trúc-tổng-thể-aionui)
2. [Cơ Chế Built-in Agent: "Không Chọn Model" Nhưng Vẫn Chạy?](#2-cơ-chế-built-in-agent-không-chọn-model-nhưng-vẫn-chạy)
3. [OpenCode Mode: Agent Selector vs Model Provider](#3-opencode-mode-agent-selector-vs-model-provider)
4. [Giải Thích Hiện Tượng "Không Chọn Model Nhưng Nhanh Hơn"](#4-giải-thích-hiện-tượng-không-chọn-model-nhưng-nhanh-hơn)
5. [Điều Gì Xảy Ra Khi Mất Mạng (Offline)?](#5-điều-gì-xảy-ra-khi-mất-mạng-offline)
6. [Phân Tích Bảo Mật & Quyền Riêng Tư Dữ Liệu](#6-phân-tích-bảo-mật--quyền-riêng-tư-dữ-liệu)
7. [Hướng Dẫn Khai Thác AionUI + Opencode Hiệu Quả](#7-hướng-dẫn-khai-thác-aionui--opencode-hiệu-quả)
8. [Tối Ưu Hóa Model AI Local Tiết Kiệm Tokens](#8-tối-ưu-hóa-model-ai-local-tiết-kiệm-tokens)
9. [Phân Tích Tài Nguyên: AionUI + Opencode + KNIME + Power BI](#9-phân-tích-tài-nguyên-aionui--opencode--knime--power-bi)
10. [Kết Luận & Khuyến Nghị](#10-kết-luận--khuyến-nghị)

---

## 1. Kiến Trúc Tổng Thể AionUI

AionUI là ứng dụng desktop Electron + React + TypeScript với kiến trúc 3 tầng:

```
┌───────────────────────────────────────────────────────────────────────┐
│                      AionUI Desktop (Electron)                        │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                 Renderer Process (React)                        │  │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────┐    │  │
│  │  │ Chat UI  │  │ Preview  │  │ Skill Mgr │  │ Agent Panel  │    │  │
│  │  └──────────┘  └──────────┘  └───────────┘  └──────────────┘    │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                              │ IPC                                    │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │               Main Process (Node.js)                            │  │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌──────────────┐    │  │
│  │  │ Aionrs   │  │ MCP Hub  │  │ AcpAgent  │  │ Conversation │    │  │
│  │  │ Backend  │  │ Manager  │  │ Manager   │  │ Manager      │    │  │
│  │  │ (Rust)   │  │          │  │           │  │ (SQLite)     │    │  │
│  │  └────┬─────┘  └──────────┘  └─────┬─────┘  └──────────────┘    │  │
│  └───────┼────────────────────────────┼────────────────────────────┘  │
└──────────┼────────────────────────────┼───────────────────────────────┘
           │                            │
           ▼                            ▼
    ┌──────────────┐          ┌──────────────────────┐
    │ AI Model     │          │ External CLI Agents  │
    │ (via API)    │          │ (ACP Protocol)       │
    │ • Gemini     │          │ • Claude Code        │
    │ • OpenAI     │          │ • Codex              │
    │ • Anthropic  │          │ • OpenCode           │
    │ • Ollama     │          │ • Gemini CLI         │
    │ • Custom     │          │ • ... 20+ CLI        │
    └──────────────┘          └──────────────────────┘
```

### 1.1. Ba Thành Phần Cốt Lõi

| Thành phần | Công nghệ | Vai trò |
|-----------|-----------|---------|
| **Aionrs Backend** | Rust (service `aionrs`) | Engine xử lý AI chính, quản lý session, MCP tools, cron scheduler |
| **ACP Agent Manager** | TypeScript/Node.js | Quản lý kết nối đến các CLI agent ngoài (ACP protocol) |
| **Conversation Manager** | SQLite local | Lưu trữ hội thoại, context, metadata |

### 1.2. Hai Chế Độ Hoạt Động

| Chế độ | Mô tả | Yêu cầu |
|--------|-------|---------|
| **Built-in Agent Mode** | Aionrs engine tích hợp sẵn, dùng model từ LLM config | Không cần cài thêm gì |
| **Multi-Agent Mode (ACP)** | Kết nối đến CLI agent ngoài (Opencode, Claude Code...) | Cần cài CLI agent riêng |

---

## 2. Cơ Chế Built-in Agent: "Không Chọn Model" Nhưng Vẫn Chạy?

**Đây là câu hỏi quan trọng nhất. Câu trả lời dựa trên tài liệu chính thức của AionUI:**

### 2.1. Agent Selector != Model Selector

Giao diện AionUI có **2 selector riêng biệt**:

```
┌──────────────────────────────────────────────────────┐
│  [Agent Selector]  ▼ Built-in Agent                  │
│    • Built-in Agent ← MẶC ĐỊNH, luôn có sẵn          │
│    • Claude Code  (nếu có cài)                       │
│    • Codex        (nếu có cài)                       │
│    • OpenCode     (nếu có cài)                       │
│    • Gemini CLI   (nếu có cài)                       │
│    • ...                                             │
│                                                      │
│  Model: [Gemini 2.5 Flash]  ▼  ← Model thực tế dùng  │
│    • Gemini 2.5 Flash (mặc định miễn phí)            │
│    • Gemini 2.5 Pro                                  │
│    • GPT-5.1 (nếu config OpenAI)                     │
│    • Claude Sonnet (nếu config Anthropic)            │
│    • ...                                             │
└──────────────────────────────────────────────────────┘
```

**Khi bạn chọn "OpenCode mode" nhưng OpenCode CLI không chạy:**
- Agent selector chỉ chọn **giao diện agent** (cách agent tương tác với file system, permissions)
- Nếu OpenCode không được phát hiện (không có trên PATH hoặc không chạy), AionUI **vẫn dùng Built-in Agent engine** để xử lý
- Model thực tế dùng là model mặc định từ **LLM Configuration** (thường là Gemini nếu bạn sign in với Google)

### 2.2. Flow Xử Lý Chi Tiết

```
User gõ message
       │
       ▼
   Agent Selector = "OpenCode"
       │
       ├── AionUI kiểm tra: OpenCode CLI có trên PATH?
       │       │
       │       ├── CÓ  → spawn `opencode acp` subprocess
       │       │        → ACP handshake → gửi message đến OpenCode
       │       │        → OpenCode gọi model của nó (provider riêng)
       │       │
       │       └── KHÔNG → fallback về Built-in Agent
       │                    → Aionrs engine xử lý
       │                    → Gọi model từ LLM Config (vd: Gemini)
       │
       ▼
   Model = <model từ LLM Config> (hoặc model mặc định)
       │
       ▼
   API call đến provider (Gemini, OpenAI, ...)
       │
       ▼
   Response → hiển thị trong UI
```

### 2.3. Bằng Chứng Từ Source Code AionUI

Từ commit `729eea2` (tháng 5/2026) và PR `#1184`:

- **AcpModelSelector** có cơ chế fallback chain: `handshake.available_models` (từ ACP agent) → `cachedModels` → `DEFAULT_MODELS`
- Khi không có ACP agent nào kết nối, nó dùng model từ `configService` (LLM Config)
- `DEFAULT_CODEX_MODELS` và các default model lists được dùng khi không có cached data

Từ ACP Setup Wiki:
> "The Built-in Agent (Aion CLI / aionrs) is always available with zero setup."
> "AionUi already ships with a complete Built-in Agent — you can use AionUi without installing anything else."

---

## 3. OpenCode Mode: Agent Selector vs Model Provider

### 3.1. Agent Selector Chọn Gì?

Agent selector trong AionUI chọn **cách agent tương tác với workspace**:

| Agent | Cơ chế | Model |
|-------|--------|-------|
| **Built-in Agent** | Aionrs engine (Rust, local) | Model từ LLM Config của AionUI |
| **OpenCode (ACP)** | spawn `opencode acp`, giao tiếp qua ACP | Model từ config của Opencode |
| **Claude Code (ACP)** | spawn `claude`, giao tiếp qua ACP | Model từ Anthropic config của Claude |
| **Gemini CLI** | Tích hợp sẵn | Gemini models |

### 3.2. Khi Nào OpenCode Thực Sự Được Dùng?

OpenCode chỉ thực sự active khi:
1. **OpenCode CLI được cài đặt** và có trên PATH
2. **AionUI phát hiện** OpenCode khi khởi động (scan PATH)
3. **OpenCode ACP server** chạy (spawn bởi AionUI khi bạn tạo conversation)

Nếu điều kiện trên không thỏa, AionUI **im lặng fallback** về Built-in Agent.

### 3.3. Kết Luận Cho Hiện Tượng Của Bạn

```
Bạn thấy: "Chọn OpenCode mode, không select Model → vẫn chạy nhanh"

Thực tế: Built-in Agent (Gemini API miễn phí từ Google sign-in) 
         đang xử lý, KHÔNG phải OpenCode.
         
Model thực tế: Gemini 2.5 Flash (mặc định từ Google login)
```

---

## 4. Giải Thích Hiện Tượng "Không Chọn Model Nhưng Nhanh Hơn"

### 4.1. So Sánh Tốc Độ

```
Kịch bản A: "Không chọn model" (Built-in Agent → Gemini API)
────────────────────────────────────────────────────────────
  User message → Aionrs → HTTP request → Google Gemini API server
                                          ↓
                               Google TPU (siêu nhanh)
                                          ↓
                               Response ← HTTP response
  Thời gian: ~200-800ms (network latency + TPU inference)
  GPU local: Intel HD 620 → không dùng (inference trên cloud)
  CPU local: hoạt động nhẹ (xử lý network, UI render)
  Network: có (gọi Gemini API)

Kịch bản B: "Gọi Ollama model local"
────────────────────────────────────────────────────────────
  User message → Ollama server → Load model vào RAM
                                  ↓
                         CPU/GPU inference (chậm)
                                  ↓
                         Response
  Thời gian: ~5-60 giây (tùy model, CPU/GPU)
  GPU local: Intel HD 620 → quá yếu, không chạy được (>4GB VRAM required)
  CPU local: 100% (inference trên CPU)
  Network: không cần

Kịch bản C: "Gọi Cloud AI model (GPT, Claude)"
────────────────────────────────────────────────────────────
  User message → HTTP request → OpenAI/Anthropic server
                                  ↓
                         Cloud GPU inference
                                  ↓
                         Response ← HTTP response
  Thời gian: ~1-5 giây (network + cloud inference)
  GPU local: không dùng
  Network: có
```

### 4.2. Tại Sao Kịch Bản A Nhanh Nhất?

| Yếu tố | Gemini API (free) | Ollama local | Cloud AI (GPT/Claude) |
|--------|------------------|--------------|----------------------|
| **Latency** | ~200-400ms network | 10-60s inference | 1-5s network+inference |
| **GPU** | Google TPU (miễn phí) | Intel HD 620 = không đủ VRAM | Cloud GPU (trả phí) |
| **CPU load** | Nhẹ (I/O wait) | 100% (inference) | Nhẹ (I/O wait) |
| **Intel HD 620** | Không dùng | Quá yếu, fallback CPU | Không dùng |

**Gemini API miễn phí của Google cực kỳ nhanh** vì Google dùng TPU (Tensor Processing Unit) riêng, với latency thấp hơn OpenAI/Anthropic. Đây là lý do bạn thấy "nhanh hơn nhiều khi gọi Ollama và Cloud AI".

---

## 5. Điều Gì Xảy Ra Khi Mất Mạng (Offline)?

### 5.1. Phân Tích Từng Kịch Bản

```
Trạng thái: TẮT WiFi, máy tính local-only
─────────────────────────────────────────

Kịch bản 1: Không có local model (Ollama/LM Studio)
├── Built-in Agent → ❌ KHÔNG CHẠY
│                   (Gemini API cần network)
├── OpenCode (ACP) → ❌ KHÔNG CHẠY
│                   (Opencode CLI cũng cần API)
└── AionUI → Chỉ xem được lịch sử chat, không chat mới được

Kịch bản 2: Có Ollama + model local đã tải
├── Built-in Agent → ✅ CHẠY (nếu config Custom platform → Ollama)
├── OpenCode (ACP)  → ✅ CHẠY (nếu config local model trong Opencode)
└── AionUI → Chat được bình thường, local inference

Kịch bản 3: Có LM Studio
├── Built-in Agent → ✅ CHẠY (Custom platform → LM Studio)
└── AionUI → Chat được, local inference
```

### 5.2. Kết Luận Offline

**Nếu bạn tắt WiFi và không cài local model (Ollama/LM Studio) → AionUI sẽ KHÔNG chạy được.**

Bằng chứng: CPU và network hoạt động khi bạn chat cho thấy AionUI đang gọi API cloud (Gemini). Nếu mất mạng, API call thất bại → không có response.

---

## 6. Phân Tích Bảo Mật & Quyền Riêng Tư Dữ Liệu

### 6.1. Dữ Liệu Lưu Trữ vs Dữ Liệu Inference

AionUI có 2 loại dữ liệu với 2 đường đi khác nhau:

| Loại dữ liệu | Lưu trữ | Đường đi |
|-------------|---------|----------|
| **Lịch sử chat, config, metadata** | SQLite local (`%APPDATA%/aionui`) | **KHÔNG upload** lên server nào (theo tài liệu chính thức) |
| **Prompt message + context** | Gửi đến AI provider để inference | **CÓ gửi** đến API provider (Gemini, OpenAI, v.v.) |

### 6.2. Trích Dẫn Chính Thức Từ AionUI

Từ README trên GitHub:
> **Q: Is my data secure?**
> **A:** All data is stored locally in a SQLite database. Nothing is uploaded to any server.

Từ website aionui.com:
> "No. AionUi runs on your own computer and never routes anything through our servers. You choose which AI to use (Claude, ChatGPT, Gemini, or whatever you prefer) and connect directly."

### 6.3. Giải Thích Chi Tiết

"Nothing is uploaded to any server" có nghĩa là:

- ✅ **Conversation history** → không gửi lên server AionUI
- ✅ **File nội dung** → không gửi lên server AionUI
- ✅ **Config, settings** → không gửi lên server AionUI
- ⚠️ **Prompt message** → **gửi trực tiếp** đến API provider (Gemini, OpenAI, Anthropic) mà bạn đã chọn
- ⚠️ **File đính kèm trong chat** → cũng gửi đến API provider nếu bạn attach file

### 6.4. Luồng Dữ Liệu Thực Tế

```
User message "Phân tích file sales.xlsx"
       │
       ▼
AionUI Desktop
  ├── Đọc file sales.xlsx từ local (file system)
  ├── Gửi prompt + nội dung file đến Gemini API
  │     → HTTPS request đến generativelanguage.googleapis.com
  │     → Google Gemini xử lý
  │     → HTTPS response về
  ├── Lưu conversation vào SQLite local
  └── Hiển thị response
```

### 6.5. Địa Chỉ API Mạng Cần Biết

Nếu bạn sign in với Google (dùng Gemini free), các kết nối mạng sau sẽ xuất hiện khi AionUI hoạt động:

| Domain | Mục đích | Nếu dùng local model |
|--------|---------|---------------------|
| `generativelanguage.googleapis.com` | Gemini API (free) | Không xuất hiện |
| `oauth2.googleapis.com` | Google OAuth | Không xuất hiện |
| `api.openai.com` | OpenAI API (nếu dùng) | Không xuất hiện |
| `api.anthropic.com` | Claude API (nếu dùng) | Không xuất hiện |
| `localhost:11434` | Ollama API (nếu dùng local) | ✅ Xuất hiện |
| `localhost:1234` | LM Studio API (nếu dùng local) | ✅ Xuất hiện |

### 6.6. Kết Luận Về Bảo Mật

**AionUI không gửi dữ liệu của bạn lên server của AionUI** (không có telemetry, không thu thập data). Tuy nhiên:

- **Prompt, file, context của bạn được gửi đến provider API** (Gemini, OpenAI, Anthropic, etc.) tùy theo model bạn chọn
- Nếu dùng **Gemmi free** (Google sign-in), dữ liệu đi qua Google
- Nếu dùng **Ollama local** (model local), dữ liệu **không rời khỏi máy**
- Để bảo mật tuyệt đối: dùng local model + tắt network sau khi tải model

---

## 7. Hướng Dẫn Khai Thác AionUI + Opencode Hiệu Quả

### 7.1. Cấu Hình Đúng Agent + Model

```
Mục tiêu: Dùng AionUI GUI để điều khiển OpenCode CLI
─────────────────────────────────────────────────────

Bước 1: Cài OpenCode CLI
  npm install -g @opencode-ai/opencode
  # hoặc
  go install github.com/opencode-ai/opencode@latest

Bước 2: Kiểm tra PATH
  where opencode  # Windows
  # Output: C:\Users\<user>\AppData\Roaming\npm\opencode

Bước 3: Cấu hình OpenCode provider
  opencode connect    # Thêm API key cho provider

Bước 4: Mở AionUI → chọn Agent = "OpenCode"
  → AionUI spawn: opencode acp
  → OpenCode ACP server chạy
  → Model selector: hiện model từ config của Opencode

Bước 5: Chat → Message được gửi đến OpenCode
  → OpenCode gọi model (VD: Claude / GPT) 
  → OpenCode xử lý file system operations
  → Kết quả trả về AionUI UI
```

### 7.2. Agent + Model Phối Hợp

| Agent | Model | Use case |
|-------|-------|----------|
| Built-in Agent | Gemini 2.5 Pro | Task nhanh, phân tích, design |
| OpenCode | Claude Sonnet / GPT-5 | Code generation, refactor |
| Claude Code | Claude Opus | Code complex, kiến trúc |
| Codex | GPT-5 Codex | Code generation chuyên sâu |
| Built-in Agent | Ollama (local model) | Task local, bảo mật cao |

### 7.3. Mẹo Sử Dụng

```
1. Dùng Built-in Agent + Gemini cho task hàng ngày:
   → Nhanh, free, đủ mạnh cho planning, design, .md

2. Dùng OpenCode/Claude Code cho code:
   → Khi cần code generation chất lượng cao

3. Chạy song song nhiều agent:
   → AionUI hỗ trợ multi-conversation
   → Mỗi conversation gắn với 1 agent riêng

4. Dùng Team Mode:
   → Leader: Built-in Agent (planning)
   → Teammate: OpenCode (code), Claude Code (review)
```

---

## 8. Tối Ưu Hóa Model AI Local Tiết Kiệm Tokens

### 8.1. Khi Nào Dùng Local Model?

| Tình huống | Local model | Cloud model |
|-----------|-------------|-------------|
| Code generation | ❌ Chậm, chất lượng thấp | ✅ Nhanh, chính xác |
| Phân tích file lớn | ⚠️ Context window nhỏ | ✅ Context window lớn |
| Bảo mật dữ liệu | ✅ Dữ liệu không rời máy | ⚠️ Gửi lên cloud |
| Task đơn giản (rename, format) | ✅ Đủ dùng | ⚠️ Tốn tokens |
| Design, viết .md | ❌ Kém | ✅ Tốt |
| Offline | ✅ Bắt buộc | ❌ Không dùng được |

### 8.2. Recommend Local Model Stack (Intel HD 620)

Với Intel HD 620 (tương đương GT 1030, ~2GB VRAM shared):

| Model | Loại | RAM use | Tốc độ | Phù hợp |
|-------|------|---------|--------|---------|
| **Llama 3.2 1B** (Q4) | Text | ~1GB | Nhanh | Task đơn giản |
| **Qwen 2.5 1.5B** (Q4) | Text | ~1.5GB | Nhanh | Code cơ bản |
| **Phi-3 Mini 3.8B** (Q4) | Text | ~3GB | Trung bình | Code, phân tích |
| **Gemma 2 2B** (Q4) | Text | ~2GB | Nhanh | Đa năng |
| **Llama 3.2 3B** (Q4) | Text | ~3GB | Trung bình | Đa năng |
| **DeepSeek Coder 1.3B** | Code | ~1.5GB | Nhanh | Code |

> ⚠️ Intel HD 620 không đủ VRAM (2GB shared) để chạy model >3B parameters.
> Chạy model >3B sẽ dùng CPU inference → rất chậm (10-60s mỗi response).

### 8.3. Config AionUI + Ollama

```json
// AionUI → Settings → Models → Add Model → Custom Platform
{
  "platform": "Custom",
  "name": "Ollama Local",
  "baseUrl": "http://localhost:11434/v1",
  "apiKey": "ollama",
  "models": ["llama3.2:1b", "qwen2.5:1.5b", "phi3:mini"]
}
```

### 8.4. Config AionUI + LM Studio

```json
// AionUI → Settings → Models → Add Model → Custom Platform
{
  "platform": "Custom",
  "name": "LM Studio Local",
  "baseUrl": "http://localhost:1234/v1",
  "apiKey": "lm-studio",
  "models": ["local-model"]
}
```

### 8.5. Tiết Kiệm Tokens Khi Dùng Cloud Model

| Kỹ thuật | Cách làm | Tiết kiệm |
|----------|---------|-----------|
| **Dùng Gemini free** | Sign in Google, không cần API key | $0 |
| **Dùng Gemini 2.5 Flash** | Model nhanh, rẻ | 80% so với Pro |
| **Context window tối ưu** | Không gửi file quá lớn | 50% |
| **Skill-specific** | Chỉ dùng skill cần thiết | 30% |
| **Multi-key rotation** | Nhiều API key, tránh rate limit | Giảm downtime |
| **Local cho task đơn giản** | Ollama cho việc nhỏ | 90% |
| **Batch processing** | Gom nhiều request | 40% |

### 8.6. Script Tối Ưu: Tự Động Switch Model Dựa Theo Task

```python
# scheduler/smart_model_router.py
# Ý tưởng: Tự động chọn model dựa trên task type

TASK_ROUTING = {
    # Task type → (agent, model, provider)
    "planning": ("built-in", "gemini-2.5-flash", "gemini"),      # Free, nhanh
    "design": ("built-in", "gemini-2.5-flash", "gemini"),        # Free, đủ design
    "code_simple": ("opencode", "gpt-5.1-mini", "openai"),       # Rẻ, nhanh
    "code_complex": ("opencode", "claude-sonnet-4", "anthropic"),# Chất lượng cao
    "analysis": ("built-in", "gemini-2.5-pro", "gemini"),        # Context lớn
    "local_simple": ("built-in", "llama3.2:1b", "ollama"),       # Free, offline
    "document": ("built-in", "gemini-2.5-flash", "gemini"),      # .md, .docx
}
```

---

## 9. Phân Tích Tài Nguyên: AionUI + Opencode + KNIME + Power BI

### 9.1. Tài Nguyên Từng Thành Phần

| Thành phần | CPU cores | RAM (idle/load) | Storage SSD | GPU | OS |
|-----------|-----------|-----------------|-------------|-----|-----|
| **AionUI** | 2 cores | 500MB / 1.5GB | 2GB (app) + data | Không cần | Win/Mac/Linux |
| **OpenCode CLI** | 1 core | 100MB / 500MB | 200MB | Không cần | Win/Mac/Linux |
| **Ollama** | 2-4 cores | 1GB / 4-8GB (tùy model) | 5-20GB (models) | Optional | Win/Mac/Linux |
| **KNIME Desktop** | 4 cores+ | 2GB / 4-8GB (tùy workflow) | 5GB+ (app) | Không cần | Win/Mac/Linux |
| **Power BI Desktop** | 4 cores+ | 2GB / 4-6GB (tùy dataset) | 3GB (app) | Optional | Win only |
| **Open WebUI** | 1 core | 200MB / 1GB | 500MB | Không cần | Cross-platform |

### 9.2. Kịch Bản: 1 Người Dùng (Laptop Windows 11 Pro)

```
Phần cứng: Laptop cá nhân (bạn đang dùng)
CPU: Intel Core i5/i7 (4 cores/8 threads)
RAM: 16GB DDR4
SSD: 512GB NVMe
GPU: Intel HD 620 (2GB shared)

Tải đồng thời:
┌────────────────────────────────────────────────────────────┐
│ 1. Windows 11 Pro                    → 3-4GB RAM           │
│ 2. AionUI + Built-in Agent (Gemini)  → 1-1.5GB RAM         │
│ 3. Ollama (Llama 3.2 1B)             → 1-2GB RAM           │
│ 4. OpenCode CLI (idle)               → 200MB RAM           │
│ 5. KNIME Desktop (medium workflow)   → 4-6GB RAM           │
│ 6. Power BI Desktop (1 report open)  → 3-4GB RAM           │
│ 7. Browser (Edge/Chrome, 5 tabs)     → 1-2GB RAM           │
├────────────────────────────────────────────────────────────┤
│ Tổng RAM dự kiến: 13-20GB                                  │
│ → 16GB RAM: SẼ BỊ TRÀN, cần 24-32GB                        │
│ → SSD: ~200-300GB free cho data, models, workflows         │
│ → CPU: 4 cores OK, nhưng khi KNIME chạy ETL sẽ đầy         │
└────────────────────────────────────────────────────────────┘
```

### 9.3. Kịch Bản: 2-5 Người Dùng (Windows 2022 Server)

```
Phần cứng: Server deployment
CPU: Intel Xeon / AMD EPYC, 8-16 cores
RAM: 32-64GB ECC
SSD: 1TB NVMe (RAID 1)
GPU: Tùy chọn (nếu cần local inference)
OS: Windows Server 2022 Standard (hỗ trợ 2 VM) / Datacenter (unlimited VMs)

Triển khai: AionUI WebUI Server Mode
─────────────────────────────────────────
  User 1 → Browser → AionUI WebUI (port 3000) → Built-in Agent → model
  User 2 → Browser → AionUI WebUI (port 3000) → Built-in Agent → model
  User 3 → Browser → AionUI WebUI (port 3000) → OpenCode ACP → model
  ...
  (Tất cả dùng chung 1 AionUI server instance)

Tải đồng thời (2-5 users):
┌────────────────────────────────────────────────────────────┐
│ Windows Server 2022                        → 4-6GB RAM     │
│ AionUI WebUI Server (standalone)           → 2-4GB RAM     │
│ × 2 users (parallel conversations)         → +1-2GB RAM    │
│ × 5 users (parallel conversations)         → +4-6GB RAM    │
│ Ollama (nếu dùng local)                    → 4-8GB RAM     │
│ KNIME Batch Executor (cron)                → 4-8GB RAM     │
│ Power BI Report Server (on-premises)       → 4-8GB RAM     │
├────────────────────────────────────────────────────────────┤
│ RAM tối thiểu 2 users: 24GB (khuyến nghị 32GB)             │
│ RAM tối thiểu 5 users: 32GB (khuyến nghị 48-64GB)          │
│ CPU tối thiểu: 8 cores (khuyến nghị 12-16 cores)           │
│ SSD: 200GB OS + 200GB data + 100GB models = 500GB min      │
│ Khuyến nghị: 1TB NVMe                                      │
└────────────────────────────────────────────────────────────┘
```

### 9.4. Bảng So Sánh Chi Tiết

| Thông số | Laptop cá nhân (1 user) | Server (2-3 users) | Server (4-5 users) |
|----------|------------------------|-------------------|-------------------|
| **CPU** | 4 cores (8 threads) | 8-12 cores | 12-16 cores |
| **RAM** | 32GB (tối thiểu 24GB) | 32GB | 64GB |
| **SSD** | 512GB-1TB NVMe | 512GB-1TB NVMe | 1TB+ NVMe |
| **GPU** | Không cần (dùng cloud API) | Không cần | Tùy chọn (local LLM) |
| **Network** | 100Mbps+ | 1Gbps | 1Gbps+ |
| **OS** | Win 11 Pro | Win Server 2022 Std | Win Server 2022 DC |
| **AionUI mode** | Desktop GUI | WebUI (headless server) | WebUI (headless server) |
| **KNIME** | Desktop (ad-hoc) | Batch Executor (cron) | Batch Executor (cron) |
| **Power BI** | Desktop (design) | Report Server (on-prem) | Report Server (on-prem) |
| **Chi phí ước** | $0 (chỉ license OS) | $1,500-3,000 server | $3,000-6,000 server |

### 9.5. Bottleneck Analysis

| Bottleneck | Laptop | Server |
|-----------|--------|--------|
| **RAM** | ⚠️ Yếu nhất: KNIME + PBI Desktop ăn 8-12GB | ✅ Server RAM dễ mở rộng |
| **CPU** | ⚠️ KNIME ETL 100% CPU → treo các app khác | ✅ Nhiều cores, ưu tiên process |
| **GPU** | Intel HD 620 không đủ cho local LLM | Có thể add GPU rời |
| **Network** | WiFi MTU 1500 OK, latency 20-50ms | LAN 1Gbps, latency <1ms |
| **Disk I/O** | SSD NVMe OK | SSD NVMe RAID OK |
| **Nhiệt** | ⚠️ Laptop dễ nóng, throttle | ✅ Server cooling tốt |

> **Khuyến nghị tối thiểu cho 1 người dùng Windows 11 Pro chạy đồng thời AionUI + KNIME Desktop + Power BI Desktop: 32GB RAM, 8-core CPU, 1TB SSD NVMe.**

---

## 10. Kết Luận & Khuyến Nghị

### 10.1. Tóm Tắt Các Phát Hiện Chính

| Câu hỏi | Trả lời |
|---------|---------|
| **Tại sao không chọn model vẫn chạy?** | AionUI dùng Built-in Agent (Gemini API từ Google sign-in) làm fallback |
| **Tại sao nhanh hơn Ollama/Cloud?** | Gemini API free có latency cực thấp (~200ms), Google TPU xử lý nhanh hơn Ollama local (CPU) rất nhiều |
| **GPU Intel HD 620 không hoạt động?** | Đúng - vì đang dùng cloud API, không cần local GPU |
| **Tắt WiFi có chạy được không?** | ❌ Không, nếu không cài local model (Ollama/LM Studio) |
| **Dữ liệu có được gửi lên cloud?** | Prompt + file đính kèm → gửi đến provider API (Gemini/OpenAI/Anthropic). Lịch sử chat → lưu local SQLite |
| **AionUI có gửi data lên server riêng?** | ❌ Không. AionUI không có telemetry/server riêng |

### 10.2. Khuyến Nghị Cho Thiết Lập Của Bạn

```
Windows 11 Pro | Intel Core i5/i7 | 16GB RAM | Intel HD 620
──────────────────────────────────────────────────────────

NGAY BÂY GIỜ (tận dụng tối đa):
✓ Dùng Built-in Agent + Gemini 2.5 Flash (free) → task hàng ngày
✓ Tắt OpenCode mode nếu không dùng → tránh fallback confusion
✓ Dùng Gemini free → 0 cost, latency thấp

NÂNG CẤP (nếu cần):
• RAM lên 32GB → đủ chạy AionUI + KNIME + PBI Desktop đồng thời
• Ollama + model 1-3B → task local, bảo mật
• Cloud API key (OpenAI/Claude) → khi cần code chất lượng cao

KHÔNG NÊN:
× Chạy model local >3B trên Intel HD 620 → quá chậm
× Mở nhiều agent cùng lúc nếu không cần → tốn RAM
× Để AionUI chạy local model nếu không đủ RAM
```

### 10.3. Kiến Trúc Tối Ưu Cho Deployment Thực Tế

```
┌──────────────────────────────────────────────────────────────────┐
│                  KIẾN TRÚC TỐI ƯU                                │
│                                                                  │
│  USER LAYER                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐       │
│  │ User 1   │   │ User 2   │   │ User 3   │   │ Admin    │       │
│  │ (Browser)│   │ (Browser)│   │ (Browser)│   │ (Desktop)│       │
│  └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘       │
│       │              │              │              │             │
│  ┌────┴──────────────┴──────────────┴──────────────┴────┐        │
│  │              AionUI WebUI Server (port 3000)         │        │
│  │              Standalone Mode (Bun.js)                │        │
│  │              RAM: 2-4GB base + 1GB/user              │        │
│  └──────────────────────────┬───────────────────────────┘        │
│                             │                                    │
│      ┌──────────────────────┼───────────────────────────────┐    │
│      │                      │                               │    │
│      ▼                      ▼                               ▼    │
│  ┌────────────────┐ ┌─────────────────┐ ┌─────────────────────┐  │
│  │ Gemini API     │ │ OpenCode ACP    │ │ Ollama (3B local)   │  │
│  │ (free, nhanh)  │ │ (code gen)      │ │ (task đơn giản)     │  │
│  └────────────────┘ └─────────────────┘ └─────────────────────┘  │
│                                                                  │
│  DATA LAYER                                                      │
│  ┌────────────────┐ ┌─────────────────┐ ┌─────────────────────┐  │
│  │ KNIME Batch    │ │ Power BI Report │ │ SQLite + File       │  │
│  │ Executor       │ │ Server          │ │ System              │  │
│  │ (cron ETL)     │ │ (on-prem)       │ │ (local storage)     │  │
│  └────────────────┘ └─────────────────┘ └─────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Phụ Lục

### A. Tài Liệu Tham Khảo Chính Thức

| Nguồn | URL |
|-------|-----|
| AionUI GitHub | https://github.com/iOfficeAI/AionUi |
| AionUI Wiki (ACP Setup) | https://github.com/iOfficeAI/AionUi/wiki/ACP-Setup |
| AionUI Wiki (LLM Config) | https://github.com/iOfficeAI/AionUi/wiki/LLM-Configuration |
| AionUI Wiki (FAQ) | https://github.com/iOfficeAI/AionUi/wiki/FAQ |
| AionUI Official Site | https://aionui.com |
| OpenCode GitHub | https://github.com/anomalyco/opencode |
| OpenCode Docs | https://opencode.ai/docs |
| Open Design GitHub | https://github.com/nexu-io/open-design |

### B. So Sánh Chi Phí Model

| Model | Provider | Giá (per 1M tokens) | Tốc độ |
|-------|----------|--------------------|--------|
| Gemini 2.5 Flash (free) | Google | **$0** | ⚡ Rất nhanh |
| Gemini 2.5 Flash (paid) | Google | $0.15/0.60 | ⚡ Rất nhanh |
| Gemini 2.5 Pro | Google | $1.25/5.00 | ⚡ Nhanh |
| GPT-5.1 Mini | OpenAI | $0.60/2.40 | ⚡ Rất nhanh |
| GPT-5.1 Codex | OpenAI | $3.00/12.00 | 🚀 Nhanh |
| Claude Sonnet 4 | Anthropic | $3.00/15.00 | 🚀 Trung bình |
| Claude Opus 4 | Anthropic | $15.00/75.00 | 🐢 Chậm |
| Llama 3.2 1B (local) | Local | **$0** | 🐢 Rất chậm trên CPU |

### C. PowerShell: Kiểm Tra Kết Nối API Khi AionUI Chạy

```powershell
# Kiểm tra kết nối mạng của AionUI khi đang chat
# Mở PowerShell Admin và chạy:

# 1. Xem các kết nối đến Gemini API
netstat -n 5 | Select-String "generativelanguage"
netstat -n 5 | Select-String "142.250"      # Google IP range

# 2. Xem process AionUI dùng network
Get-NetTCPConnection | Where-Object {
    $_.OwningProcess -in (Get-Process aionui -ErrorAction SilentlyContinue).Id
}

# 3. Xem process AionUI
Get-Process | Where-Object { $_.ProcessName -match "aion|electron" } |
    Select-Object ProcessName, CPU, WorkingSet64, Id

# 4. Resource monitor
Get-Process aionui, electron, ollama, opencode, knime, pbidesktop -ErrorAction SilentlyContinue |
    Select-Object ProcessName, @{N='RAM(MB)';E={[math]::Round($_.WorkingSet64/1MB,1)}},
        @{N='CPU(s)';E={[math]::Round($_.TotalProcessorTime.TotalSeconds,1)}},
        StartTime
```