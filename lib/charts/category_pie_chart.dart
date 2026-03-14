import 'dart:math';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  final void Function(String category)? onCategorySelected;

  const CategoryPieChart({
    super.key,
    required this.data,
    this.onCategorySelected,
  });

  static const List<Color> _colors = [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF26A69A),
  ];

  String? _getTappedCategory(Offset tapPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final dx = tapPos.dx - center.dx;
    final dy = tapPos.dy - center.dy;

    final distance = sqrt(dx * dx + dy * dy);

    final outerRadius = (size.shortestSide / 2) * 0.8;

    final innerRadius = outerRadius - 24;

    if (distance < innerRadius || distance > outerRadius) return null;

    double angle = atan2(dy, dx) + (pi / 2);
    if (angle < 0) angle += 2 * pi;

    final total = data.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return null;

    double startAngle = 0;
    for (final entry in data.entries) {
      final sweep = (entry.value / total) * 2 * pi;

      if (angle >= startAngle && angle <= startAngle + sweep) {
        return entry.key;
      }
      startAngle += sweep;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.values.fold<double>(0.0, (a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return GestureDetector(
                        onTapDown: (details) {
                          final tappedCategory = _getTappedCategory(
                            details.localPosition,
                            size,
                          );

                          if (tappedCategory != null &&
                              onCategorySelected != null) {
                            onCategorySelected!(tappedCategory);
                          }
                        },
                        child: CustomPaint(
                          size: size,
                          painter: _PieChartPainter(
                            data: data,
                            colors: _colors,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(total),
      ],
    );
  }

  Widget _buildLegend(double total) {
    int index = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: data.entries.map((entry) {
        final color = _colors[index++ % _colors.length];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  _PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<double>(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.8;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;

    int index = 0;
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;

      final adjustedSweep = sweepAngle - 0.1;

      paint.color = colors[index % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.05,
        adjustedSweep > 0 ? adjustedSweep : 0,
        false,
        paint,
      );

      startAngle += sweepAngle;
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => old.data != data;
}
