// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String title; // Ghi chú hoặc tên giao dịch
  final double amount; // Số tiền
  final String type; // 'expense' hoặc 'income'
  final String categoryId;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  IconData get categoryIcon => IconData(categoryIconCode, fontFamily: 'MaterialIcons');
  Color get categoryColor => Color(categoryColorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconCode': categoryIconCode,
      'categoryColorValue': categoryColorValue,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type']?.toString() ?? 'expense',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      categoryIconCode: (map['categoryIconCode'] as num?)?.toInt() ?? Icons.category.codePoint,
      categoryColorValue: (map['categoryColorValue'] as num?)?.toInt() ?? 0xFF2196F3,
      date: map['date'] is DateTime
          ? map['date'] as DateTime
          : (map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now()),
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : (map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? categoryId,
    String? categoryName,
    int? categoryIconCode,
    int? categoryColorValue,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
