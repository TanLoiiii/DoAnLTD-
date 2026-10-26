import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PersonalExpenseTrackerApp());
}

class PersonalExpenseTrackerApp extends StatelessWidget {
  final ExpenseProvider? provider;

  const PersonalExpenseTrackerApp({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider != null) {
      return ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider!,
        child: const _ExpenseTrackerAppContent(),
      );
    }

    return ChangeNotifierProvider<ExpenseProvider>(
      create: (_) => ExpenseProvider(),
      child: const _ExpenseTrackerAppContent(),
    );
  }
}

class _ExpenseTrackerAppContent extends StatelessWidget {
  const _ExpenseTrackerAppContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return MaterialApp(
      title: 'Quản Lý Chi Tiêu Cá Nhân',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF1E88E5), // Xanh dương thanh lịch
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1E88E5),
        scaffoldBackgroundColor: const Color(0xFF12141A),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C2029),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang chuẩn bị Sổ tay Chi tiêu...',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final screens = [
      DashboardScreen(
        onNavigateToTransactions: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const TransactionsScreen(),
      const ReportsScreen(),
      const CategoriesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category_rounded),
            label: 'Danh mục',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
