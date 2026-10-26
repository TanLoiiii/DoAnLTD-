# 📱 Sổ Tay Quản Lý Chi Tiêu Cá Nhân (Personal Expense Tracker)

Ứng dụng quản lý tài chính & chi tiêu cá nhân được thiết kế vận hành theo kiến trúc **Offline-First**, kết hợp đồng bộ hóa đám mây **MongoDB Atlas** linh hoạt. Giao diện hiện đại, trực quan, hỗ trợ đầy đủ trên nền tảng **Mobile (Android)** và Web/Desktop.

---

## 🌟 Các Chức Năng Cốt Lõi

### 1. 💳 Quản Lý Giao Dịch
- **Thêm nhanh giao dịch**: Phân loại rõ ràng giữa **Khoản Chi (Expense)** và **Khoản Thu (Income)**.
- **Chi tiết giao dịch**: Nhập số tiền (hiển thị trực tiếp định dạng VND), ghi chú/mục đích, chọn ngày giao dịch (DatePicker), chọn danh mục tương ứng.
- **Chỉnh sửa & Xóa**: Chạm vào giao dịch để chỉnh sửa thông tin hoặc xóa nhanh với hộp thoại xác nhận bảo vệ dữ liệu.

### 2. 📊 Bảng Điều Khiển Tổng Quan (Dashboard)
- **Thẻ Số dư Tháng này**: Hiển thị số dư thuần (Thu nhập - Chi tiêu) với màu sắc trực quan (xanh khi dương, đỏ khi âm).
- **Thẻ Tổng Thu & Tổng Chi**: Tóm tắt dòng tiền trong tháng được chọn.
- **Bộ chuyển tháng**: Dễ dàng xem lại số liệu các tháng trước hoặc tháng kế tiếp.
- **Danh sách giao dịch gần nhất (Recent Transactions)**: Hiển thị 6 giao dịch mới nhất kèm danh mục, màu sắc, số tiền và nút chuyển nhanh đến trang sổ giao dịch.
- **Trạng thái kết nối**: Hiển thị huy hiệu trực tiếp `Atlas Online` hoặc `Offline Mode`.

### 3. 📈 Báo Cáo & Thống Kê Chuyên Sâu
- **Biểu đồ tròn (PieChart)**: Phân tích cơ cấu chi tiêu theo từng danh mục (hiển thị tỷ lệ phần trăm % và màu sắc đại diện tương tác chạm).
- **Bộ lọc chu kỳ thời gian**: Chuyển đổi linh hoạt giữa **Theo Tuần Này** và **Theo Tháng Này**.
- **Bảng xếp hạng tốn kém nhất (Top Spending Categories)**:
  - Xếp hạng từ Top 1 trở đi với huy hiệu vàng, bạc, đồng.
  - Thanh tiến trình phần trăm (Progress bar) trực quan.
  - Hiển thị tổng số tiền và tỷ lệ % trên tổng chi tiêu.

### 4. 🗂️ Quản Lý Danh Mục Thu & Chi
- **Hệ thống danh mục mặc định**:
  - *Chi tiêu*: Ăn uống, Mua sắm, Di chuyển, Hóa đơn & Tiện ích, Giải trí, Y tế & Sức khỏe, Giáo dục, Chi tiêu khác...
  - *Thu nhập*: Tiền lương, Thưởng & Tiền boa, Đầu tư & Lãi suất, Kinh doanh, Thu nhập khác...
- **Tùy chỉnh danh mục mới**: Cho phép người dùng tự đặt tên danh mục, chọn biểu tượng trong thư viện **22+ icons** và chọn mã màu sắc từ bảng màu phong phú.
- **Chỉnh sửa & Xóa danh mục tùy chỉnh**.

### 5. 🔍 Tìm Kiếm & Bộ Lọc Nâng Cao
- **Tra cứu từ khóa nhanh**: Tìm kiếm theo nội dung ghi chú hoặc tên danh mục.
- **Lọc theo loại giao dịch**: Tất cả / Chỉ khoản chi / Chỉ khoản thu.
- **Bộ lọc nâng cao (Collapsible Filter)**:
  - Lọc theo **khoảng tiền** (Từ số tiền tối thiểu đến số tiền tối đa).
  - Lọc theo **danh mục cụ thể**.
  - Lọc theo **khoảng thời gian (Date Range Picker)**.
