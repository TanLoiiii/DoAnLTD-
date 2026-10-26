// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final CategoryModel? initialCategory;
  final String defaultType;

  const AddEditCategoryDialog({
    super.key,
    this.initialCategory,
    this.defaultType = 'expense',
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _nameController = TextEditingController();
  late String _type;
  late int _selectedColor;
  late int _selectedIconCode;

  // Danh sách các Icon phổ biến cho người dùng chọn
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.shopping_bag,
    Icons.directions_car,
    Icons.receipt_long,
    Icons.sports_esports,
    Icons.medical_services,
    Icons.school,
    Icons.flight,
    Icons.fitness_center,
    Icons.pets,
    Icons.local_cafe,
    Icons.home,
    Icons.local_gas_station,
    Icons.celebration,
    Icons.card_giftcard,
    Icons.account_balance_wallet,
    Icons.trending_up,
    Icons.storefront,
    Icons.savings,
    Icons.work,
    Icons.payments,
    Icons.category,
  ];

  // Danh sách màu sắc đẹp mắt
  final List<int> _availableColors = [
    0xFFFF5722, // Deep Orange
    0xFFE91E63, // Pink
    0xFF9C27B0, // Purple
    0xFF673AB7, // Deep Purple
    0xFF3F51B5, // Indigo
    0xFF2196F3, // Blue
    0xFF03A9F4, // Light Blue
    0xFF00BCD4, // Cyan
    0xFF009688, // Teal
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFFC107, // Amber
    0xFFFF9800, // Orange
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialCategory;
    if (init != null) {
      _nameController.text = init.name;
      _type = init.type;
      _selectedColor = init.colorValue;
      _selectedIconCode = init.iconCodePoint;
    } else {
      _type = widget.defaultType;
      _selectedColor = _availableColors[0];
      _selectedIconCode = _availableIcons[0].codePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục!')),
      );
      return;
    }

    final provider = context.read<ExpenseProvider>();
    final isEditing = widget.initialCategory != null;

    final category = CategoryModel(
      id: isEditing
          ? widget.initialCategory!.id
          : 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _type,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColor,
      isDefault: isEditing ? widget.initialCategory!.isDefault : false,
    );

    if (isEditing) {
      provider.updateCategory(category);
    } else {
      provider.addCategory(category);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialCategory != null;

    return AlertDialog(
      title: Text(isEditing ? 'Sửa Danh Mục' : 'Tạo Danh Mục Mới'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn loại danh mục
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Chi tiêu')),
                      selected: _type == 'expense',
                      selectedColor: Colors.redAccent.withOpacity(0.25),
                      onSelected: (selected) {
                        if (selected) setState(() => _type = 'expense');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Thu nhập')),
                      selected: _type == 'income',
                      selectedColor: Colors.green.withOpacity(0.25),
                      onSelected: (selected) {
                        if (selected) setState(() => _type = 'income');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Xem trước Icon & Màu
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Color(_selectedColor).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(_selectedColor), width: 2),
                  ),
                  child: Icon(
                    IconData(_selectedIconCode, fontFamily: 'MaterialIcons'),
                    color: Color(_selectedColor),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tên danh mục
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên danh mục',
                  hintText: 'VD: Du lịch, Thú cưng, Học tập...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // Chọn màu sắc
              Text(
                'Chọn màu sắc',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((colorVal) {
                  final isSelected = _selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorVal),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorVal).withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Chọn icon
              Text(
                'Chọn biểu tượng (Icon)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = _selectedIconCode == icon.codePoint;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIconCode = icon.codePoint);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColor).withOpacity(0.2)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Color(_selectedColor)
                                : theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Color(_selectedColor)
                              : theme.iconTheme.color,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? 'Lưu' : 'Tạo mới'),
        ),
      ],
    );
  }
}
