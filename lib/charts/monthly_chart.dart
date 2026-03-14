import 'package:flutter/material.dart';

class DailyTotal {
  final int day;
  final double amount;

  DailyTotal({required this.day, required this.amount});
}

class MonthlyChart extends StatelessWidget {
  final List<DailyTotal> data;
  final double? dailyLimit;
  const MonthlyChart({super.key, required this.data, required this.dailyLimit});

  static const double chartHeight = 120;
  static const double topPadding = 30.0; // Reserved space for the label

  double get _maxAmount {
    if (data.isEmpty) return 0;
    double maxSpending = data
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    // Ensure the chart scales to show the limit line even if spending is low
    return maxSpending > (dailyLimit ?? 0) ? maxSpending : (dailyLimit ?? 1);
  }

  double get _limitLineHeight {
    if (dailyLimit == null || _maxAmount == 0) return 0;
    return (dailyLimit! / _maxAmount) * chartHeight;
  }

  Widget _buildBar(DailyTotal dt) {
    final totalBarHeight = _maxAmount == 0
        ? 0.0
        : (dt.amount / _maxAmount) * chartHeight;
    final limitLinePos = _limitLineHeight;

    final blueHeight = totalBarHeight <= limitLinePos
        ? totalBarHeight
        : limitLinePos;
    final redHeight = totalBarHeight > limitLinePos
        ? totalBarHeight - limitLinePos
        : 0.0;

    return SizedBox(
      width: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (redHeight > 0)
            Container(
              height: redHeight,
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          Container(
            height: blueHeight,
            width: 10,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Monthly Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: topPadding + chartHeight + 30,
              child: Stack(
                children: [
                  //  Daily Limit Label (Fixed at top)
                  if (dailyLimit != null)
                    Positioned(
                      top: 0,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Daily Limit ₹${dailyLimit!.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  //  Scrollable Chart Content
                  Padding(
                    padding: const EdgeInsets.only(top: topPadding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            // Bars + Limit Line Stack
                            SizedBox(
                              height: chartHeight,
                              child: Stack(
                                children: [
                                  // Bars
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: data.map(_buildBar).toList(),
                                  ),
                                  // Limit Line
                                  if (_limitLineHeight > 0)
                                    Positioned(
                                      bottom: _limitLineHeight,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 1,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Date Labels
                            Row(
                              children: data
                                  .map(
                                    (dt) => SizedBox(
                                      width: 24,
                                      child: Text(
                                        dt.day.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
