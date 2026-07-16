import 'package:flutter/material.dart';

class CategoryProgressBar extends StatelessWidget {
  final double spent;
  final double allocated;
  final double height;

  const CategoryProgressBar({
    super.key,
    required this.spent,
    required this.allocated,
    this.height = 8,
  });

  Color _getProgressColor(double percentage) {
    if (percentage <= 70) {
      return Colors.green;
    } else if (percentage <= 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allocated == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: const Center(
          child: Text(
            'Not Set',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      );
    }

    final percentage = (spent / allocated) * 100;
    final displayPercentage = percentage > 100 ? 100.0 : percentage;
    final color = _getProgressColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: displayPercentage / 100,
            minHeight: height,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (percentage > 100) ...[
          const SizedBox(height: 4),
          Text(
            'Exceeded by ${(percentage - 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
