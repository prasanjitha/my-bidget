import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import 'budget_status_badge.dart';
import 'category_progress_bar.dart';

class MonthlyHistoryList extends StatelessWidget {
  final List<String> budgetCycles;
  final String currency;

  const MonthlyHistoryList({
    super.key,
    required this.budgetCycles,
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

  String _formatBudgetCycle(String cycle) {
    try {
      final parts = cycle.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return cycle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (budgetCycles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: budgetCycles.length,
          itemBuilder: (context, index) {
            final cycle = budgetCycles[index];
            return _MonthlyHistoryCard(
              budgetCycle: cycle,
              monthYear: _formatBudgetCycle(cycle),
              currency: currency,
              currencySymbol: _getCurrencySymbol(currency),
            );
          },
        ),
      ],
    );
  }
}

class _MonthlyHistoryCard extends StatefulWidget {
  final String budgetCycle;
  final String monthYear;
  final String currency;
  final String currencySymbol;

  const _MonthlyHistoryCard({
    required this.budgetCycle,
    required this.monthYear,
    required this.currency,
    required this.currencySymbol,
  });

  @override
  State<_MonthlyHistoryCard> createState() => _MonthlyHistoryCardState();
}

class _MonthlyHistoryCardState extends State<_MonthlyHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return FutureBuilder<Map<String, double>>(
      future: homeProvider.getMonthlySummary(widget.budgetCycle),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final summary = snapshot.data!;
        final totalSpent = summary['totalSpent'] ?? 0.0;

        // Hide months with no expenses
        if (totalSpent == 0.0) {
          return const SizedBox.shrink();
        }

        final allocated = homeProvider.appSettings.monthlyAllocation;
        final remaining = allocated - totalSpent;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  widget.monthYear,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(
                        'Total Spent',
                        totalSpent,
                        totalSpent > allocated ? Colors.red : Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      _buildRow('Allocated', allocated, Colors.grey.shade600),
                      const SizedBox(height: 4),
                      _buildRow(
                        'Remaining',
                        remaining,
                        remaining < 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BudgetStatusBadge(spent: totalSpent, allocated: allocated),
                    const SizedBox(height: 8),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 24,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
              if (_isExpanded) ...[
                const Divider(height: 1),
                _buildCategoryBreakdown(context, homeProvider, summary),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          '${widget.currencySymbol} ${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    HomeProvider homeProvider,
    Map<String, double> summary,
  ) {
    final categories = homeProvider.categories;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...categories.map((category) {
            final spent = summary[category.id] ?? 0.0;
            final allocated = category.allocatedBudget;
            final remaining = allocated - spent;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.currencySymbol} ${NumberFormat('#,##0.00').format(spent)} / ${NumberFormat('#,##0.00').format(allocated)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CategoryProgressBar(spent: spent, allocated: allocated),
                  const SizedBox(height: 4),
                  Text(
                    'Remaining: ${widget.currencySymbol} ${NumberFormat('#,##0.00').format(remaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: remaining < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
