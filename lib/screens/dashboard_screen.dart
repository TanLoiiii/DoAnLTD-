import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stat_card.dart';
import '../widgets/transaction_item.dart';
import 'add_edit_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sổ Quản Lý Chi Tiêu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Trạng thái kết nối MongoDB
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Tooltip(
                message: provider.syncStatusMessage,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: provider.mongoService.isConnected
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.mongoService.isConnected
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: provider.mongoService.isConnected
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.mongoService.isConnected
                            ? 'Atlas Online'
                            : 'Offline Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: provider.mongoService.isConnected
                              ? Colors.green
                              : Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.manualSyncMongo(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Bộ chọn Tháng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: provider.previousMonth,
                      tooltip: 'Tháng trước',
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            size: 18, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.formatFullMonthYear(
                              provider.selectedMonth),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: provider.nextMonth,
                      tooltip: 'Tháng sau',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Thẻ Số dư tổng quan (Large Stat Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatCard(
                title: 'SỐ DƯ THÁNG NÀY',
                amount: provider.netBalanceForSelectedMonth,
                icon: Icons.account_balance_wallet_rounded,
                color: provider.netBalanceForSelectedMonth >= 0
                    ? Colors.blueAccent
                    : Colors.redAccent,
                isLarge: true,
              ),
            ),

            const SizedBox(height: 12),

            // 2 Thẻ Tổng thu & Tổng chi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Tổng Thu',
                      amount: provider.totalIncomeForSelectedMonth,
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Tổng Chi',
                      amount: provider.totalExpenseForSelectedMonth,
                      icon: Icons.arrow_downward_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tiêu đề Danh sách Giao dịch Gần nhất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToTransactions,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Xem tất cả'),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Danh sách các giao dịch gần nhất
            if (provider.recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có giao dịch nào trong sổ.',
                        style: TextStyle(color: theme.disabledColor),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEditTransactionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm giao dịch đầu tiên'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...provider.recentTransactions.map(
                (tx) => TransactionItem(
                  transaction: tx,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditTransactionScreen(initialTransaction: tx),
                      ),
                    );
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: Text(
                            'Bạn có chắc chắn muốn xóa giao dịch "${tx.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteTransaction(tx.id);
                              Navigator.pop(ctx);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
