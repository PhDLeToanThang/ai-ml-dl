# Hướng dẫn Cài đặt & Tối ưu KNIME Analytics Platform trên Windows Server 2022

**Cấu hình máy:** Windows Server 2022 DC (32GB RAM, 16 vCPU, 128GB SSD C: + 200GB SSD D:)

---

## Mục lục

- [0. Tình huống thực tế](#0-tình-huống-thực-tế)
- [1. Yêu cầu Hệ thống](#1-yêu-cầu-hệ-thống)
- [2. Tải & Cài đặt](#2-tải--cài-đặt)
- [3. Chuyển Workspace ra ổ D: cho nhiều Users](#3-chuyển-workspace-ra-ổ-d-cho-nhiều-users)
- [4. Tối ưu knime.ini cho 32GB RAM / 16 vCPU](#4-tối-ưu-knimeini-cho-32gb-ram--16-vcpu)
- [5. Tối ưu Windows Server 2022](#5-tối-ưu-windows-server-2022)
- [6. Extensions cần thiết](#6-extensions-cần-thiết)
- [7. Verify cấu hình](#7-verify-cấu-hình)
- [8. Tối ưu Workflow cho Server](#8-tối-ưu-workflow-cho-server)
- [9. Script tổng hợp — chạy 1 lần](#9-script-tổng-hợp--chạy-1-lần)
- [10. Quy trình tóm tắt cho Admin](#10-quy-trình-tóm-tắt-cho-admin)

---

## 0. Tình huống thực tế

| Thông tin | Giá trị |
|---|---|
| KNIME đã cài | Cho All Users tại `C:\Program Files\KNIME` |
| Workspace hiện tại | `C:\Users\Administrator\knime-workspace` |
| Số user chưa tạo | 20 users — chưa có profile, chưa có workspace |
| Ổ C: | 128GB SSD — OS + KNIME code |
| Ổ D: | 200GB SSD — sẽ dùng cho workspace của tất cả users |

**Mục tiêu:** Mỗi user khi đăng nhập lần đầu sẽ tự động có workspace riêng trên D:\. Không cần cấu hình tay cho từng user.

```
D:\KNIME_Workspaces\
  ├── Administrator\knime-workspace\    ← admin
  ├── user1\knime-workspace\            ← user 1
  ├── user2\knime-workspace\            ← user 2
  └── ...
```

---

## 1. Yêu cầu Hệ thống

| Thành phần | Yêu cầu | Máy bạn |
|---|---|---|
| HĐH | Windows Server 2016/2019/2022 | ✅ WS 2022 DC |
| RAM | 4GB (khuyến nghị 8GB+) | ✅ 32GB |
| CPU | Đa lõi | ✅ 16 vCPU |
| Ổ cứng | 500MB+ cho KNIME | ✅ 128GB SSD (C:) + 200GB SSD (D:) |
| Java | JRE 17 (64-bit) — đi kèm KNIME | ✅ Tự động |

---

## 2. Tải & Cài đặt

### 2.1 Tải

Từ https://www.knime.com/downloads, chọn bản **Windows (64-bit) Installer (.exe)**.

### 2.2 Cài đặt đồ họa (GUI)

1. Chạy file `.exe`
2. Chọn **Install for anyone using this computer** (All Users)
3. Thư mục đích: `C:\Program Files\KNIME` (mặc định)
4. Màn hình **Memory Settings**: nhập `16384` (sẽ tinh chỉnh lại ở mục 4)
5. Hoàn tất

### 2.3 Silent Install (cho automation)

```powershell
.\knime-x.x.x-installer-win-x86_64.exe /S /D=C:\Program Files\KNIME
```

---

## 3. Chuyển Workspace ra ổ D: cho nhiều Users

### 3.1 Vấn đề

- `knime.ini` dùng chung cho All Users → không thể set workspace cố định
- Workspace mặc định: `C:\Users\%USERNAME%\knime-workspace`
- 20 users x ~2GB data = 40GB trên ổ C: 128GB → nhanh đầy

### 3.2 Giải pháp: Shortcut + Login Script

**Cơ chế:**

| Thành phần | Vai trò |
|---|---|
| Shortcut trên Public Desktop | Dùng biến `%USERNAME%` trong tham số `-data` để trỏ workspace xuống D:\ |
| Task Scheduler | Chạy script PowerShell mỗi khi user logon, tự động tạo thư mục workspace nếu chưa có |

### 3.3 Bước 1 — Tạo shortcut (chạy 1 lần với Admin)

```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\KNIME Analytics Platform.lnk")
$Shortcut.TargetPath = "C:\Program Files\KNIME\knime.exe"
$Shortcut.Arguments = '-data "D:\KNIME_Workspaces\%USERNAME%\knime-workspace"'
$Shortcut.WorkingDirectory = "D:\KNIME_Workspaces\%USERNAME%"
$Shortcut.Description = "KNIME Analytics Platform"
$Shortcut.Save()
```

> `%USERNAME%` là biến môi trường Windows — tự động thay bằng tên user đang đăng nhập. Shortcut đặt ở `C:\Users\Public\Desktop` để tất cả users đều thấy.

### 3.4 Bước 2 — Tạo login script `D:\KNIME_Workspaces\create-workspace.ps1`

```powershell
$workspaceRoot = "D:\KNIME_Workspaces"
$username = $env:USERNAME
$userWorkspace = Join-Path $workspaceRoot "$username\knime-workspace"

if (-not (Test-Path $userWorkspace)) {
    New-Item -ItemType Directory -Force -Path $userWorkspace | Out-Null
}
```

### 3.5 Bước 3 — Đăng ký Task Scheduler (chạy 1 lần với Admin)

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File D:\KNIME_Workspaces\create-workspace.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "Users" -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "KNIME-CreateWorkspace" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
```

### 3.6 Luồng hoạt động

```
1. User đăng nhập lần đầu → Windows tạo profile
2. Task Scheduler chạy create-workspace.ps1
3. Script phát hiện workspace chưa có → tự động tạo:
   D:\KNIME_Workspaces\{username}\knime-workspace\
4. User click shortcut KNIME trên Desktop
5. KNIME mở đúng workspace riêng trên D:\
```

### 3.7 Cấu trúc thư mục cuối cùng

```
C:\ (128GB SSD)
  ├── Windows Server 2022
  ├── Program Files\KNIME\
  └── Users\{từng user}\...        ← profile, không chứa workspace

D:\ (200GB SSD)
  └── KNIME_Workspaces\
       ├── Administrator\knime-workspace\
       ├── user1\knime-workspace\
       ├── user2\knime-workspace\
       └── ...
```

---

## 4. Tối ưu knime.ini cho 32GB RAM / 16 vCPU

**File cấu hình:** `C:\Program Files\KNIME\knime.ini` (dùng chung cho tất cả users)

### 4.1 Phân bổ RAM

| Thành phần | RAM |
|---|---|
| OS + ứng dụng nền | ~8GB |
| KNIME Java Heap (`-Xmx`) | **16GB** (16384m) |
| KNIME Metaspace + ngoài heap | ~4GB |
| Dự phòng | ~4GB |
| **Tổng** | **32GB** |

> **Tại sao 16GB thay vì 20GB?** Nếu nhiều user cùng chạy KNIME trên server này, để 16GB an toàn. Nếu chỉ 1-2 người dùng, có thể đẩy lên 20GB.

### 4.2 Các tham số đã thêm vào knime.ini

```ini
-Xmx16384m
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:ParallelGCThreads=8
-XX:ConcGCThreads=4
-XX:G1HeapRegionSize=16m
-XX:MetaspaceSize=512m
-XX:MaxMetaspaceSize=1g
```

> ✅ File `C:\Program Files\KNIME\knime.ini` **đã được cập nhật** các tham số này.

### 4.3 Giải thích tham số JVM

| Tham số | Giá trị | Tác dụng |
|---|---|---|
| `-Xmx` | 16384m | Heap tối đa 16GB — phù hợp 32GB RAM |
| `-XX:+UseG1GC` | — | G1 Garbage Collector — tốt nhất cho heap lớn, latency thấp |
| `-XX:MaxGCPauseMillis` | 200 | Giới hạn tạm dừng GC ≤ 200ms |
| `-XX:ParallelGCThreads` | 8 | Số thread GC song song (50% của 16 vCPU) |
| `-XX:ConcGCThreads` | 4 | Số thread GC đồng thời |
| `-XX:G1HeapRegionSize` | 16m | Kích thước vùng G1 — tối ưu xử lý data lớn |
| `-XX:MetaspaceSize` | 512m | Metaspace khởi tạo |
| `-XX:MaxMetaspaceSize` | 1g | Metaspace tối đa |

### 4.4 Cấu hình Performance trong KNIME

**File → Preferences → KNIME → General → Performance:**

| Tùy chọn | Giá trị |
|---|---|
| Number of used cores for parallel execution | `8` |
| Number of rows held in memory for table display | `50000` |
| Maximum number of rows per chunk | `50000` |
| Enable streaming execution for large data | ✅ Bật |

**File → Preferences → KNIME → General → Workspace:**

| Tùy chọn | Giá trị |
|---|---|
| Refresh workspace automatically | ✅ Bật |

---

## 5. Tối ưu Windows Server 2022

### 5.1 Power Plan

```powershell
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  # High Performance
powercfg /hibernate off                                       # Giải phóng dung lượng C:
```

### 5.2 Hiệu ứng đồ họa

```powershell
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
```

### 5.3 Antivirus Exclusions

```powershell
Add-MpPreference -ExclusionPath "C:\Program Files\KNIME"
Add-MpPreference -ExclusionPath "D:\KNIME_Workspaces"
```

---

## 6. Extensions cần thiết

| Extension | Mục đích |
|---|---|
| **Python Integration** | Chạy Python scripts trong KNIME |
| **Power BI Integration** | Push dữ liệu lên Power BI dataset |
| **Database** | Kết nối SQL Server, PostgreSQL... |
| **Reporting** | Tạo báo cáo PDF/HTML |

Extensions cài cho All Users → mọi user đều dùng được.

```powershell
& "C:\Program Files\KNIME\knime.exe" -application org.eclipse.equinox.p2.director -repository "https://update.knime.com/analytics-platform/5.11" -installIU "org.knime.features.python.feature.group,org.knime.features.powerbi.feature.group"
```

---

## 7. Verify cấu hình

```powershell
# Liệt kê extensions đã cài
& "C:\Program Files\KNIME\knime.exe" -nosplash -application org.eclipse.equinox.p2.director -listInstalledRoots

# Kiểm tra JVM heap
wmic process where "name='knime.exe'" get CommandLine | findstr Xmx
```

Trong KNIME: **Help → About KNIME Analytics Platform → Installation Details → Configuration** → tìm `-Xmx` → phải là `16384m`.

---

## 8. Tối ưu Workflow cho Server

| Kỹ thuật | Mô tả |
|---|---|
| **Chunk-based processing** | Dùng Row Splitter + Loops thay vì load all-in-memory |
| **Database push-down** | Đẩy xử lý xuống SQL Server thay vì kéo dữ liệu về |
| **Parallel execution** | Dùng Parallel Chunk End node, set 8 threads |
| **Streamable nodes** | Ưu tiên nodes có flag "Streamable" |
| **Tắt visualization khi batch** | Bỏ Bar Chart, Scatter Plot khi chạy workflow không cần UI |

---

## 9. Script tổng hợp — chạy 1 lần

Script này làm tất cả các bước trên tự động. **Chạy với Administrator quyền.**

```powershell
# ============ KNIME SETUP FOR WS2022 - MULTI-USER ============
# Chạy 1 lần duy nhất với Administrator

Write-Host "=== Bắt đầu cấu hình KNIME multi-user ===" -ForegroundColor Cyan

# 1. Power & OS
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /hibernate off
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
Write-Host "✅ Power plan + OS settings" -ForegroundColor Green

# 2. Antivirus exclusion
Add-MpPreference -ExclusionPath "C:\Program Files\KNIME" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "D:\KNIME_Workspaces" -ErrorAction SilentlyContinue
Write-Host "✅ Antivirus exclusions" -ForegroundColor Green

# 3. Tạo thư mục gốc workspaces trên D:
New-Item -ItemType Directory -Force -Path "D:\KNIME_Workspaces" | Out-Null
Write-Host "✅ D:\KNIME_Workspaces created" -ForegroundColor Green

# 4. Tạo shortcut trên Public Desktop
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\KNIME Analytics Platform.lnk")
$Shortcut.TargetPath = "C:\Program Files\KNIME\knime.exe"
$Shortcut.Arguments = '-data "D:\KNIME_Workspaces\%USERNAME%\knime-workspace"'
$Shortcut.WorkingDirectory = "D:\KNIME_Workspaces\%USERNAME%"
$Shortcut.Description = "KNIME Analytics Platform"
$Shortcut.Save()
Write-Host "✅ Shortcut created (Public Desktop)" -ForegroundColor Green

# 5. Tạo login script
$scriptContent = @'
$workspaceRoot = "D:\KNIME_Workspaces"
$username = $env:USERNAME
$userWorkspace = Join-Path $workspaceRoot "$username\knime-workspace"
if (-not (Test-Path $userWorkspace)) {
    New-Item -ItemType Directory -Force -Path $userWorkspace | Out-Null
}
'@
$scriptContent | Out-File -FilePath "D:\KNIME_Workspaces\create-workspace.ps1" -Encoding UTF8
Write-Host "✅ Login script created" -ForegroundColor Green

# 6. Đăng ký Task Scheduler
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File D:\KNIME_Workspaces\create-workspace.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "Users" -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "KNIME-CreateWorkspace" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force
Write-Host "✅ Task Scheduler registered (runs at logon)" -ForegroundColor Green

Write-Host ""
Write-Host "========= HOÀN TẤT =========" -ForegroundColor Yellow
Write-Host "📌 knime.ini: Xmx16384m + G1GC" -ForegroundColor Cyan
Write-Host "📌 Workspace: tự tạo ở D:\KNIME_Workspaces\<username>\ khi user logon" -ForegroundColor Cyan
Write-Host "📌 Shortcut: C:\Users\Public\Desktop\KNIME Analytics Platform.lnk" -ForegroundColor Cyan
```

---

## 10. Quy trình tóm tắt cho Admin

```
Bước 1: [ĐÃ XONG]  Cài KNIME for All Users tại C:\Program Files\KNIME
Bước 2: [ĐÃ XONG]  Sửa knime.ini — Xmx16384m + G1GC + 8 threads
Bước 3: [CẦN LÀM]  Chạy Script tổng hợp (mục 9) — 1 lần, Admin quyền
Bước 4: [CẦN LÀM]  Tạo 20 users trong AD hoặc Local Users and Groups
Bước 5: [TỰ ĐỘNG]  User đăng nhập lần đầu → workspace tự tạo trên D:\
Bước 6: [TỰ ĐỘNG]  User click shortcut KNIME → dùng workspace riêng ngay lập tức
```

---

## Tổng kết

| Vấn đề | Giải pháp | Trạng thái |
|---|---|---|
| 20 users chưa có profile | Task Scheduler tự tạo workspace khi user logon lần đầu | ✅ Tự động |
| Workspace tránh ổ C: 128GB | Shortcut dùng `-data D:\KNIME_Workspaces\%USERNAME%\knime-workspace` | ✅ Tự động |
| RAM 32GB | `-Xmx16384m` (16GB heap) | ✅ Đã set |
| vCPU 16 | ParallelGCThreads=8, KNIME cores=8 | ✅ Đã set |

---

*Tham khảo: [KNIME Installation Guide](https://docs.knime.com/ap/latest/analytics_platform_installation_guide/), [KNIME Performance Optimization](https://www.knime.com/blog/optimizing-knime-workflows-for-performance), [Windows Server 2022 Performance Tuning](https://www.apachelounge.com/download/contr/Perf-tun-srv-2022.pdf)*
