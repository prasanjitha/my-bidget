import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/savings.dart';
import '../../../../core/utils/toast_utils.dart';

class SavingsDialog extends StatefulWidget {
  final Savings? savings;

  const SavingsDialog({super.key, this.savings});

  @override
  State<SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends State<SavingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedMonth;
  bool _isLoading = false;
  String? _errorMessage;

  List<String> _monthOptions = [];

  @override
  void initState() {
    super.initState();
    _generateMonthOptions();

    if (widget.savings != null) {
      _amountController.text = widget.savings!.amount.toString();
      _selectedMonth = widget.savings!.month;
    } else {
      // Default to current month
      final now = DateTime.now();
      _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _generateMonthOptions() {
    final now = DateTime.now();
    final options = <String>[];

    // Future 3 months
    for (int i = 3; i > 0; i--) {
      final date = DateTime(now.year, now.month + i);
      options.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }

    // Current month
    options.add('${now.year}-${now.month.toString().padLeft(2, '0')}');

    // Past 12 months
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(now.year, now.month - i);
      options.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }

    _monthOptions = options;
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

  bool get _isEditMode => widget.savings != null;

  Future<void> _saveSavings() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMonth == null) {
      setState(() {
        _errorMessage = 'Please select a month';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final homeProvider = context.read<HomeProvider>();
      final amount = double.parse(_amountController.text);

      if (_isEditMode) {
        await homeProvider.updateSavings(widget.savings!.id, amount);
      } else {
        await homeProvider.addSavings(
          month: _selectedMonth!,
          amount: amount,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ToastUtils.showSuccess(
          context,
          _isEditMode
              ? 'Savings updated successfully'
              : 'Savings added successfully',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    if (amount > 999999999) {
      return 'Amount is too large';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit Savings' : 'Add Savings',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: InputDecoration(
                  labelText: 'Month',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_month),
                  enabled: !_isEditMode && !_isLoading,
                ),
                items: _monthOptions.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(_formatMonth(month)),
                  );
                }).toList(),
                onChanged: _isEditMode
                    ? null
                    : (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                autofocus: !_isEditMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: _validateAmount,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _saveSavings(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveSavings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
