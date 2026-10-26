import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showClearDataConfirmation(BuildContext context) {
    final provider = context.read<ExpenseProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.redAccent, size: 48),
        title: const Text('Xác nhận xóa trắng dữ liệu'),
        content: const Text(
          'Thao tác này sẽ xóa toàn bộ các giao dịch và đưa danh mục về mặc định (trên cả bộ nhớ máy và MongoDB Atlas) để phục vụ kiểm thử.\n\nBạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa trắng toàn bộ dữ liệu kiểm thử!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('XÓA TRẮNG DỮ LIỆU',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMongoConfigDialog(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final controller =
        TextEditingController(text: provider.mongoService.currentUri);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình MongoDB Atlas'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập chuỗi kết nối MongoDB Connection String (Atlas / Local):',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUri = controller.text;
              Navigator.pop(ctx);
              await provider.updateMongoUri(newUri);
              final ok = await provider.manualSyncMongo();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Kết nối MongoDB thành công!'
                        : 'Không thể kết nối MongoDB Atlas.'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Lưu & Kết nối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiện Ích & Cài Đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Mục Giao diện & Trải nghiệm
          _buildSectionHeader('GIAO DIỆN & HIỂN THỊ', theme),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: Colors.indigo,
                    ),
                  ),
                  title: const Text('Giao diện Tối (Dark Mode)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(provider.isDarkMode
                      ? 'Đang bật chế độ ban đêm'
                      : 'Đang dùng chế độ sáng'),
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleDarkMode(),
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.attach_money_rounded,
                        color: Colors.green),
                  ),
                  title: const Text('Định dạng tiền tệ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Việt Nam Đồng (VND - ₫)'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '₫  VND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cơ sở dữ liệu MongoDB Atlas
          _buildSectionHeader('CƠ SỞ DỮ LIỆU MONGODB ATLAS', theme),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (provider.mongoService.isConnected
                                  ? Colors.green
                                  : Colors.orange)
                              .withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_sync_rounded,
                          color: provider.mongoService.isConnected
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.mongoService.isConnected
                                  ? 'Đã kết nối MongoDB Atlas'
                                  : 'Chế độ Ngoại tuyến (Offline-First)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.syncStatusMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dữ liệu luôn được lưu an toàn trên máy (offline) và tự động đồng bộ lên Atlas Cloud.',
                            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showMongoConfigDialog(context),
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('Chuỗi kết nối'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final ok = await provider.manualSyncMongo();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Đã đồng bộ thành công với MongoDB Atlas!'
                                      : 'Đồng bộ thất bại. Vui lòng kiểm tra internet!'),
                                  backgroundColor:
                                      ok ? Colors.green : Colors.orange,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync, size: 16),
                          label: const Text('Đồng bộ ngay'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quản lý Dữ liệu Kiểm thử (Test Utilities)
          _buildSectionHeader('CÔNG CỤ KIỂM THỬ HỆ THỐNG', theme),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.playlist_add_check_rounded,
                        color: Colors.blue),
                  ),
                  title: const Text('Nạp dữ liệu mẫu (Sample Data)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Tạo 10 giao dịch mẫu phong phú để kiểm tra biểu đồ và thống kê'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await provider.loadSampleData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã nạp bộ dữ liệu mẫu thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_sweep_rounded,
                        color: Colors.redAccent),
                  ),
                  title: const Text('Xóa trắng dữ liệu (Clear Data)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      )),
                  subtitle: const Text(
                      'Xóa toàn bộ giao dịch để bắt đầu kiểm thử lại từ đầu'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                  onTap: () => _showClearDataConfirmation(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Thông tin ứng dụng
          Center(
            child: Column(
              children: [
                Text(
                  'Sổ tay Quản lý Chi tiêu Cá nhân',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phiên bản 1.0.0 • Offline-First + MongoDB Atlas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
