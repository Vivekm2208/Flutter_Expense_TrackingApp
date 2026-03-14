import "package:flutter/material.dart";

class SummaryCard extends StatelessWidget {
  final double totalSpent;
  final double? remainingBudget;
  final String currency;

  const SummaryCard({
    super.key,
    required this.totalSpent,
    required this.currency,
    this.remainingBudget,
  });
  @override
  Widget build(BuildContext context) {
    final remaining = remainingBudget;

    Color remainingColor = Colors.green;
    if (remaining != null && remaining < 0) {
      remainingColor = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spent',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currency${totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (remaining != null) ...[
                Text(
                  'Remaining Budget',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currency${remaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: remainingColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
