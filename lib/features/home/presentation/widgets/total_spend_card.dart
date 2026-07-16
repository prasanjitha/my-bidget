import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';

class TotalSpendCard extends StatelessWidget {
  const TotalSpendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final totalSpent = homeProvider.totalSpent;
    final budget = homeProvider.appSettings.monthlyAllocation;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    final isOverBudget = totalSpent > budget && budget > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF3E0), // Light orange
            const Color(0xFFFFE0B2), // Lighter orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOverBudget ? Colors.red.shade100 : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: isOverBudget ? Colors.red.shade600 : Colors.orange.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Total Spend - ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE65100),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF999999),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            settingsProvider.formatAmount(totalSpent),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isOverBudget ? Colors.red.shade700 : const Color(0xFF000000),
              letterSpacing: -0.5,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
