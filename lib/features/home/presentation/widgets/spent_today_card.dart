import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpentTodayCard extends StatelessWidget {
  final double amount;
  final String currency;

  const SpentTodayCard({
    super.key,
    required this.amount,
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
    return Container(
      margin: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spent Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                  color: Color(0xFF1565C0),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('MMMM dd, yyyy').format(DateTime.now()),
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade800.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade900,
              letterSpacing: -1,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
