import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'budget_status_badge.dart';

class MonthlySummaryCard extends StatelessWidget {
  final String monthYear;
  final double totalSpent;
  final double allocated;
  final String currency;

  const MonthlySummaryCard({
    super.key,
    required this.monthYear,
    required this.totalSpent,
    required this.allocated,
    required this.currency,
  });

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'LKR':
        return 'RS';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = allocated - totalSpent;
    final isOverBudget = totalSpent > allocated;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BudgetStatusBadge(spent: totalSpent, allocated: allocated),
              ],
            ),
            const SizedBox(height: 20),
            _buildRow(
              'Total Spent',
              totalSpent,
              isOverBudget ? Colors.red : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
            ),
            const SizedBox(height: 12),
            _buildRow('Allocated Budget', allocated, Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade700),
            const Divider(height: 24),
            _buildRow(
              'Remaining',
              remaining,
              remaining < 0 ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, Color amountColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
