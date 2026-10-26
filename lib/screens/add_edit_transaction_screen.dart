import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTransaction;

  const AddEditTransactionScreen({super.key, this.initialTransaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  late String _selectedType;
  CategoryModel? _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;
    if (init != null) {
      _selectedType = init.type;
      _amountController.text = init.amount.toStringAsFixed(0);
      _titleController.text = init.title;
      _selectedDate = init.date;
    } else {
      _selectedType = 'expense';
      _selectedDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory == null) {
      final provider = context.read<ExpenseProvider>();
      final categories = _selectedType == 'expense'
          ? provider.expenseCategories
          : provider.incomeCategories;

      if (widget.initialTransaction != null) {
        final match = provider.categories.where(
          (c) => c.id == widget.initialTransaction!.categoryId,
        );
        _selectedCategory = match.isNotEmpty
            ? match.first
            : (categories.isNotEmpty ? categories.first : null);
      } else {
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      final provider = context.read<ExpenseProvider>();
      final categories = newType == 'expense'
          ? provider.expenseCategories
          : provider.incomeCategories;
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'CHỌN NGÀY GIAO DỊCH',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một danh mục!')),
      );
      return;
    }

    final amount = CurrencyFormatter.parseDouble(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền phải lớn hơn 0 ₫!')),
      );
      return;
    }

    final provider = context.read<ExpenseProvider>();
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : _selectedCategory!.name;

    final isEditing = widget.initialTransaction != null;
    final transaction = TransactionModel(
      id: isEditing
          ? widget.initialTransaction!.id
          : 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      categoryIconCode: _selectedCategory!.iconCodePoint,
      categoryColorValue: _selectedCategory!.colorValue,
      date: _selectedDate,
      createdAt: isEditing ? widget.initialTransaction!.createdAt : DateTime.now(),
    );

    if (isEditing) {
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Đã cập nhật giao dịch thành công!'
              : 'Đã thêm giao dịch mới!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final isEditing = widget.initialTransaction != null;

    final availableCategories = _selectedType == 'expense'
        ? provider.expenseCategories
        : provider.incomeCategories;

    if (_selectedCategory == null && availableCategories.isNotEmpty) {
      if (widget.initialTransaction != null) {
        final match = provider.categories.where(
          (c) => c.id == widget.initialTransaction!.categoryId,
        );
        _selectedCategory =
            match.isNotEmpty ? match.first : availableCategories.first;
      } else {
        _selectedCategory = availableCategories.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Giao Dịch' : 'Thêm Giao Dịch Mới'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Bộ chọn Chi tiêu / Thu nhập
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onTypeChanged('expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'expense'
                              ? Colors.redAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                color: _selectedType == 'expense'
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Khoản Chi (Tiêu)',
                                style: TextStyle(
                                  color: _selectedType == 'expense'
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onTypeChanged('income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == 'income'
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                color: _selectedType == 'income'
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Khoản Thu (Vào)',
                                style: TextStyle(
                                  color: _selectedType == 'income'
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
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
            ),

            const SizedBox(height: 24),

            // Nhập số tiền
            Text(
              'Số tiền (VND)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: _selectedType == 'expense'
                    ? Colors.redAccent
                    : Colors.green,
              ),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '₫',
                suffixStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              onChanged: (val) {
                setState(() {});
              },
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                final numVal = CurrencyFormatter.parseDouble(val);
                if (numVal <= 0) {
                  return 'Số tiền phải lớn hơn 0';
                }
                return null;
              },
            ),
            if (_amountController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Định dạng: ${CurrencyFormatter.formatVND(CurrencyFormatter.parseDouble(_amountController.text))}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Ghi chú / Tiêu đề
            Text(
              'Ghi chú / Mục đích',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'VD: Mua quà sinh nhật, Cà phê sáng...',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),

            const SizedBox(height: 20),

            // Chọn Ngày
            Text(
              'Ngày giao dịch',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Text(
                      CurrencyFormatter.formatDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Danh mục
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh mục ${_selectedType == 'expense' ? 'chi tiêu' : 'thu nhập'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedCategory != null)
                  Text(
                    'Đang chọn: ${_selectedCategory!.name}',
                    style: TextStyle(
                      color: _selectedCategory!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lưới danh mục
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableCategories.map((category) {
                final isSelected = _selectedCategory?.id == category.id;
                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: category.color.withOpacity(0.2),
                    child: Icon(
                      category.icon,
                      size: 16,
                      color: category.color,
                    ),
                  ),
                  label: Text(category.name),
                  selected: isSelected,
                  selectedColor: category.color.withOpacity(0.25),
                  labelStyle: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                        : null,
                  ),
                  side: BorderSide(
                    color: isSelected ? category.color : Colors.transparent,
                    width: 1.5,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            // Nút Lưu
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == 'expense'
                    ? Colors.redAccent
                    : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Text(
                isEditing ? 'CẬP NHẬT GIAO DỊCH' : 'LƯU GIAO DỊCH',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
