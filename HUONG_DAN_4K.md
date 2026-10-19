# Hướng Dẫn Cấu Hình Và Chạy AirPlay 4K 60FPS Cho Máy Mới (UxPlay Windows)

Tài liệu này hướng dẫn chi tiết cách thiết lập một máy tính Windows mới để có thể nhận phản chiếu màn hình (AirPlay Screen Mirroring) từ iPhone / iPad / Mac với chất lượng **4K 60fps (chuẩn mã hóa HEVC/H.265)** tương tự như cấu hình chuẩn trên máy này.

---

## 1. Cơ Chế Hoạt Động Của Chế Độ 4K

Trên phiên bản này, chế độ 4K đạt được nhờ sự kết hợp của:
1. **Mã hóa HEVC / H.265 (`-h265`)**: Nén video băng thông cao hiệu quả gấp đôi so với H.264, cho phép truyền tải độ phân giải 3840x2160 mà không bị nghẽn mạng.
2. **Độ phân giải & Tần số quét (`-s 3840x2160@60 -fps 60 -vsync no`)**: Khai báo với thiết bị Apple để xuất luồng 4K ở 60 khung hình/giây và tắt vsync nhằm giảm độ trễ (latency) tối đa.
3. **Bộ dựng hình phần cứng Direct3D 11 (`-vs d3d11videosink`)**: Sử dụng trực tiếp GPU (card đồ họa) để giải mã và hiển thị video mượt mà, không gây quá tải cho CPU.

---

## 2. Yêu Cầu Hệ Thống Cho Máy Mới

* **Hệ điều hành**: Windows 10 hoặc Windows 11 (64-bit).
* **Phần cứng**:
  * GPU hỗ trợ giải mã phần cứng HEVC/H.265 10-bit (Intel HD Graphics 520 / Core Gen 6 trở lên, NVIDIA GTX 950/1050 trở lên, hoặc AMD Radeon RX 400 trở lên).
  * RAM tối thiểu 8GB.
* **Mạng (Rất quan trọng cho 4K)**:
  * Máy tính và thiết bị iOS/macOS phải kết nối **cùng một mạng LAN/Wi-Fi**.
  * **Khuyên dùng**: Cắm dây mạng LAN (Ethernet) cho PC và kết nối iPhone/iPad vào băng tần Wi-Fi **5GHz** hoặc **Wi-Fi 6**. Băng tần 2.4GHz thường không đủ băng thông cho 4K 60fps.

---

## 3. Cài Đặt Dịch Vụ Bonjour (Bắt Buộc)

AirPlay sử dụng giao thức mDNS (Multicast DNS / Bonjour) để thiết bị Apple tìm thấy máy tính trong mạng nội bộ. Nếu máy mới chưa có Bonjour, iPhone sẽ không nhìn thấy tên máy tính.

