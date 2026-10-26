import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberOnly = NumberFormat('#,###', 'vi_VN');

  static String formatVND(double amount) {
    return _formatter.format(amount).trim();
  }

  static String formatNumberOnly(double amount) {
    return _numberOnly.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  static String formatFullMonthYear(DateTime date) {
    return 'Tháng ${date.month}, ${date.year}';
  }

  static double parseDouble(String text) {
    if (text.isEmpty) return 0.0;
    // Bỏ tất cả ký tự không phải số
    final cleaned = text.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
