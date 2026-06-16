# Thiết Kế Công Cụ AI Agent: Mô Hình Nào Hiệu Quả, Mô Hình Nào Không & Nguyên Lý Kết Hợp Với Database

> **Tác giả tổng hợp**: PhD Lê Toàn Thắng  
> **Nguồn tham khảo**:  
> - MachineLearningMastery.com — "AI Agent Tool Design: What Works and What Doesn't" (Bala Priya C, 2026)  
> - WecommitAI — "AI Agent kết hợp với Database" (Trần Quốc Huy, 2026)  
> - WWBN/AVideo Open Source Platform  
> - PostgreSQL HTX — "LLM Agents and PostgreSQL in 2026"  
> - MongoDB — "AI Agent Memory Architecture"  
> - OpenAgentSkill Registry  

---

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Thiết kế công cụ AI Agent — Cái gì hiệu quả?](#2-thiết-kế-công-cụ-ai-agent--cái-gì-hiệu-quả)
3. [Thiết kế công cụ AI Agent — Cái gì không hiệu quả?](#3-thiết-kế-công-cụ-ai-agent--cái-gì-không-hiệu-quả)
4. [Bảng so sánh tổng hợp](#4-bảng-so-sánh-tổng-hợp)
5. [Phân loại các mô hình AI & Agentic AI](#5-phân-loại-các-mô-hình-ai--agentic-ai)
6. [Các công cụ AI Agent hiệu quả & không hiệu quả](#6-các-công-cụ-ai-agent-hiệu-quả--không-hiệu-quả)
7. [AI Agent kết hợp với Database — Nguyên lý cốt lõi](#7-ai-agent-kết-hợp-với-database--nguyên-lý-cốt-lõi)
8. [Agentic BI — Tương lai của Business Intelligence](#8-agentic-bi--tương-lai-của-business-intelligence)
9. [Kiến trúc tham khảo](#9-kiến-trúc-tham-khảo)
10. [Kết luận](#10-kết-luận)

---

## 1. Tổng quan

Hầu hết các thất bại của AI Agent trông giống như lỗi của mô hình: chọn sai công cụ, truyền sai tham số, hoặc xử lý lỗi không đúng. Nhưng trên thực tế, **mô hình thường đang làm việc với giao diện mà nó được cung cấp**. Vấn đề cốt lõi nằm ở **thiết kế công cụ (tool design)**.

Một mô hình chỉ có thể suy luận từ thông tin được phơi bày qua giao diện công cụ:
- Tên công cụ
- Mô tả công cụ
- Schema tham số
- Mô tả tham số

Những chi tiết đó định hình cách mô hình diễn giải ý định, lập kế hoạch hành động và thực thi tác vụ. Khi thiết kế công cụ không rõ ràng, thiếu hoàn chỉnh, hoặc cấu trúc lỏng lẻo, thất bại trở nên có thể dự đoán trước thay vì ngẫu nhiên.

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Agent Pipeline                         │
│                                                             │
│  User Input → LLM Reasoning → Tool Selection → Execution    │
│                                    ↓                        │
│                           Tool Design Quality               │
│                           (quyết định thành công/thất bại)   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Thiết kế công cụ AI Agent — Cái gì hiệu quả?

### 2.1. Một công cụ, một trách nhiệm (Single Responsibility)

**Nguyên lý**: Mỗi công cụ nên đại diện cho một thao tác duy nhất, rõ ràng.

```python
# ❌ Không hiệu quả: multi-action tool
@tool
def manage_customer(action: str, customer_id: str = None, data: dict = None):
    """action: create | get | update | delete | suspend"""
    ...

# ✅ Hiệu quả: single-responsibility tools
@tool
def create_customer(data: CustomerInput) -> Customer:
    """Create a new customer record."""

@tool
def get_customer(customer_id: str) -> Customer:
    """Retrieve a customer by ID."""

@tool
def suspend_customer(customer_id: str, reason: str) -> SuspensionResult:
    """Suspend a customer account."""
```

**Khi nào ngoại lệ**: Shell, filesystem, browser, calendar tools có thể hưởng lợi từ multi-action interface vì bản thân action space là một phần của abstraction.

### 2.2. Schema chặt chẽ — Loại bỏ trạng thái không hợp lệ

**Nguyên lý**: Dùng Enums, validators, typed fields để encoding constraints ngay trong schema.

```python
from pydantic import BaseModel, Field
from enum import Enum

class Priority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class CreateTaskInput(BaseModel):
    title: str = Field(
        description="Short, actionable task title. Use imperative form.",
        min_length=5, max_length=100
    )
    priority: Priority = Field(
        description="Task priority. Use HIGH only for blockers.",
        default=Priority.MEDIUM
    )
    due_date: str = Field(
        description="Due date in ISO 8601: YYYY-MM-DD.",
        pattern=r"^\d{4}-\d{2}-\d{2}$"
    )
```

```
┌──────────────────────────────────────────────────┐
│            Loose Schema vs Tight Schema           │
│                                                    │
│  Loose: {"param": "any string"}                   │
│    → Model phải đoán constraints                   │
│    → Lỗi chỉ phát hiện ở runtime                   │
│                                                    │
│  Tight: Enum + Regex + MinLength + MaxLength      │
│    → Constraints encoded trong schema              │
│    → Lỗi phát hiện ngay tại tool boundary          │
└──────────────────────────────────────────────────┘
```

### 2.3. Mô tả xác định phạm vi, không chỉ mục đích

**Nguyên lý**: Mô tả tool cần trả lời 2 câu hỏi: (1) Khi nào dùng, (2) Khi nào **không** dùng.

```python
# ❌ Yếu: chỉ giải thích nó làm gì
"""Search for documents in the knowledge base."""

# ✅ Mạnh: định nghĩa purpose, scope, boundaries
"""
Search the internal knowledge base for documents, policies, and reference material.
Use this when the user asks about company procedures, product specs, or documented workflows.
Do NOT use this for real-time data (prices, availability, current status) — use get_live_data() instead.
Returns up to 5 results ranked by relevance. If no results are returned, the information is not in the knowledge base.
"""
```

### 2.4. Error returns có cấu trúc, có thể hành động

**Nguyên lý**: Error cần cho model biết: (1) Có thể retry không? (2) Nên làm gì tiếp theo?

```python
class ToolError(BaseModel):
    error_code: str        # machine-readable
    message: str           # human-readable
    recoverable: bool      # can retry?
    suggested_action: str  # what to do next

# Record not found → retryable
return ToolError(
    error_code="RECORD_NOT_FOUND",
    message="No user record found with ID 'usr_123'.",
    recoverable=True,
    suggested_action="Use list_users() to get valid user IDs."
)

# Quota exceeded → not retryable
return ToolError(
    error_code="QUOTA_EXCEEDED",
    message="API quota reached for today.",
    recoverable=False,
    suggested_action="Notify the user and stop. Do not retry."
)
```

### 2.5. Idempotent operations

**Nguyên lý**: Mọi thao tác ghi phải an toàn khi gọi 2 lần (retry-safe).

```python
@tool
def send_email(to: str, subject: str, body: str,
               idempotency_key: str = Field(
                   description="Unique key. Same key on retry returns original result."
               )) -> dict:
    existing = idempotency_store.get(idempotency_key)
    if existing:
        return existing
    result = email_service.send(to=to, subject=subject, body=body)
    idempotency_store.set(idempotency_key, result, ttl=86400)
    return result
```

---

## 3. Thiết kế công cụ AI Agent — Cái gì không hiệu quả?

### 3.1. Wrapper mỏng quanh API không được lọc

**Vấn đề**: Trỏ agent vào REST API và surface nó như một tool là shortcut phổ biến nhất gây lỗi production.

```python
# ❌ Không hiệu quả: expose toàn bộ API
@tool
def call_api(endpoint: str, params: dict) -> dict:
    """Generic API caller"""
    return requests.get(f"https://api.example.com/{endpoint}", params=params)

# ✅ Hiệu quả: purpose-built wrapper
@tool
def search_products(query: str, category: str = None, max_price: float = None) -> list[Product]:
    """Search products with filters. Handles pagination internally."""
    ...
```

**Tại sao không hiệu quả**:
- API responses có hàng trăm fields, agent chỉ cần vài fields
- API dùng pagination, internal IDs, error codes phức tạp
- Agent phải tự construct API paths, manage pages

### 3.2. Nạp tất cả tools vào mọi context

**Vấn đề**: Accuracy giảm mạnh khi tool catalog lớn. Nghiên cứu LongFuncEval (2025) cho thấy performance drops substantially khi tool count tăng — kể cả với models có 128K context window.

```
Context Window với tất cả tools:
┌──────────────────────────────────────────────────────┐
│ System Prompt (5K tokens)                             │
│ Tool Definitions (50 tools × 500 tokens = 25K tokens) │
│ Conversation History (10K tokens)                      │
│ → Còn rất ít token cho reasoning                      │
└──────────────────────────────────────────────────────┘

Context Window với dynamic loading:
┌──────────────────────────────────────┐
│ System Prompt (5K tokens)             │
│ Relevant Tools Only (3-5 tools)       │
│ Conversation History (10K tokens)     │
│ → Nhiều token cho reasoning           │
└──────────────────────────────────────┘
```

**Giải pháp**: Dynamic tool loading theo step.

```python
STEP_TOOL_MAP = {
    "research": ["search_documents", "search_web", "get_url_content"],
    "write":    ["create_document", "update_document", "format_text"],
    "send":     ["send_email", "post_to_slack", "create_calendar_event"],
}

def get_tools_for_step(step_type: str, available_tools: list) -> list:
    relevant_names = STEP_TOOL_MAP.get(step_type, [])
    return [t for t in available_tools if t.name in relevant_names]
```

### 3.3. Silent partial success

**Vấn đề**: Tool hoàn thành một phần công việc nhưng trả về response có vẻ thành công hoàn toàn.

```python
# ❌ Không hiệu quả: silent failure
@tool
def bulk_create_tasks(tasks: list) -> dict:
    created = []
    for task in tasks:
        try:
            result = task_api.create(task)
            created.append(result.id)
        except Exception:
            pass  # silent failure: đây là bug
    return {"created": created}

# ✅ Hiệu quả: explicit partial success
@tool
def bulk_create_tasks(tasks: list) -> BulkCreateResult:
    created, failed = [], []
    for task in tasks:
        try:
            created.append(task_api.create(task).id)
        except TaskCreationError as e:
            failed.append({"input": task.title, "reason": str(e)})
    return BulkCreateResult(
        created_ids=created,
        failed_items=failed,
        success=len(failed) == 0,
        partial_success=len(created) > 0 and len(failed) > 0
    )
```

### 3.4. Tool names và descriptions trùng lặp

**Vấn đề**: Khi 2 tools làm việc *tương tự*, model phải suy luận để chọn — tiêu tốn tokens và gây lỗi.

```
❌ Các cặp tool dễ gây nhầm lẫn:
  - search_documents vs find_documents
  - get_user vs fetch_user_profile
  - create_task vs add_task vs new_task

✅ Nguyên tắc: Mỗi tool cần một mục đích có thể mô tả
   mà không cần tham chiếu đến tool khác.
   Nếu description cần "unlike X, this one..." → thiết kế có vấn đề.
```

### 3.5. Hành động hủy diệt không có confirmation gate

**Vấn đề**: Tool xóa records, gửi message thật, thực hiện giao dịch tài chính cần 2-step confirmation.

```python
# ✅ Hiệu quả: Two-step staging + confirmation
@tool
def stage_deletion(record_ids: list[str], reason: str) -> StagedDeletion:
    """Stage records for deletion. Does NOT delete anything.
    Returns a confirmation token that expires in 60 seconds."""
    token = generate_deletion_token(record_ids)
    staged_deletions[token] = {"ids": record_ids, "expires": now() + 60}
    return StagedDeletion(token=token, records_to_delete=len(record_ids))

@tool
def confirm_deletion(token: str) -> DeletionResult:
    """Execute a staged deletion. IRREVERSIBLE. Confirm only after user approval."""
    staged = staged_deletions.get(token)
    if not staged or staged["expires"] < now():
        raise ValueError("Token invalid or expired. Stage the deletion again.")
    # proceed with deletion
```

```
┌──────────┐     stage_deletion()     ┌──────────────┐
│  User    │ ──────────────────────→  │   Staged     │
│  Request │                         │  (chờ xác    │
│          │ ←── token + preview ─── │   nhận)      │
│          │                         └──────────────┘
│          │     confirm_deletion()      ↓
│          │ ──────────────────────→  ┌──────────────┐
│          │                         │  Executed    │
└──────────┘                         └──────────────┘
```

---

## 4. Bảng so sánh tổng hợp

| Lĩnh vực thiết kế | Hiệu quả (Works) | Không hiệu quả (Doesn't Work) |
|-------------------|-------------------|-------------------------------|
| **Phạm vi Tool** | Single responsibility | Action-parameter tools như `manage_database(action="create")` |
| **Schema** | Chặt: enums, validators, typed fields | Lỏng: free strings, untyped dicts |
| **Mô tả** | Bao gồm scope boundaries và khi nào *không dùng* | Chỉ happy path |
| **Write Operations** | Idempotent với idempotency keys | Fire-and-forget, không retry safety |
| **Error Returns** | Có cấu trúc: `error_code`, `recoverable`, `suggested_action` | Unhandled exceptions hoặc untyped strings |
| **Số lượng Tool** | Dynamic loading theo step | Tất cả tools trong mọi context |
| **API Wrapping** | Purpose-built wrapper, agent-facing schema | Unfiltered API exposure |
| **Partial Success** | Explicit `partial_success` field | Silent exception swallowing |
| **Hành động hủy diệt** | Two-step staging + confirmation | Single-call delete/send/execute |
| **Tool Overlap** | Semantically distinct, kiểm tra trước deploy | Names và descriptions tương tự cạnh tranh |

---

## 5. Phân loại các mô hình AI & Agentic AI

### 5.1. Phân loại theo khả năng

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PHÂN LOẠI MÔ HÌNH AI                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  📦 MÔ HÌNH NỀN TẢNG (Foundation Models)                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ GPT-4o, Claude 3.5/4, Gemini 2.5, DeepSeek-V3, Llama 4     │   │
│  │ → Đa năng, hiểu ngữ cảnh sâu, tool calling mạnh             │   │
│  │ → Hiệu quả: Khi có thiết kế tool tốt                        │   │
│  │ → Không hiệu quả: Khi tool design lỏng lẻo                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  🔧 MÔ HÌNH CHUYÊN DỤNG (Specialized Models)                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Codex (code), Stable Diffusion (image), Whisper (audio)    │   │
│  │ → Tối ưu cho một tác vụ cụ thể                              │   │
│  │ → Hiệu quả: Trong domain được train                          │   │
│  │ → Không hiệu quả: Ngoài domain chuyên biệt                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  🤖 MÔ HÌNH SUY LUẬN (Reasoning Models)                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ o1, o3, Claude Opus, Gemini Thinking, DeepSeek-R1          │   │
│  │ → Chain-of-thought, tự kiểm tra, tự sửa lỗi                 │   │
│  │ → Hiệu quả: Bài toán logic, toán, lập kế hoạch phức tạp    │   │
│  │ → Không hiệu quả: Task đơn giản (latency cao, cost cao)     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2. Phân loại Agentic AI theo mức độ tự động

| Cấp độ | Tên gọi | Mô tả | Ví dụ |
|--------|---------|-------|-------|
| **L0** | No AI | Không có AI | Rule-based chatbot |
| **L1** | AI Assistant | Trả lời câu hỏi, không hành động | ChatGPT cơ bản |
| **L2** | AI Agent có Tool | Gọi API, truy vấn DB, thao tác file | Claude + Tools |
| **L3** | Multi-Agent | Nhiều agent phối hợp | CrewAI, AutoGen |
| **L4** | Autonomous Agent | Tự lập kế hoạch, tự thực thi, tự sửa lỗi | LangGraph Agent |
| **L5** | Agentic Organization | Hệ thống agent tự vận hành doanh nghiệp | Tương lai |

```
Mức độ tự động hóa tăng dần →
L0 ─→ L1 ─→ L2 ─→ L3 ─→ L4 ─→ L5
↓      ↓      ↓      ↓      ↓      ↓
Không  Chat   Single Multi- Auton- Agentic
có AI  đơn   Agent  Agent  omous  Org
       thuần +Tools        Agent
```

### 5.3. Mô hình nào HIỆU QUẢ?

| Mô hình | Điểm mạnh | Phù hợp cho |
|---------|-----------|-------------|
| **Claude 4 (Opus)** | Tool calling xuất sắc, ít hallucination, tuân thủ schema chặt | Agent production, xử lý tài chính, y tế |
| **GPT-4o** | Đa năng, tốc độ tốt, eco-system lớn | General-purpose agent, customer support |
| **Gemini 2.5 Pro** | Context window 1M+, streaming mạnh | Phân tích dữ liệu lớn, research |
| **DeepSeek-V3/R1** | Cost thấp, reasoning tốt, open-weight | Internal deployment, custom fine-tune |
| **Llama 4 (405B)** | Open-source, có thể self-host | Privacy-sensitive applications |
| **Claude Code / Codex** | Code generation, DB query, file ops | Developer tooling, database management |

### 5.4. Mô hình nào KHÔNG HIỆU QUẢ?

| Mô hình | Lý do không hiệu quả | Khi nào vẫn dùng được |
|---------|---------------------|----------------------|
| **Small LLMs (<7B parameters)** | Tool calling accuracy thấp, dễ hallucination | Task đơn giản, ít tools, có LLM guardrails |
| **Models không được train với tool calling** | Không hiểu định dạng function call | Chỉ dùng cho chat thuần túy |
| **Models không support structured output** | Không thể parse response tin cậy | Cần JSON mode hoặc regex hậu xử lý |
| **Các mô hình cũ (GPT-3.5, Claude 2)** | Không còn được support, accuracy thấp hơn | Thử nghiệm, không dùng production |
| **Fine-tune sai cách** | Catastrophic forgetting, mất khả năng tool calling | Chỉ fine-tune với dữ liệu chất lượng cao |

---

## 6. Các công cụ AI Agent hiệu quả & không hiệu quả

### 6.1. Framework & Platform HIỆU QUẢ

| Công cụ | Loại | Rating | Ưu điểm chính |
|---------|------|--------|---------------|
| **LangChain + LangGraph** | Framework | ⭐⭐⭐⭐⭐ | State graph, persistent memory, tool calling chuẩn |
| **Claude Code** | CLI Agent | ⭐⭐⭐⭐⭐ | Tích hợp sâu với codebase, DB, file system |
| **CrewAI** | Multi-Agent | ⭐⭐⭐⭐ | Dễ dùng, role-based agent, collaboration |
| **AutoGen (Microsoft)** | Multi-Agent | ⭐⭐⭐⭐ | Conversation-driven, flexible |
| **Semantic Kernel (Microsoft)** | Framework | ⭐⭐⭐⭐ | Tích hợp Azure AI, enterprise-ready |
| **MCP (Model Context Protocol)** | Protocol | ⭐⭐⭐⭐⭐ | Chuẩn kết nối AI Agent với tools/database |
| **WrenAI** | Agentic BI | ⭐⭐⭐⭐⭐ | Text-to-SQL, multi-source, governance |
| **WhoDB** | DB Agent | ⭐⭐⭐⭐ | Chat interface cho nhiều DB (Postgres, MySQL, MongoDB) |
| **pgvector** | Extension | ⭐⭐⭐⭐⭐ | Vector search trên PostgreSQL |
| **MongoDB Atlas + LangChain** | Platform | ⭐⭐⭐⭐⭐ | Unified backend: vector + memory + observability |

### 6.2. Framework & Platform KHÔNG HIỆU QUẢ

| Công cụ | Lý do không hiệu quả |
|---------|---------------------|
| **Custom agent tự xây từ API đơn thuần** | Thiếu retry, error handling, state management |
| **ChatGPT Plugins (cũ)** | Không còn được support, bảo mật kém |
| **AutoGPT (phiên bản gốc)** | Loop vô hạn, cost cao, thiếu kiểm soát |
| **BabyAGI (phiên bản gốc)** | Task management đơn giản, dễ lặp vô hạn |
| **Tool không có idempotency** | Gây duplicate actions, data corruption khi retry |
| **Tool không có structured error** | Model không biết nên retry hay放弃, dẫn đến hành vi không xác định |
| **Wrapper API generic** | Agent bị overwhelmed bởi API surface quá lớn |

### 6.3. Ma trận đánh giá công cụ

```
                    HIỆU QUẢ CAO
                        ↑
                        │
    WrenAI ●──────────● LangGraph
            │    ● Claude Code
    WhoDB   │    ● MCP Protocol
            │
────────────┼──────────────────────────→ DỄ DÙNG
            │
    AutoGPT │    ● ChatGPT Plugins
    BabyAGI │    ● Custom API Wrapper
            │
            │    ● Tool không idempotent
                        ↓
                 KHÔNG HIỆU QUẢ
```

---

## 7. AI Agent kết hợp với Database — Nguyên lý cốt lõi

> **Nguồn tham khảo chính**: Trần Quốc Huy (WecommitAI) — "AI Agent kết hợp với Database"  
> **Luận điểm**: AI chỉ "chat" thì khó tạo lợi thế. Lợi thế thật nằm ở **tri thức – quy trình – dữ liệu nội bộ** của doanh nghiệp.

### 7.1. Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────────────────┐
│                      AI Agent + Database                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐     ┌──────────┐     ┌──────────────────────┐     │
│  │  User    │────→│  LLM     │────→│   Tool Layer         │     │
│  │  Input   │     │  (Agent) │     │   ┌──────────────┐   │     │
│  └──────────┘     └──────────┘     │   │ Schema       │   │     │
│                        │           │   │ Inspector    │   │     │
│                        │           │   └──────────────┘   │     │
│                        │           │   ┌──────────────┐   │     │
│                        │           │   │ SQL Generator│   │     │
│                        ↓           │   └──────────────┘   │     │
│                   ┌──────────┐     │   ┌──────────────┐   │     │
│                   │ Response │     │   │ Query        │   │     │
│                   │   +      │     │   │ Executor     │   │     │
│                   │ Result   │     │   └──────────────┘   │     │
│                   └──────────┘     └──────────┬───────────┘     │
│                                               │                 │
│                                               ↓                 │
│                                   ┌──────────────────────┐     │
│                                   │    Database Layer     │     │
│                                   │  ┌────────────────┐   │     │
│                                   │  │ PostgreSQL     │   │     │
│                                   │  │ + pgvector     │   │     │
│                                   │  ├────────────────┤   │     │
│                                   │  │ MySQL/MariaDB  │   │     │
│                                   │  ├────────────────┤   │     │
│                                   │  │ MongoDB Atlas  │   │     │
│                                   │  ├────────────────┤   │     │
│                                   │  │ Oracle DB      │   │     │
│                                   │  └────────────────┘   │     │
│                                   └──────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2. Nguyên lý 4 bước (WecommitAI)

#### Bước 1: Khoanh vùng Schema

Agent cần hiểu **cấu trúc database** trước khi có thể truy vấn. Không nên expose toàn bộ schema.

```sql
-- Hiệu quả: Agent chỉ thấy relevant tables
CREATE VIEW agent_customers AS
SELECT id, name, email, status, created_at
FROM customers
WHERE deleted_at IS NULL;

-- Không hiệu quả: Agent thấy toàn bộ columns (kể cả internal)
-- SELECT * FROM customers; → exposed 50 columns, agent bị nhiễu
```

**Nguyên tắc**:
- Expose schema qua information_schema nhưng **giới hạn** theo role
- Dùng views thay vì tables trực tiếp
- Document relationships giữa các tables

#### Bước 2: Chọn đúng bảng/cột

Tool mô tả cần hướng dẫn agent chọn đúng schema object.

```python
@tool
def describe_schema(domain: str) -> list[TableSchema]:
    """
    Describe database tables relevant to a business domain.
    Use this before generating any SQL query.
    
    Domains:
    - "sales": orders, order_items, customers, products
    - "inventory": products, warehouses, stock_movements
    - "support": tickets, ticket_comments, agents
    
    Returns table names, column names, types, and foreign keys.
    """
    allowed_tables = DOMAIN_MAP.get(domain, [])
    return get_schema_for_tables(allowed_tables)
```

#### Bước 3: Sinh SQL

Text-to-SQL là bước quan trọng nhất. Cần:

```python
@tool
def generate_sql(natural_query: str, domain: str) -> SQLResult:
    """
    Generate and execute SQL from natural language.
    
    Rules:
    1. Always use parameterized queries (prevent SQL injection)
    2. Limit results to 100 rows by default
    3. Never use DROP, DELETE, UPDATE, INSERT without explicit user confirmation
    4. Use EXPLAIN before running complex queries
    5. Return both SQL and results
    
    Do NOT use this for:
    - Schema inspection (use describe_schema instead)
    - Data modification without confirmation
    """
    schema = describe_schema(domain)
    sql = llm.generate_sql(natural_query, schema)
    
    # Safety check
    if is_destructive(sql):
        return SQLResult(error="Destructive queries require confirmation", 
                        requires_confirmation=True)
    
    # Execute with EXPLAIN first
    explain = db.execute(f"EXPLAIN {sql}")
    if explain.cost > THRESHOLD:
        return SQLResult(error="Query too expensive", explain=explain)
    
    result = db.execute(sql, limit=100)
    return SQLResult(sql=sql, result=result)
```

#### Bước 4: Trả kết quả có cấu trúc

```python
class SQLResult(BaseModel):
    sql: str = Field(description="The generated SQL query")
    result: list[dict] = Field(description="Query results")
    row_count: int = Field(description="Number of rows returned")
    truncated: bool = Field(description="True if results exceed limit")
    execution_time_ms: float = Field(description="Query execution time")
    explanation: str = Field(description="Plain English summary of the query")
```

### 7.3. Các loại Database và cách tích hợp

#### PostgreSQL + pgvector

**Khi nào hiệu quả**:
- Cần cả structured data + vector search trong 1 database
- ACID compliance cho transactional data
- Extension phong phú (pgvector, pg_stat_statements, postgis)

```sql
-- Kết hợp SQL + Vector Search
SELECT p.id, p.name, p.price,
       p.embedding <=> query_embedding AS similarity
FROM products p
WHERE p.category = 'electronics'
  AND p.price BETWEEN 100 AND 1000
ORDER BY similarity
LIMIT 10;
```

**Công cụ hỗ trợ**: pgvectorscale, pgai (AI functions trong DB), pgml (machine learning)

#### MongoDB Atlas + LangChain

**Khi nào hiệu quả**:
- JSON-like documents, schema linh hoạt
- Vector search + operational data unified
- Persistent memory cho AI Agent (Checkpointer)

```javascript
// MongoDB Atlas Vector Search
db.products.aggregate([
  {
    $vectorSearch: {
      index: "product_index",
      queryVector: embedding,
      path: "embedding",
      numCandidates: 100,
      limit: 10,
      filter: { category: "electronics" }
    }
  },
  {
    $project: {
      name: 1, price: 1,
      similarity: { $meta: "vectorSearchScore" }
    }
  }
]);
```

#### MySQL / MariaDB

**Khi nào hiệu quả**:
- Hệ thống cũ (legacy) cần AI Agent truy vấn
- Chi phí thấp, eco-system rộng
- Tương thích cao với các ứng dụng PHP (như AVideo)

**Hạn chế**: Vector search chưa native (cần plugin hoặc external)

#### Oracle Database

**Khi nào hiệu quả**:
- Enterprise, ngân hàng, tài chính
- AI Vector Search (23c+)
- Bảo mật, auditing, multi-tenant

### 7.4. Ba loại Memory cho AI Agent

Một trong những ứng dụng quan trọng nhất của database trong AI Agent là **persistent memory**.

```
┌─────────────────────────────────────────────────────────────┐
│               THREE TYPES OF AGENT MEMORY                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📝 EPISODIC MEMORY (Ký ức sự kiện)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Lưu: conversation turns, tool calls, API results    │   │
│  │ DB: PostgreSQL hypertable (time-series)             │   │
│  │ Query: "What did we discuss yesterday?"             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  🧠 SEMANTIC MEMORY (Ký ức ngữ nghĩa)                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Lưu: embeddings, knowledge graph, patterns          │   │
│  │ DB: pgvector, MongoDB Atlas, Neo4j                  │   │
│  │ Query: "Find similar cases to this problem"         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ⚙️ PROCEDURAL MEMORY (Ký ức thủ tục)                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Lưu: user preferences, workflows, rules             │   │
│  │ DB: Standard relational tables (ACID)               │   │
│  │ Query: "What format does the user prefer for exports?"│  │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.5. MCP — Model Context Protocol

MCP là chuẩn do Anthropic phát triển, cho phép AI Agent kết nối an toàn với database và các hệ thống bên ngoài.

```
┌──────────────────────────────────────────────────────┐
│              MCP Architecture                         │
│                                                       │
│  ┌──────────┐          ┌──────────────────────┐      │
│  │   Host   │          │   MCP Server          │      │
│  │ (Claude, │ ←─MCP──→ │   ┌────────────────┐ │      │
│  │  IDE)    │ Protocol  │   │ PostgreSQL     │ │      │
│  └──────────┘          │   │ Server         │ │      │
│                        │   ├────────────────┤ │      │
│                        │   │ MySQL Server   │ │      │
│                        │   ├────────────────┤ │      │
│                        │   │ File System    │ │      │
│                        │   │ Server         │ │      │
│                        │   └────────────────┘ │      │
│                        └──────────────────────┘      │
└──────────────────────────────────────────────────────┘
```

**Lợi ích của MCP**:
- **Parameterized queries**: Chống SQL injection
- **Tool annotations**: Mark write operations as destructive
- **Audit logging**: Mọi query đều được log
- **Row-level security (RLS)**: Agent chỉ truy cập dữ liệu được phép

### 7.6. Safety Patterns cho Agent + Database

| Pattern | Mô tả | Implement |
|---------|-------|-----------|
| **Read-Only by Default** | Agent chỉ được SELECT, cần confirmation cho write | `GRANT SELECT ON ... TO agent_role` |
| **Query Cost Limit** | Chặn query quá expensive | `EXPLAIN` + threshold check |
| **Row Limit** | Không cho phép SELECT không giới hạn | `LIMIT 100` mặc định |
| **Parameterized Query** | Chống SQL injection | Prepared statements |
| **Schema Restriction** | Chỉ expose relevant tables/views | Database views + schema filtering |
| **Time-bounded Execution** | Query chạy quá lâu bị kill | `SET statement_timeout = '30s'` |
| **Human-in-the-Loop** | Write operations cần xác nhận | Two-step confirmation |
| **Audit Trail** | Mọi query đều được log | `pgaudit` hoặc application logging |

---

## 8. Agentic BI — Tương lai của Business Intelligence

### 8.1. Text-to-SQL truyền thống vs Agentic BI

```
Text-to-SQL truyền thống:
┌──────────┐    ┌──────────┐    ┌──────────┐
│  User    │───→│  LLM     │───→│  SQL     │
│  Question│    │  (one-   │    │  Result  │
│          │    │  shot)   │    │          │
└──────────┘    └──────────┘    └──────────┘
    ↓                              ↓
  Thiếu context                  Không có
  (không biết schema)            giải thích

Agentic BI:
┌──────────┐    ┌────────────────────────────┐    ┌──────────┐
│  User    │───→│  AI Agent                   │───→│  Insight │
│  Question│    │  ┌──────────────────────┐   │    │  + Viz   │
│          │    │  │ 1. Schema Discovery  │   │    │  + Report│
│          │    │  │ 2. Query Planning    │   │    └──────────┘
│          │    │  │ 3. SQL Generation    │   │
│          │    │  │ 4. Result Analysis   │   │
│          │    │  │ 5. Visualization     │   │
│          │    │  │ 6. Self-Correction   │   │
│          │    │  └──────────────────────┘   │
│          │    └────────────────────────────┘
└──────────┘
```

### 8.2. WrenAI — Open Source Agentic BI

WrenAI là một trong những công cụ Agentic BI hàng đầu (15K stars).

**Kiến trúc**:
```
┌──────────────────────────────────────────────────┐
│                   WrenAI                          │
├──────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  │
│  │ Semantic    │  │ Text-to-SQL │  │ Chart   │  │
│  │ Layer       │  │ Engine      │  │ Builder │  │
│  ├─────────────┤  ├─────────────┤  ├─────────┤  │
│  │ Business    │  │ Multi-turn  │  │ Auto    │  │
│  │ Definitions │  │ Correction  │  │ Dashboard│  │
│  └─────────────┘  └─────────────┘  └─────────┘  │
├──────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────┐    │
│  │  20+ Data Sources                        │    │
│  │  PostgreSQL │ MySQL │ BigQuery │ Snowflake│   │
│  │  ClickHouse │ MongoDB │ REST API │ ...    │   │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
```

**Tính năng nổi bật**:
- Semantic Layer: ánh xạ business terms vào database schema
- Governance: kiểm soát ai được hỏi gì
- Multi-turn: hỏi tiếp nếu kết quả chưa đúng
- Visualization: tự động tạo chart

### 8.3. Ứng dụng thực tế cho Doanh nghiệp

| Tình huống | Agent truyền thống | Agent + Database | Lợi thế |
|------------|-------------------|------------------|----------|
| "Doanh số Q1?" | Trả lời chung chung | Truy vấn thực tế database → số chính xác | Dữ liệu thật, real-time |
| "Khách hàng nào sắp hết hạn hợp đồng?" | Không biết, không có access | JOIN 3 tables → danh sách cụ thể | Hành động được |
| "Phân tích xu hướng bán hàng" | Trả lời lý thuyết | Aggregate + time-series → trend charts | Có căn cứ dữ liệu |
| "Tối ưu query nào đang chậm?" | Không biết | pg_stat_statements → phân tích | Performance thật |

---

## 9. Kiến trúc tham khảo

### 9.1. Kiến trúc AI Agent + PostgreSQL (Multi-Database)

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRODUCTION ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    APPLICATION LAYER                      │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │  API Gateway (FastAPI / Express / ...)              │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    AGENT LAYER                            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐   │   │
│  │  │  Claude  │  │  GPT-4o  │  │  Open Source (Llama) │   │   │
│  │  │  Agent   │  │  Agent   │  │  Agent (Self-hosted) │   │   │
│  │  └──────────┘  └──────────┘  └──────────────────────┘   │   │
│  │         │            │                    │              │   │
│  │         └────────────┴────────────────────┘              │   │
│  │                        │                                  │   │
│  │  ┌──────────────────────────────────────────────────┐    │   │
│  │  │           Tool Registry (MCP Compatible)         │    │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌────────────────┐  │    │   │
│  │  │  │ Schema   │ │ SQL     │ │ Report         │  │    │   │
│  │  │  │ Inspector│ │ Executor│ │ Generator      │  │    │   │
│  │  │  └──────────┘ └──────────┘ └────────────────┘  │    │   │
│  │  └──────────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    DATA LAYER                             │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐    │   │
│  │  │           PostgreSQL / YugabyteDB                 │    │   │
│  │  │                                                   │    │   │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  │    │   │
│  │  │  │ Episodic    │  │ Semantic    │  │ Proced. │  │    │   │
│  │  │  │ Memory      │  │ Memory     │  │ Memory  │  │    │   │
│  │  │  │ (hypertable)│  │ (pgvector) │  │ (relat) │  │    │   │
│  │  │  └─────────────┘  └─────────────┘  └─────────┘  │    │   │
│  │  └──────────────────────────────────────────────────┘    │   │
│  │                                                          │   │
│  │  ┌──────────────────┐  ┌──────────────────┐              │   │
│  │  │ MySQL / MariaDB  │  │ MongoDB Atlas    │              │   │
│  │  │ (Legacy Apps)    │  │ (Documents + Vec)│              │   │
│  │  └──────────────────┘  └──────────────────┘              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2. AVideo + AI Agent Integration Pattern

Áp dụng cho platform AVideo đang triển khai:

```
┌─────────────────────────────────────────────────────────────────┐
│              AVideo + AI Agent Architecture                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User (Web/Mobile)                                              │
│       │                                                         │
│       ↓                                                         │
│  ┌──────────────────┐                                           │
│  │   AVideo Site    │  Apache (PHP)                             │
│  │   (media.cloud   │                                           │
│  │    .edu.vn)      │                                           │
│  └────────┬─────────┘                                           │
│           │                                                     │
│  ┌────────┴─────────┐  ┌──────────────────────┐                │
│  │   MariaDB        │  │   AI Agent Layer     │                │
│  │   (avideo DB)    │  │   (Python/LangGraph) │                │
│  │                  │←─│                      │                │
│  │  - users         │  │  Text-to-SQL Tool    │                │
│  │  - videos        │  │  Video Analytics     │                │
│  │  - live_servers  │  │  Report Generation   │                │
│  │  - plugins       │  │  Auto Moderation     │                │
│  └──────────────────┘  └──────────────────────┘                │
│           │                                                     │
│  ┌────────┴─────────┐                                           │
│  │   Nginx RTMP     │  Live Streaming                          │
│  │   (1935/8080/    │                                           │
│  │    8443)         │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Kết luận

### 10.1. Tóm tắt các nguyên lý cốt lõi

1. **Tool design quyết định thành công của AI Agent**, không phải model capability
2. **Single responsibility** cho mỗi tool, schema chặt chẽ với enums/validators
3. **Mô tả tool** phải bao gồm scope boundaries và khi nào **không** dùng
4. **Structured error** với `error_code`, `recoverable`, `suggested_action`
5. **Idempotency** cho mọi write operations
6. **Dynamic tool loading** thay vì nạp tất cả tools
7. **Explicit partial success** — không silent failure
8. **Confirmation gate** cho destructive actions
9. **Database là trái tim của AI Agent** — persistent memory, structured query
10. **Agentic BI** thay thế Text-to-SQL truyền thống với multi-step reasoning

### 10.2. Lộ trình áp dụng cho Doanh nghiệp

```
Giai đoạn 1: Chat với Database (Basic Text-to-SQL)
  → Single tool, single model, simple schema
  → Ví dụ: "Doanh số tháng trước?"

Giai đoạn 2: AI Agent với Database Tools
  → Multiple tools (schema inspect + SQL gen + analyze)
  → Memory, error handling, retry
  → Ví dụ: "Phân tích doanh số theo region, so sánh với cùng kỳ năm ngoái"

Giai đoạn 3: Multi-Agent BI System
  → Agent Orchestrator + Specialist Agents
  → Persistent memory + knowledge graph
  → Ví dụ: "Tạo báo cáo tự động hàng tuần, gửi email, kèm dashboard"

Giai đoạn 4: Autonomous Agentic Organization
  → Hệ thống agent tự vận hành
  → Tự phát hiện vấn đề, tự đề xuất giải pháp
  → Ví dụ: "Phát hiện doanh số giảm → phân tích nguyên nhân → đề xuất hành động"
```

### 10.3. Tham khảo thêm

| Tài nguyên | Link |
|------------|------|
| AI Agent Tool Design (Bài gốc) | https://machinelearningmastery.com/ai-agent-tool-design-what-works-and-what-doesnt/ |
| AI Agent + Database (WecommitAI) | https://www.youtube.com/watch?v=Kau_TcdGMEc |
| MCP Protocol | https://modelcontextprotocol.io |
| LangGraph Documentation | https://langchain-ai.github.io/langgraph/ |
| WrenAI (Agentic BI) | https://github.com/Canner/WrenAI |
| pgvector | https://github.com/pgvector/pgvector |
| MongoDB AI Integrations | https://www.mongodb.com/docs/atlas/ai-integrations/ |
| Anthropic Writing Tools for Agents | https://www.anthropic.com/engineering/writing-tools-for-agents |
| LLM Agents and PostgreSQL 2026 | https://postgresqlhtx.com/llm-agents-and-postgresql-in-2026/ |

---

> **Tác giả**: PhD Lê Toàn Thắng  
> **Cập nhật**: Tháng 6, 2026  
> **Phiên bản**: 1.0  
> **Giấy phép**: CC BY-NC 4.0  
> **Dự án**: media.cloud.edu.vn — AVideo Platform & AI Agent Integration
