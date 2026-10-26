import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

enum MongoConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class MongoDbService {
  static const String defaultUri =
      'mongodb+srv://loitan948_db_user:T71x0jNQcHsyeic7@cluster0.w5jeoln.mongodb.net/expense_tracker?retryWrites=true&w=majority&appName=Cluster0';

  Db? _db;
  String _currentUri = defaultUri;
  MongoConnectionStatus _status = MongoConnectionStatus.disconnected;
  String _lastErrorMessage = '';

  MongoConnectionStatus get status => _status;
  bool get isConnected => _status == MongoConnectionStatus.connected && _db != null && _db!.isConnected;
  String get lastErrorMessage => _lastErrorMessage;
  String get currentUri => _currentUri;

  void setUri(String uri) {
    final trimmed = uri.trim();
    if (trimmed != _currentUri) {
      _currentUri = trimmed;
      disconnect();
    }
  }

  // Kết nối tới MongoDB Atlas
  Future<bool> connect({String? customUri}) async {
    final uriToUse = customUri?.trim() ?? _currentUri;
    if (uriToUse != _currentUri) {
      _currentUri = uriToUse;
      await disconnect();
    }

    if (_db != null && _db!.isConnected) {
      _status = MongoConnectionStatus.connected;
      return true;
    }

    _status = MongoConnectionStatus.connecting;
    _lastErrorMessage = '';

    try {
      _db = await Db.create(uriToUse);
      // Đặt timeout 12 giây để không làm đơ ứng dụng nếu không có mạng
      await _db!.open().timeout(const Duration(seconds: 12));
      _status = MongoConnectionStatus.connected;
      debugPrint('MongoDB Atlas đã kết nối thành công!');
      return true;
    } catch (e) {
      _status = MongoConnectionStatus.error;
      _lastErrorMessage = e.toString();
      debugPrint('Lỗi kết nối MongoDB Atlas: $e');
      return false;
    }
  }

  // Ngắt kết nối
  Future<void> disconnect() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }
    } catch (_) {}
    _status = MongoConnectionStatus.disconnected;
  }

  // Lấy toàn bộ danh sách giao dịch từ Atlas
  Future<List<TransactionModel>> fetchTransactions() async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return [];
    }

    try {
      final collection = _db!.collection('transactions');
      final list = await collection.find().toList();
      return list.map((doc) => TransactionModel.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Lỗi fetchTransactions: $e');
      return [];
    }
  }

  // Lưu một giao dịch lên Atlas
  Future<bool> saveTransaction(TransactionModel transaction) async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final collection = _db!.collection('transactions');
      await collection.replaceOne(
        where.eq('id', transaction.id),
        transaction.toMap(),
        upsert: true,
      );
      return true;
    } catch (e) {
      debugPrint('Lỗi saveTransaction: $e');
      return false;
    }
  }

  // Xóa giao dịch trên Atlas
  Future<bool> deleteTransaction(String id) async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final collection = _db!.collection('transactions');
      await collection.deleteOne(where.eq('id', id));
      return true;
    } catch (e) {
      debugPrint('Lỗi deleteTransaction: $e');
      return false;
    }
  }

  // Lấy toàn bộ danh mục từ Atlas
  Future<List<CategoryModel>> fetchCategories() async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return [];
    }

    try {
      final collection = _db!.collection('categories');
      final list = await collection.find().toList();
      if (list.isEmpty) return [];
      return list.map((doc) => CategoryModel.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Lỗi fetchCategories: $e');
      return [];
    }
  }

  // Lưu danh mục lên Atlas
  Future<bool> saveCategory(CategoryModel category) async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final collection = _db!.collection('categories');
      await collection.replaceOne(
        where.eq('id', category.id),
        category.toMap(),
        upsert: true,
      );
      return true;
    } catch (e) {
      debugPrint('Lỗi saveCategory: $e');
      return false;
    }
  }

  // Xóa danh mục trên Atlas
  Future<bool> deleteCategory(String id) async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final collection = _db!.collection('categories');
      await collection.deleteOne(where.eq('id', id));
      return true;
    } catch (e) {
      debugPrint('Lỗi deleteCategory: $e');
      return false;
    }
  }

  // Đồng bộ toàn bộ dữ liệu máy lên Atlas
  Future<bool> syncAllToAtlas(List<TransactionModel> transactions, List<CategoryModel> categories) async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final txColl = _db!.collection('transactions');
      final catColl = _db!.collection('categories');

      // Đồng bộ transactions
      for (final tx in transactions) {
        await txColl.replaceOne(where.eq('id', tx.id), tx.toMap(), upsert: true);
      }

      // Đồng bộ categories
      for (final cat in categories) {
        await catColl.replaceOne(where.eq('id', cat.id), cat.toMap(), upsert: true);
      }

      return true;
    } catch (e) {
      debugPrint('Lỗi syncAllToAtlas: $e');
      return false;
    }
  }

  // Xóa trắng toàn bộ collection trên Atlas (cho mục đích test)
  Future<bool> clearAllRemoteData() async {
    if (!isConnected) {
      final ok = await connect();
      if (!ok) return false;
    }

    try {
      final txColl = _db!.collection('transactions');
      final catColl = _db!.collection('categories');
      await txColl.deleteMany({});
      await catColl.deleteMany({});
      return true;
    } catch (e) {
      debugPrint('Lỗi clearAllRemoteData: $e');
      return false;
    }
  }
}
