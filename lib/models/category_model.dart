// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.colorValue,
    this.isDefault = false,
  });

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily ?? 'MaterialIcons',
        fontPackage: iconFontPackage,
      );

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'expense',
      iconCodePoint: (map['iconCodePoint'] as num?)?.toInt() ?? Icons.category.codePoint,
      iconFontFamily: map['iconFontFamily']?.toString(),
      iconFontPackage: map['iconFontPackage']?.toString(),
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFF2196F3,
      isDefault: map['isDefault'] == true,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? type,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Danh mục mặc định
  static List<CategoryModel> getDefaultCategories() {
    return [
      // Chi tiêu
      CategoryModel(
        id: 'cat_food',
        name: 'Ăn uống',
        type: 'expense',
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: 0xFFFF5722, // Cam
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_shopping',
        name: 'Mua sắm',
        type: 'expense',
        iconCodePoint: Icons.shopping_bag.codePoint,
        colorValue: 0xFFE91E63, // Hồng
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_transport',
        name: 'Di chuyển',
        type: 'expense',
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: 0xFF2196F3, // Xanh dương
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_bills',
        name: 'Hóa đơn & Tiện ích',
        type: 'expense',
        iconCodePoint: Icons.receipt_long.codePoint,
        colorValue: 0xFF9C27B0, // Tím
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_entertainment',
        name: 'Giải trí',
        type: 'expense',
        iconCodePoint: Icons.sports_esports.codePoint,
        colorValue: 0xFF00BCD4, // Xanh lục lam
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_health',
        name: 'Y tế & Sức khỏe',
        type: 'expense',
        iconCodePoint: Icons.medical_services.codePoint,
        colorValue: 0xFF4CAF50, // Xanh lá
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_education',
        name: 'Giáo dục',
        type: 'expense',
        iconCodePoint: Icons.school.codePoint,
        colorValue: 0xFFFF9800, // Hổ phách
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_expense_other',
        name: 'Chi tiêu khác',
        type: 'expense',
        iconCodePoint: Icons.category.codePoint,
        colorValue: 0xFF607D8B, // Xám lam
        isDefault: true,
      ),

      // Thu nhập
      CategoryModel(
        id: 'cat_salary',
        name: 'Tiền lương',
        type: 'income',
        iconCodePoint: Icons.account_balance_wallet.codePoint,
        colorValue: 0xFF2E7D32, // Xanh lá đậm
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_bonus',
        name: 'Thưởng & Tiền boa',
        type: 'income',
        iconCodePoint: Icons.card_giftcard.codePoint,
        colorValue: 0xFF00897B, // Xanh ngọc
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_investment',
        name: 'Đầu tư & Lãi suất',
        type: 'income',
        iconCodePoint: Icons.trending_up.codePoint,
        colorValue: 0xFF1565C0, // Xanh đậm
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_side_job',
        name: 'Kinh doanh / Nghề tay trái',
        type: 'income',
        iconCodePoint: Icons.storefront.codePoint,
        colorValue: 0xFFF57C00, // Cam đậm
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_income_other',
        name: 'Thu nhập khác',
        type: 'income',
        iconCodePoint: Icons.savings.codePoint,
        colorValue: 0xFF546E7A, // Xám
        isDefault: true,
      ),
    ];
  }
}
