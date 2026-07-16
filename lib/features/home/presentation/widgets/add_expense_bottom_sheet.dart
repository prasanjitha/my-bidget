import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/expense.dart';
import 'category_dialog.dart';
import '../../../../core/utils/number_input_formatter.dart';
import '../../../../core/utils/toast_utils.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final Expense? expense;

  const AddExpenseBottomSheet({super.key, this.expense});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final categories = homeProvider.categories;
    final currency = homeProvider.appSettings.currency;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              widget.expense == null ? Icons.add_rounded : Icons.edit_rounded,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.expense == null ? 'Add Expense' : 'Edit Expense',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Roboto',
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.grey[600],
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title (optional)',
                      hintText: 'Enter title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: Icon(Icons.description_outlined, color: Colors.blue.shade600),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50.withValues(alpha: 0.3),
                            prefixIcon: Icon(Icons.category_rounded, color: Colors.blue.shade600),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green.shade700, size: 28),
                          onPressed: () => _showAddCategoryDialog(context, homeProvider),
                          tooltip: 'Add new category',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: Icon(Icons.calendar_today_rounded, color: Colors.blue.shade600),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50.withValues(alpha: 0.3),
                      prefixIcon: Icon(Icons.payments_rounded, color: Colors.green.shade700, size: 26),
                      prefixText: '${_getCurrencySymbol(currency)} ',
                      prefixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                        fontFamily: 'Roboto',
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      // Remove commas before parsing
                      final cleanValue = value.replaceAll(',', '');
                      final amount = double.tryParse(cleanValue);
                      if (amount == null) {
                        return 'Please enter a valid number';
                      }
                      if (amount < 0.01) {
                        return 'Amount must be at least 0.01';
                      }
                      if (amount > 999999999) {
                        return 'Amount is too large';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.expense == null ? 'ADD EXPENSE' : 'UPDATE',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  // Add bottom padding to avoid system navigation bar
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ToastUtils.showError(context, 'Please select a category');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final homeProvider = context.read<HomeProvider>();
      // Remove commas before parsing
      final cleanAmount = _amountController.text.replaceAll(',', '');
      final amount = double.parse(cleanAmount);
      final title = _titleController.text.trim();

      if (widget.expense == null) {
        await homeProvider.addExpense(
          categoryId: _selectedCategoryId!,
          amount: amount,
          description: title.isEmpty ? 'Expense' : title,
          date: _selectedDate,
        );
      } else {
        await homeProvider.updateExpense(
          expenseId: widget.expense!.id,
          categoryId: _selectedCategoryId!,
          amount: amount,
          description: title.isEmpty ? 'Expense' : title,
          date: _selectedDate,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccess(
          context,
          widget.expense == null
              ? 'Expense added successfully'
              : 'Expense updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddCategoryDialog(BuildContext context, HomeProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CategoryDialog(),
    );

    if (result == true && mounted) {
      // Get the newly created category and select it
      final categories = provider.categories;
      if (categories.isNotEmpty) {
        // The newest category will be the last one (sorted alphabetically, but we want the most recent)
        // We can select it based on the timestamp or just get the last added
        setState(() {
          _selectedCategoryId = categories.last.id;
        });
      }
    }
  }

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
}
