import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';
import '../../../../core/utils/number_input_formatter.dart';
import '../../../../core/utils/toast_utils.dart';

class MonthlyBudgetCard extends StatelessWidget {
  const MonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final budget = homeProvider.appSettings.monthlyAllocation;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    String displayAmount = budget > 0
        ? settingsProvider.formatAmount(budget)
        : 'Not Set';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MONTHLY Allocation Budget',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Color(0xFF333333),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayAmount,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: budget > 0 ? const Color(0xFF000000) : const Color(0xFF999999),
                    letterSpacing: -0.5,
                    fontFamily: 'Roboto',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showSetBudgetDialog(context, homeProvider),
                    customBorder: const CircleBorder(),
                    child: const Center(
                      child: Text(
                        'SET',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, HomeProvider provider) {
    final settingsProvider = context.read<SettingsProvider>();
    final amountController = TextEditingController(
      text: provider.appSettings.monthlyAllocation.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                prefixText: '${settingsProvider.getCurrencySymbol()} ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Remove commas before parsing
              final cleanText = amountController.text.replaceAll(',', '');
              final amount = double.tryParse(cleanText);
              if (amount == null || amount < 0) {
                ToastUtils.showError(context, 'Please enter a valid amount');
                return;
              }

              if (amount > 999999999) {
                ToastUtils.showError(context, 'Amount is too large');
                return;
              }

              await provider.setMonthlyBudget(amount, settingsProvider.currency);
              if (context.mounted) {
                Navigator.of(context).pop();
                ToastUtils.showSuccess(context, 'Budget updated successfully');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