### Cách 1: Tải bộ cài chính thức từ Apple (Khuyên Dùng)
1. Tải bộ cài **Bonjour Print Services for Windows v2.0.2** trực tiếp từ Apple:
   * Link tải Apple: [https://support.apple.com/kb/DL999](https://support.apple.com/kb/DL999)
   *(Hoặc nếu máy đã cài ứng dụng iTunes từ file exe của Apple thì dịch vụ Bonjour đã có sẵn)*.
2. Cài đặt file `BonjourPSSetup.exe`.
3. Kiểm tra dịch vụ đã hoạt động bằng lệnh PowerShell:
   ```powershell
   Get-Service "Bonjour Service"
   ```
   Nếu trạng thái là `Running` là đã hoàn tất.

### Cách 2: Sử dụng mDNSResponder có sẵn trong repo / thư mục phát hành
Nếu không muốn cài Bonjour của Apple, mở **Command Prompt (Run as Administrator)** và gõ:
```cmd
cd /d "ĐƯỜNG_DẪN_TỚI_THƯ_MỤC_CHỨA_FILE"
mDNSResponder.exe -install
```

---

## 4. Mở Cổng Tường Lửa (Windows Firewall)

Nếu tường lửa chặn cổng mạng, thiết bị Apple sẽ không tìm thấy hoặc kết nối sẽ bị đứt giữa chừng.

Mở **PowerShell (Run as Administrator)** và dán các lệnh sau:
```powershell
# Cho phép uxplay nhận kết nối mạng riêng (Private Network)
New-NetFirewallRule -DisplayName "UxPlay AirPlay Receiver" -Direction Inbound -Program "C:\path\to\uxplay-windows.exe" -Action Allow -Profile Private,Domain

# Mở các cổng AirPlay tiêu chuẩn (AirPlay Streaming & Bonjour Discovery)
New-NetFirewallRule -DisplayName "UxPlay Ports TCP" -Direction Inbound -LocalPort 7000,7001,7100,5000 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "UxPlay Ports UDP" -Direction Inbound -LocalPort 5353,6000,6001,7011 -Protocol UDP -Action Allow
```

---

## 5. Cài Đặt Môi Trường Chạy Cho Máy Mới

Bạn có 2 lựa chọn để triển khai trên máy mới:

### Cách A: Dùng Thư Mục Release Đóng Gói (Portable - Nhanh Nhất)
Nếu bạn copy thư mục đã build hoàn chỉnh (thư mục chứa đầy đủ các file DLL như `Qt6Core.dll`, `avcodec-62.dll`, GStreamer plugins...):
1. Copy toàn bộ thư mục đó sang máy mới (ví dụ đặt tại `D:\ios_win`).
2. Copy 2 file batch `run_4k.bat` và `run_uxplay.bat` vào cùng thư mục đó.
3. Nhấp đúp chuột vào `run_4k.bat` để chạy ngay.

### Cách B: Cài Đặt Môi Trường Build Nguồn (MSYS2 UCRT64 - Giống máy hiện tại)
Nếu máy mới cần tự build hoặc chạy trực tiếp thư mục `build\uxplay-windows.exe`:
1. Tải và cài đặt **MSYS2** tại đường dẫn mặc định `C:\msys64`: [https://www.msys2.org/](https://www.msys2.org/)
2. Mở terminal **MSYS2 UCRT64** và chạy lệnh sau để cài đặt toàn bộ thư viện:
   ```bash
   pacman -S --needed \
     mingw-w64-ucrt-x86_64-cmake \
     mingw-w64-ucrt-x86_64-gcc \
     mingw-w64-ucrt-x86_64-libplist \
     mingw-w64-ucrt-x86_64-json-glib \
     mingw-w64-ucrt-x86_64-gstreamer \
     mingw-w64-ucrt-x86_64-gst-plugins-base \
     mingw-w64-ucrt-x86_64-gst-libav \
     mingw-w64-ucrt-x86_64-gst-plugins-good \
     mingw-w64-ucrt-x86_64-gst-plugins-bad \
     mingw-w64-ucrt-x86_64-qt6-base \
     mingw-w64-ucrt-x86_64-ninja
   ```
3. Sau khi build xong ra file `build\uxplay-windows.exe`, file `run_4k.bat` sẽ tự động liên kết biến môi trường `PATH=C:\msys64\ucrt64\bin;%PATH%` để nạp các DLL.

---

## 6. Thiết Lập File Batch Tự Động Hóa Chạy 4K

Repo đã được tích hợp sẵn file batch **`run_4k.bat`** tại thư mục gốc.

### File `run_4k.bat` hoạt động như thế nào?
1. **Tự động kích hoạt Profile 4K**: Ghi giá trị vào Windows Registry của người dùng:
   * `stream_profile` = `hevc4k`
   * `renderer_mode` = `d3d11`
   * `ble_enabled` = `true`
2. **Tự nạp MSYS2 DLL**: Nhận diện nếu máy có cài `C:\msys64\ucrt64\bin` để tự bổ sung vào PATH.
3. **Tự quét vị trí thực thi**: Tìm kiếm `uxplay-windows.exe` ở `build\`, `release\` hoặc ngay thư mục hiện tại.
4. **Kiểm tra trạng thái Bonjour**: Nếu dịch vụ Bonjour chưa chạy, file batch sẽ cảnh báo để bạn xử lý.

### Cách sử dụng:
* Chỉ cần **nhấp đúp vào `run_4k.bat`**.
* Ứng dụng sẽ khởi chạy thu nhỏ dưới khay hệ thống (System Tray).

### Tự động khởi động cùng Windows:
1. Nhấn tổ hợp phím `Win + R`, gõ `shell:startup` và nhấn Enter.
2. Tạo shortcut của file `run_4k.bat` và dán vào thư mục Startup này.

---

## 7. Sử Dụng & Kết Nối Trên Thiết Bị Apple

1. Trên máy tính Windows, đảm bảo ứng dụng đang chạy (icon hình tam giác/play màu xanh ở góc phải thanh Taskbar).
2. Trên iPhone / iPad:
   * Vuốt mở **Trung tâm điều khiển (Control Center)**.
   * Chọn nút **Phản chiếu màn hình (Screen Mirroring)**.
   * Chọn tên máy tính của bạn (tên mặc định được lấy theo tên máy Windows, ví dụ: `RIBIAS-DAT` hoặc `AirPlay - <TenMay>`).
3. Nhấn **`Alt + Enter`** trên bàn phím Windows để bật/tắt chế độ toàn màn hình (Fullscreen).
4. Để tùy chỉnh: Nhấp chuột phải vào icon ở khay hệ thống (System Tray) -> Chọn **Settings**:
   * **Streaming Profile**: Đảm bảo là `HEVC / 4K (Experimental)`.
   * **Video Renderer**: Đảm bảo là `D3D11`.

---

## 8. Bảng Tham Số Kỹ Thuật (Dành Cho Cấu Hình Thủ Công)

Nếu bạn cấu hình qua file `%APPDATA%\leapbtw\uxplay-windows\arguments.txt` hoặc chế độ Custom:

| Tham số | Ý nghĩa |
| :--- | :--- |
| `-n <Ten>` | Đặt tên hiển thị AirPlay Receiver |
| `-nh` | Không thêm mã hex ngẫu nhiên vào đuôi tên |
| `-h265` | Bật giải mã chuẩn video HEVC / H.265 cho 4K |
| `-s 3840x2160@60` | Yêu cầu độ phân giải 3840x2160 ở tần số 60 FPS |
| `-fps 60` | Khóa tốc độ khung hình ở 60 FPS |
| `-vsync no` | Tắt đồng bộ vsync để giảm thiểu tối đa độ trễ hình |
| `-vs d3d11videosink` | Sử dụng Direct3D 11 Video Sink để GPU hiển thị hình ảnh mượt mà |

---

## 9. Khắc Phục Lỗi Thường Gặp (Troubleshooting)

1. **iPhone không tìm thấy máy tính**:
   * Kiểm tra xem Bonjour Service có đang chạy không: `sc query "Bonjour Service"`.
   * Đảm bảo iPhone và PC đang kết nối cùng một router mạng và không bật chế độ "AP Isolation" / "Guest Network".
   * Thử tắt và bật lại Wi-Fi trên iPhone.
2. **Hình ảnh bị giật, lag hoặc đơ**:
   * Đổi router Wi-Fi sang băng tần **5GHz** hoặc cắm cáp mạng LAN cho PC.
   * Đảm bảo card đồ họa đã cài driver mới nhất để hỗ trợ giải mã phần cứng HEVC.
   * Trong giao diện Settings, kiểm tra Video Renderer đang ở `D3D11` thay vì Auto.
3. **Báo lỗi thiếu DLL (Missing dll)**:
   * Nếu chạy từ build MSYS2: Hãy đảm bảo chạy qua `run_4k.bat` hoặc đã thêm `C:\msys64\ucrt64\bin` vào biến môi trường hệ thống PATH.
   * Nếu chạy bản Portable: Đảm bảo không xóa bất kỳ file `.dll` nào trong thư mục.
