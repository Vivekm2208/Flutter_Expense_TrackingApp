import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, Object>> weeklySpending;
  final double? dailyLimit;

  const WeeklyChart({super.key, required this.weeklySpending, this.dailyLimit});

  static const double chartHeight = 80;
  static const double totalHeight = 150;

  double get maxSpending {
    if (weeklySpending.isEmpty) return 0.0;
    double maxVal = weeklySpending.fold<double>(0.0, (max, item) {
      final amount = item['amount'] as double;
      return amount > max ? amount : max;
    });

    if (dailyLimit != null && dailyLimit! > maxVal) return dailyLimit!;
    return maxVal;
  }

  double get _limitLineHeight {
    if (dailyLimit == null || maxSpending == 0) return 0;
    return (dailyLimit! / maxSpending) * chartHeight;
  }

  Widget _buildBar(Map<String, Object> data) {
    final amount = data['amount'] as double;
    final day = data['day'] as DateTime;

    final barHeight = maxSpending == 0
        ? 0.0
        : (amount / maxSpending) * chartHeight;
    final limitHeight = _limitLineHeight;

    final blueHeight = barHeight <= limitHeight ? barHeight : limitHeight;
    final redHeight = barHeight > limitHeight ? barHeight - limitHeight : 0.0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount == 0 ? '' : amount.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: chartHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (redHeight > 0)
                  Container(
                    height: redHeight,
                    width: 16,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                Container(
                  height: blueHeight,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.vertical(
                      bottom: const Radius.circular(4),
                      top: Radius.circular(redHeight > 0 ? 0 : 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 16,
            child: Text(
              DateFormat.E().format(day),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (weeklySpending.isEmpty ||
        weeklySpending.every((d) => (d['amount'] as double) == 0)) {
      return const SizedBox(
        height: totalHeight,
        child: Center(child: Text('No spending data available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Weekly Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 4,
          color: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: totalHeight,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklySpending.map(_buildBar).toList(),
                ),

                if (dailyLimit != null && maxSpending > 0)
                  Positioned(
                    bottom: 20.0 + _limitLineHeight,
                    left: 0,
                    right: 0,
                    child: Container(height: 1.5, color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
