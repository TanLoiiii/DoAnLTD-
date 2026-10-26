import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/mongodb_service.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final MongoDbService _mongoService = MongoDbService();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isDarkMode = false;
  bool _isLoading = true;
  String _syncStatusMessage = 'Chế độ Ngoại tuyến (Sẵn sàng)';
  DateTime _selectedMonth = DateTime.now();

  // Search & Filter state
  String _searchKeyword = '';
  String _filterType = 'all'; // 'all', 'expense', 'income'
  String? _filterCategoryId;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  DateTimeRange? _filterDateRange;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String get syncStatusMessage => _syncStatusMessage;
  DateTime get selectedMonth => _selectedMonth;
  MongoDbService get mongoService => _mongoService;

  String get searchKeyword => _searchKeyword;
  String get filterType => _filterType;
  String? get filterCategoryId => _filterCategoryId;
  double? get filterMinAmount => _filterMinAmount;
  double? get filterMaxAmount => _filterMaxAmount;
  DateTimeRange? get filterDateRange => _filterDateRange;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  ExpenseProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Tải cấu hình từ SharedPreferences trước (đảm bảo ứng dụng chạy tức thì offline)
    _isDarkMode = await _storageService.loadDarkMode();
    final savedMongoUri = await _storageService.loadMongoUri();
    if (savedMongoUri != null && savedMongoUri.trim().isNotEmpty) {
      _mongoService.setUri(savedMongoUri);
    }
    _categories = await _storageService.loadCategories();
    _transactions = await _storageService.loadTransactions();

    // Nếu lần đầu mở và chưa có dữ liệu, nạp dữ liệu mẫu để người dùng trải nghiệm ngay
    if (_transactions.isEmpty) {
      await loadSampleData(saveOnly: true);
    }

    _isLoading = false;
    notifyListeners();

    // 2. Thử kết nối ngầm tới MongoDB Atlas để đồng bộ
    _tryAutoConnectMongo();
  }

  Future<void> _tryAutoConnectMongo() async {
    _syncStatusMessage = 'Đang kiểm tra kết nối MongoDB Atlas...';
    notifyListeners();

    final connected = await _mongoService.connect();
    if (connected) {
      _syncStatusMessage = 'Đã kết nối MongoDB Atlas';
      // Thử tải dữ liệu từ Atlas nếu trên máy chưa có hoặc đồng bộ
      final remoteTx = await _mongoService.fetchTransactions();
      if (remoteTx.isNotEmpty && _transactions.isEmpty) {
        _transactions = remoteTx;
        await _storageService.saveTransactions(_transactions);
      } else if (_transactions.isNotEmpty) {
        // Đồng bộ dữ liệu hiện có lên MongoDB
        await _mongoService.syncAllToAtlas(_transactions, _categories);
      }
    } else {
      _syncStatusMessage = 'Ngoại tuyến (Offline)';
    }
    notifyListeners();
  }

  // Chuyển đổi Dark / Light mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Chọn tháng cho Dashboard
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  // Bảng điều khiển - Tính toán số liệu tháng
  List<TransactionModel> get transactionsForSelectedMonth {
    return _transactions.where((tx) {
      return tx.date.year == _selectedMonth.year &&
          tx.date.month == _selectedMonth.month;
    }).toList();
  }

  double get totalIncomeForSelectedMonth {
    return transactionsForSelectedMonth
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpenseForSelectedMonth {
    return transactionsForSelectedMonth
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get netBalanceForSelectedMonth {
    return totalIncomeForSelectedMonth - totalExpenseForSelectedMonth;
  }

  // Danh sách giao dịch gần nhất (Recent Transactions)
  List<TransactionModel> get recentTransactions {
    final list = List<TransactionModel>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(6).toList();
  }

  // Tìm kiếm & Bộ lọc
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword.trim().toLowerCase();
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategoryId(String? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void setFilterAmountRange(double? min, double? max) {
    _filterMinAmount = min;
    _filterMaxAmount = max;
    notifyListeners();
  }

  void setFilterDateRange(DateTimeRange? range) {
    _filterDateRange = range;
    notifyListeners();
  }

  void clearFilters() {
    _searchKeyword = '';
    _filterType = 'all';
    _filterCategoryId = null;
    _filterMinAmount = null;
    _filterMaxAmount = null;
    _filterDateRange = null;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((tx) {
      // 1. Từ khóa ghi chú/tiêu đề
      if (_searchKeyword.isNotEmpty) {
        final title = tx.title.toLowerCase();
        final catName = tx.categoryName.toLowerCase();
        if (!title.contains(_searchKeyword) && !catName.contains(_searchKeyword)) {
          return false;
        }
      }

      // 2. Loại giao dịch (thu / chi / tất cả)
      if (_filterType != 'all' && tx.type != _filterType) {
        return false;
      }

      // 3. Danh mục
      if (_filterCategoryId != null && _filterCategoryId!.isNotEmpty) {
        if (tx.categoryId != _filterCategoryId) {
          return false;
        }
      }

      // 4. Khoảng tiền
      if (_filterMinAmount != null && tx.amount < _filterMinAmount!) {
        return false;
      }
      if (_filterMaxAmount != null && tx.amount > _filterMaxAmount!) {
        return false;
      }

      // 5. Khoảng ngày
      if (_filterDateRange != null) {
        final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final startOnly = DateTime(_filterDateRange!.start.year,
            _filterDateRange!.start.month, _filterDateRange!.start.day);
        final endOnly = DateTime(_filterDateRange!.end.year,
            _filterDateRange!.end.month, _filterDateRange!.end.day);
        if (dateOnly.isBefore(startOnly) || dateOnly.isAfter(endOnly)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Quản lý Giao dịch: Thêm, Sửa, Xóa
  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.insert(0, transaction);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();

    // Đồng bộ nền MongoDB Atlas
    if (_mongoService.isConnected) {
      _mongoService.saveTransaction(transaction);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _storageService.saveTransactions(_transactions);
      notifyListeners();

      if (_mongoService.isConnected) {
        _mongoService.saveTransaction(transaction);
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();

    if (_mongoService.isConnected) {
      _mongoService.deleteTransaction(id);
    }
  }

  // Quản lý Danh mục: Thêm, Sửa, Xóa
  Future<void> addCategory(CategoryModel category) async {
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();

    if (_mongoService.isConnected) {
      _mongoService.saveCategory(category);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      // Cập nhật tên/icon/màu của danh mục trong các giao dịch tương ứng
      for (int i = 0; i < _transactions.length; i++) {
        if (_transactions[i].categoryId == category.id) {
          _transactions[i] = _transactions[i].copyWith(
            categoryName: category.name,
            categoryIconCode: category.iconCodePoint,
            categoryColorValue: category.colorValue,
          );
        }
      }
      await _storageService.saveCategories(_categories);
      await _storageService.saveTransactions(_transactions);
      notifyListeners();

      if (_mongoService.isConnected) {
        _mongoService.saveCategory(category);
      }
    }
  }

  Future<bool> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id,
        orElse: () => CategoryModel(
            id: '',
            name: '',
            type: '',
            iconCodePoint: 0,
            colorValue: 0));
    if (category.isDefault) {
      // Không thể xóa danh mục mặc định
      return false;
    }

    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();

    if (_mongoService.isConnected) {
      _mongoService.deleteCategory(id);
    }
    return true;
  }

  // Thống kê & Báo cáo
  // Lấy chi tiêu theo danh mục (cho Biểu đồ tròn PieChart)
  Map<String, double> getExpenseByCategory({
    required bool isWeekly,
    DateTime? anchorDate,
  }) {
    final date = anchorDate ?? DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (isWeekly) {
      // Tuần hiện tại (tính từ thứ 2 tới chủ nhật)
      final weekday = date.weekday;
      startDate = DateTime(date.year, date.month, date.day - (weekday - 1));
      endDate = DateTime(startDate.year, startDate.month, startDate.day + 6, 23, 59, 59);
    } else {
      // Tháng
      startDate = DateTime(date.year, date.month, 1);
      final lastDay = DateTime(date.year, date.month + 1, 0).day;
      endDate = DateTime(date.year, date.month, lastDay, 23, 59, 59);
    }

    final targetTransactions = _transactions.where((tx) {
      return tx.isExpense &&
          tx.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    final Map<String, double> result = {};
    for (final tx in targetTransactions) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0.0) + tx.amount;
    }

    return result;
  }

  // Bảng xếp hạng danh mục tốn kém nhất theo tuần hoặc tháng
  List<MapEntry<String, double>> getTopSpendingCategories({
    required bool isWeekly,
    DateTime? anchorDate,
    int limit = 6,
  }) {
    final map = getExpenseByCategory(isWeekly: isWeekly, anchorDate: anchorDate);
    final list = map.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }

  // Tổng chi tiêu trong kỳ (Tuần hoặc Tháng)
  double getTotalExpenseForPeriod({
    required bool isWeekly,
    DateTime? anchorDate,
  }) {
    final map = getExpenseByCategory(isWeekly: isWeekly, anchorDate: anchorDate);
    return map.values.fold(0.0, (sum, val) => sum + val);
  }

  // Tiện ích hệ thống: Đồng bộ thủ công MongoDB Atlas
  Future<bool> manualSyncMongo() async {
    _syncStatusMessage = 'Đang đồng bộ dữ liệu với MongoDB Atlas...';
    notifyListeners();

    final ok = await _mongoService.connect();
    if (!ok) {
      _syncStatusMessage = 'Lỗi kết nối MongoDB Atlas';
      notifyListeners();
      return false;
    }

    final success = await _mongoService.syncAllToAtlas(_transactions, _categories);
    if (success) {
      _syncStatusMessage = 'Đồng bộ Atlas thành công (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')})';
    } else {
      _syncStatusMessage = 'Đồng bộ thất bại';
    }
    notifyListeners();
    return success;
  }

  // Cập nhật và lưu chuỗi kết nối MongoDB Atlas
  Future<void> updateMongoUri(String uri) async {
    _mongoService.setUri(uri);
    await _storageService.saveMongoUri(uri);
    notifyListeners();
  }

  // Tiện ích hệ thống: Xóa trắng toàn bộ dữ liệu (Reset for testing)
  Future<void> clearAllData() async {
    _transactions.clear();
    _categories = CategoryModel.getDefaultCategories();
    await _storageService.clearAll();
    await _storageService.saveCategories(_categories);
    notifyListeners();

    if (_mongoService.isConnected) {
      await _mongoService.clearAllRemoteData();
    }
  }

  // Tiện ích hệ thống: Nạp dữ liệu mẫu phong phú
  Future<void> loadSampleData({bool saveOnly = false}) async {
    final now = DateTime.now();
    _categories = CategoryModel.getDefaultCategories();

    _transactions = [
      TransactionModel(
        id: 'tx_sample_1',
        title: 'Nhận lương tháng này',
        amount: 22000000,
        type: 'income',
        categoryId: 'cat_salary',
        categoryName: 'Tiền lương',
        categoryIconCode: Icons.account_balance_wallet.codePoint,
        categoryColorValue: 0xFF2E7D32,
        date: DateTime(now.year, now.month, 1),
      ),
      TransactionModel(
        id: 'tx_sample_2',
        title: 'Thưởng dự án hoàn thành tốt',
        amount: 3500000,
        type: 'income',
        categoryId: 'cat_bonus',
        categoryName: 'Thưởng & Tiền boa',
        categoryIconCode: Icons.card_giftcard.codePoint,
        categoryColorValue: 0xFF00897B,
        date: DateTime(now.year, now.month, 5),
      ),
      TransactionModel(
        id: 'tx_sample_3',
        title: 'Đi siêu thị mua thực phẩm cả tuần',
        amount: 850000,
        type: 'expense',
        categoryId: 'cat_food',
        categoryName: 'Ăn uống',
        categoryIconCode: Icons.restaurant.codePoint,
        categoryColorValue: 0xFFFF5722,
        date: DateTime(now.year, now.month, now.day > 2 ? now.day - 1 : now.day),
      ),
      TransactionModel(
        id: 'tx_sample_4',
        title: 'Cà phê sáng với đồng nghiệp',
        amount: 65000,
        type: 'expense',
        categoryId: 'cat_food',
        categoryName: 'Ăn uống',
        categoryIconCode: Icons.restaurant.codePoint,
        categoryColorValue: 0xFFFF5722,
        date: DateTime(now.year, now.month, now.day),
      ),
      TransactionModel(
        id: 'tx_sample_5',
        title: 'Tiền điện & nước tháng',
        amount: 1150000,
        type: 'expense',
        categoryId: 'cat_bills',
        categoryName: 'Hóa đơn & Tiện ích',
        categoryIconCode: Icons.receipt_long.codePoint,
        categoryColorValue: 0xFF9C27B0,
        date: DateTime(now.year, now.month, 4),
      ),
      TransactionModel(
        id: 'tx_sample_6',
        title: 'Đổ xăng xe máy',
        amount: 120000,
        type: 'expense',
        categoryId: 'cat_transport',
        categoryName: 'Di chuyển',
        categoryIconCode: Icons.directions_car.codePoint,
        categoryColorValue: 0xFF2196F3,
        date: DateTime(now.year, now.month, now.day > 1 ? now.day - 1 : now.day),
      ),
      TransactionModel(
        id: 'tx_sample_7',
        title: 'Mua giày thể thao mới',
        amount: 1450000,
        type: 'expense',
        categoryId: 'cat_shopping',
        categoryName: 'Mua sắm',
        categoryIconCode: Icons.shopping_bag.codePoint,
        categoryColorValue: 0xFFE91E63,
        date: DateTime(now.year, now.month, 8),
      ),
      TransactionModel(
        id: 'tx_sample_8',
        title: 'Xem phim cuối tuần',
        amount: 250000,
        type: 'expense',
        categoryId: 'cat_entertainment',
        categoryName: 'Giải trí',
        categoryIconCode: Icons.sports_esports.codePoint,
        categoryColorValue: 0xFF00BCD4,
        date: DateTime(now.year, now.month, now.day > 3 ? now.day - 2 : now.day),
      ),
      TransactionModel(
        id: 'tx_sample_9',
        title: 'Mua thuốc cảm cúm & Vitamin C',
        amount: 180000,
        type: 'expense',
        categoryId: 'cat_health',
        categoryName: 'Y tế & Sức khỏe',
        categoryIconCode: Icons.medical_services.codePoint,
        categoryColorValue: 0xFF4CAF50,
        date: DateTime(now.year, now.month, 10),
      ),
      TransactionModel(
        id: 'tx_sample_10',
        title: 'Mua sách kỹ năng lập trình Flutter',
        amount: 320000,
        type: 'expense',
        categoryId: 'cat_education',
        categoryName: 'Giáo dục',
        categoryIconCode: Icons.school.codePoint,
        categoryColorValue: 0xFFFF9800,
        date: DateTime(now.year, now.month, 12),
      ),
    ];

    await _storageService.saveCategories(_categories);
    await _storageService.saveTransactions(_transactions);

    if (!saveOnly) {
      notifyListeners();
      if (_mongoService.isConnected) {
        await _mongoService.syncAllToAtlas(_transactions, _categories);
      }
    }
  }
}
