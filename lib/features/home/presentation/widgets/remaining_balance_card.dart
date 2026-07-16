import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';

class RemainingBalanceCard extends StatelessWidget {
  const RemainingBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final remainingBalance = homeProvider.remainingBalance;
    final budget = homeProvider.appSettings.monthlyAllocation;

    final isNegative = remainingBalance < 0;
    final isPositive = remainingBalance > 0;

    String displayText = budget == 0
        ? 'Set budget first'
        : settingsProvider.formatAmount(remainingBalance.abs());

    if (isNegative) {
      displayText = '-$displayText';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.15),
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
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Remaining Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565C0),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: isNegative
                  ? Colors.red.shade700
                  : isPositive
                      ? Colors.green.shade700
                      : Colors.blue.shade900,
              letterSpacing: -0.8,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
