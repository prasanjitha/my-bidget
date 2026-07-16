import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/category.dart';

class DailyExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currency;

  const DailyExpensesList({
    super.key,
    required this.expenses,
    required this.categories,
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

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (var expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }
    return grouped;
  }

  double _getDayTotal(List<Expense> dayExpenses) {
    return dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  String _getCategoryName(String categoryId) {
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    return category?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final groupedExpenses = _groupByDate(expenses);
    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final date = DateTime.parse(dateKey);
        final dayExpenses = groupedExpenses[dateKey]!;
        final dayTotal = _getDayTotal(dayExpenses);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(bottom: 16),
            title: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${DateFormat('MMMM dd,').format(date)} ${DateFormat('EEEE').format(date)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dayExpenses.length} expense${dayExpenses.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(dayTotal)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: dayExpenses.map((expense) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.receipt, size: 20),
                ),
                title: Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _getCategoryName(expense.categoryId),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Text(
                  '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            ),
          ),
        );
      },
    );
  }
}
