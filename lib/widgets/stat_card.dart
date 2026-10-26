import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final bool isLarge;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark ? theme.cardColor : color.withOpacity(0.08));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 20 : 16,
        vertical: isLarge ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: isLarge ? 15 : 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isLarge ? 22 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 12 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.formatVND(amount),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 24 : 18,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
