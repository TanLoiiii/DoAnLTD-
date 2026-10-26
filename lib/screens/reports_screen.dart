import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isWeekly = false; // false = Theo tháng, true = Theo tuần
  int _touchedIndex = -1;

  // Bảng màu phụ trợ khi cần
  final List<Color> _chartColors = [
    const Color(0xFFFF5722),
    const Color(0xFFE91E63),
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF607D8B),
    const Color(0xFF795548),
    const Color(0xFF3F51B5),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    final totalExpense = provider.getTotalExpenseForPeriod(isWeekly: _isWeekly);
    final expenseMap = provider.getExpenseByCategory(isWeekly: _isWeekly);
    final topCategories = provider.getTopSpendingCategories(
        isWeekly: _isWeekly, limit: 8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo & Thống Kê'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Bộ chuyển đổi Tuần / Tháng
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
                    onTap: () {
                      setState(() {
                        _isWeekly = false;
                        _touchedIndex = -1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isWeekly
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Theo Tháng (${CurrencyFormatter.formatMonthYear(DateTime.now())})',
                          style: TextStyle(
                            color: !_isWeekly ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isWeekly = true;
                        _touchedIndex = -1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isWeekly
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Theo Tuần Này',
                          style: TextStyle(
                            color: _isWeekly ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tổng chi tiêu trong kỳ
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isWeekly ? 'TỔNG CHI TIÊU TUẦN NÀY' : 'TỔNG CHI TIÊU THÁNG NÀY',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatVND(totalExpense),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Biểu đồ tròn phân tích cơ cấu chi tiêu
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.donut_large_rounded,
                        color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cơ cấu chi tiêu (%)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (totalExpense == 0 || expenseMap.isEmpty)
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          size: 48,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chưa có dữ liệu chi tiêu trong kỳ này.',
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 44,
                            sections: _buildPieChartSections(
                                expenseMap, totalExpense),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Chú thích các danh mục
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: expenseMap.entries.toList().asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final color = _chartColors[idx % _chartColors.length];
                          final percent = (item.value / totalExpense * 100).toStringAsFixed(1);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.key} ($percent%)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bảng xếp hạng danh mục tốn kém nhất
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.leaderboard_rounded,
                        color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Bảng xếp hạng tốn kém nhất',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (topCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Không có khoản chi nào để xếp hạng.',
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ),
                  )
                else
                  ...topCategories.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final categoryName = entry.value.key;
                    final amount = entry.value.value;
                    final percent = totalExpense > 0 ? (amount / totalExpense) : 0.0;
                    final color = _chartColors[entry.key % _chartColors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Huy hiệu thứ hạng (Top 1, 2, 3...)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: rank == 1
                                      ? Colors.amber
                                      : (rank == 2
                                          ? Colors.blueGrey.shade300
                                          : (rank == 3
                                              ? Colors.brown.shade300
                                              : theme.dividerColor.withOpacity(0.2))),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$rank',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatVND(amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${(percent * 100).toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 7,
                              backgroundColor: color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, double> map, double total) {
    final list = map.entries.toList();
    return List.generate(list.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 65.0 : 55.0;
      final entry = list[i];
      final percent = (entry.value / total * 100);
      final color = _chartColors[i % _chartColors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 2),
          ],
        ),
      );
    });
  }
}
