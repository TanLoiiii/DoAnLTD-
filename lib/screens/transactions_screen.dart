import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_item.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  bool _showAdvancedFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _openDateRangePicker(ExpenseProvider provider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: provider.filterDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      helpText: 'CHỌN KHOẢNG THỜI GIAN',
      cancelText: 'HỦY',
      confirmText: 'ÁP DỤNG',
    );
    if (picked != null) {
      provider.setFilterDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final transactions = provider.filteredTransactions;

    // Tổng thu / chi của bộ lọc hiện tại
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Giao Dịch'),
        actions: [
          IconButton(
            icon: Icon(
              _showAdvancedFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showAdvancedFilters ? theme.colorScheme.primary : null,
            ),
            tooltip: 'Bộ lọc nâng cao',
            onPressed: () {
              setState(() {
                _showAdvancedFilters = !_showAdvancedFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm nhanh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo ghi chú hoặc danh mục...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchKeyword('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                provider.setSearchKeyword(value);
              },
            ),
          ),

          // Bộ lọc Loại (Tất cả / Khoản chi / Khoản thu)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: provider.filterType == 'all',
                  onSelected: (selected) {
                    if (selected) provider.setFilterType('all');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Khoản Chi (-)'),
                  selected: provider.filterType == 'expense',
                  selectedColor: Colors.redAccent.withOpacity(0.25),
                  onSelected: (selected) {
                    if (selected) provider.setFilterType('expense');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Khoản Thu (+)'),
                  selected: provider.filterType == 'income',
                  selectedColor: Colors.green.withOpacity(0.25),
                  onSelected: (selected) {
                    if (selected) provider.setFilterType('income');
                  },
                ),
                if (provider.filterCategoryId != null ||
                    provider.filterMinAmount != null ||
                    provider.filterMaxAmount != null ||
                    provider.filterDateRange != null) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.close, size: 16),
                    label: const Text('Xóa bộ lọc'),
                    onPressed: () {
                      _minAmountController.clear();
                      _maxAmountController.clear();
                      provider.clearFilters();
                    },
                  ),
                ],
              ],
            ),
          ),

          // Khu vực Bộ lọc nâng cao (Accordion / Collapsible)
          if (_showAdvancedFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bộ lọc nâng cao',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Lọc theo Khoảng tiền
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Số tiền tối thiểu',
                            suffixText: '₫',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed =
                                val.isEmpty ? null : CurrencyFormatter.parseDouble(val);
                            provider.setFilterAmountRange(
                                parsed, provider.filterMaxAmount);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Số tiền tối đa',
                            suffixText: '₫',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed =
                                val.isEmpty ? null : CurrencyFormatter.parseDouble(val);
                            provider.setFilterAmountRange(
                                provider.filterMinAmount, parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Lọc theo Danh mục & Khoảng thời gian
                  Row(
                    children: [
                      // Chọn danh mục
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: provider.filterCategoryId,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Danh mục',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả danh mục'),
                            ),
                            ...provider.categories.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(c.icon, size: 16, color: c.color),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          c.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                          onChanged: (val) {
                            provider.setFilterCategoryId(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Chọn ngày
                      ElevatedButton.icon(
                        onPressed: () => _openDateRangePicker(provider),
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          provider.filterDateRange == null
                              ? 'Chọn ngày'
                              : '${provider.filterDateRange!.start.day}/${provider.filterDateRange!.start.month} - ${provider.filterDateRange!.end.day}/${provider.filterDateRange!.end.month}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Tóm tắt kết quả bộ lọc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} giao dịch tìm thấy',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Row(
                  children: [
                    if (totalIncome > 0)
                      Text(
                        '+${CurrencyFormatter.formatVND(totalIncome)}  ',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (totalExpense > 0)
                      Text(
                        '-${CurrencyFormatter.formatVND(totalExpense)}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách các giao dịch
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy giao dịch nào phù hợp.',
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionItem(
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
                                  'Bạn có chắc muốn xóa giao dịch "${tx.title}"?'),
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
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTransactionScreen(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        tooltip: 'Thêm giao dịch mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
