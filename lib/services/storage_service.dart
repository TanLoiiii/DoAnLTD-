import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _keyTransactions = 'offline_transactions';
  static const String _keyCategories = 'offline_categories';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyMongoUri = 'mongo_uri';

  // Lưu danh sách giao dịch
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toMap()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(jsonList));
  }

  // Đọc danh sách giao dịch
  Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTransactions);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => TransactionModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  // Lưu danh mục
  Future<void> saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toMap()).toList();
    await prefs.setString(_keyCategories, jsonEncode(jsonList));
  }

  // Đọc danh mục
  Future<List<CategoryModel>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCategories);
    if (jsonString == null || jsonString.isEmpty) {
      return CategoryModel.getDefaultCategories();
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => CategoryModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return CategoryModel.getDefaultCategories();
    }
  }

  // Dark mode
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // Mongo URI
  Future<void> saveMongoUri(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMongoUri, uri);
  }

  Future<String?> loadMongoUri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMongoUri);
  }

  // Xóa trắng dữ liệu (cho mục đích test)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keyCategories);
  }
}