- **Thống kê tức thì**: Tự động hiển thị số lượng giao dịch tìm thấy cùng tổng thu/chi của kết quả lọc.

### 6. ⚙️ Tiện Ích Hệ Thống & Kiểm Thử
- **Định dạng tiền tệ**: Chuẩn Việt Nam Đồng (`150.000 ₫`, `22.000.000 ₫`).
- **Giao diện Tối/Sáng (Dark / Light Mode)**: Chuyển đổi mượt mà với theme Material 3 tối ưu cho mắt ban đêm.
- **Đồng bộ đám mây MongoDB Atlas**:
  - Chuỗi kết nối cấu hình sẵn: `cluster0.w5jeoln.mongodb.net/expense_tracker`.
  - Nút **Đồng bộ ngay** để đẩy/kéo dữ liệu lên đám mây.
  - Hỗ trợ đổi Connection String linh hoạt.
- **Công cụ kiểm thử (Testing Tools)**:
  - 🔄 **Nạp dữ liệu mẫu (Sample Data)**: Tự động tạo 10 giao dịch thực tế để kiểm tra biểu đồ và thống kê ngay lập tức.
  - 🗑️ **Xóa trắng dữ liệu (Clear All Data)**: Xóa toàn bộ dữ liệu trên máy và MongoDB Atlas để reset hệ thống về ban đầu phục vụ chấm bài/kiểm thử.

---

## 🛠️ Cấu Trúc Mã Nguồn

```text
lib/
├── main.dart                          # Khởi chạy ứng dụng, Theme Material 3, NavigationBar
├── models/
│   ├── category_model.dart            # Model Danh mục, Icon, Màu sắc, Danh mục mặc định
│   └── transaction_model.dart         # Model Giao dịch thu/chi, ánh xạ JSON/BSON
├── providers/
│   └── expense_provider.dart          # Quản lý State, tính toán thống kê, bộ lọc, đồng bộ
├── services/
│   ├── mongodb_service.dart           # Kết nối MongoDB Atlas (mongo_dart), đồng bộ dữ liệu
│   └── storage_service.dart           # Lưu trữ cục bộ SharedPreferences (Offline-First)
├── utils/
│   └── currency_formatter.dart        # Định dạng tiền tệ VND (₫), ngày tháng dd/MM/yyyy
├── widgets/
│   ├── stat_card.dart                 # Thẻ số dư, tổng thu, tổng chi trên Dashboard
│   └── transaction_item.dart          # Item giao dịch dạng Card với menu Sửa/Xóa
└── screens/
    ├── dashboard_screen.dart          # Màn hình Bảng điều khiển tổng quan
    ├── transactions_screen.dart       # Màn hình Sổ giao dịch, Tìm kiếm & Bộ lọc
    ├── reports_screen.dart            # Màn hình Báo cáo, Biểu đồ tròn PieChart, BXH
    ├── categories_screen.dart         # Màn hình Quản lý danh mục (Thu / Chi)
    ├── settings_screen.dart           # Màn hình Cài đặt, Dark Mode, Đồng bộ & Kiểm thử
    ├── add_edit_transaction_screen.dart # Form Thêm / Sửa giao dịch
    └── add_edit_category_dialog.dart  # Dialog Tạo / Sửa danh mục tùy chọn màu & icon
```

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

### Yêu cầu:
- Đã cài đặt Flutter SDK (`>= 3.13.0`).

### 1. Cài đặt các gói phụ thuộc:
```bash
flutter pub get
```

### 2. Kiểm tra chất lượng mã nguồn:
```bash
flutter analyze
```

### 3. Chạy ứng dụng:
- **Trên thiết bị Android hoặc Giả lập**:
  ```bash
  flutter run
  ```
- **Trên Google Chrome (kiểm tra nhanh trên máy tính)**:
  ```bash
  flutter run -d chrome
  ```

### 4. Đóng gói file cài đặt APK cho điện thoại Android:
```bash
flutter build apk --release
```
File APK xuất xưởng sẽ nằm tại thư mục: `build/app/outputs/flutter-apk/app-release.apk`.
