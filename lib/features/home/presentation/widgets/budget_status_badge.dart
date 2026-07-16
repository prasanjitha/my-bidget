import 'package:flutter/material.dart';

class BudgetStatusBadge extends StatelessWidget {
  final double spent;
  final double allocated;

  const BudgetStatusBadge({
    super.key,
    required this.spent,
    required this.allocated,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverBudget = spent > allocated;
    final bool noBudget = allocated == 0;

    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText;
    IconData icon;

    if (noBudget) {
      backgroundColor = Colors.grey.shade600;
      statusText = 'NO BUDGET SET';
      icon = Icons.info_outline;
    } else if (isOverBudget) {
      backgroundColor = Colors.red.shade600;
      statusText = 'OVER BUDGET';
      icon = Icons.warning;
    } else {
      backgroundColor = Colors.green.shade600;
      statusText = 'IN BUDGET';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
