import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/savings.dart';
import '../widgets/savings_dialog.dart';
import '../../../../core/utils/toast_utils.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

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

  String _formatMonth(String month) {
    try {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNum = int.parse(parts[1]);
      final date = DateTime(year, monthNum);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return month;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final currency = homeProvider.appSettings.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Savings>>(
        stream: homeProvider.getSavings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading savings',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final savingsList = snapshot.data ?? [];
          final totalSavings = savingsList.fold<double>(
            0.0,
            (sum, savings) => sum + savings.amount,
          );

          return savingsList.isEmpty
              ? _buildEmptyState()
              : ListView(
                  children: [
                    _buildTotalSavingsCard(totalSavings, currency),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Monthly Savings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...savingsList.map((savings) => _buildSavingsCard(
                          context,
                          savings,
                          currency,
                        )),
                    const SizedBox(height: 80),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'savings_fab',
        onPressed: () => _showSavingsDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Savings'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No savings yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard(double totalSavings, String currency) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Savings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xCCFFFFFF),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(totalSavings)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(
    BuildContext context,
    Savings savings,
    String currency,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showActionSheet(context, savings),
        onLongPress: () => _showActionSheet(context, savings),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.savings,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMonth(savings.month),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saved on ${DateFormat('MMM dd, yyyy').format(savings.createdAt ?? DateTime.now())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(savings.amount)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSavingsDialog(BuildContext context, {Savings? savings}) {
    showDialog(
      context: context,
      builder: (context) => SavingsDialog(savings: savings),
    );
  }

  void _showActionSheet(BuildContext context, Savings savings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                _showSavingsDialog(context, savings: savings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteSavings(context, savings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSavings(BuildContext context, Savings savings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings'),
        content: Text(
          'Are you sure you want to delete savings for ${_formatMonth(savings.month)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final homeProvider = context.read<HomeProvider>();
      await homeProvider.deleteSavings(savings.id);

      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Savings entry deleted');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Error: ${e.toString().replaceAll("Exception: ", "")}');
      }
    }
  }
}
