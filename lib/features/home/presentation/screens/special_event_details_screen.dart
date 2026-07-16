import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/special_event.dart';
import '../../domain/models/special_event_expense.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';
import '../../../../core/utils/toast_utils.dart';

class SpecialEventDetailsScreen extends StatelessWidget {
  final SpecialEvent event;
  const SpecialEventDetailsScreen({super.key, required this.event});

  // ── Add / Edit expense dialog ────────────────────────────────────────
  void _showExpenseDialog(
    BuildContext context,
    HomeProvider provider, {
    SpecialEventExpense? expense,
  }) {
    final titleCtrl = TextEditingController(text: expense?.title ?? '');
    final amountCtrl = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    DateTime selectedDate = expense?.date ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => isLoading = true);
                        try {
                          if (expense == null) {
                            await provider.addSpecialEventExpense(
                              eventId: event.id,
                              title: titleCtrl.text.trim(),
                              amount: double.parse(amountCtrl.text),
                              date: selectedDate,
                            );
                          } else {
                            await provider.updateSpecialEventExpense(
                              event.id,
                              expense.id,
                              title: titleCtrl.text.trim(),
                              amount: double.parse(amountCtrl.text),
                              date: selectedDate,
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (ctx.mounted) ToastUtils.showInfo(ctx, 'Error: $e');
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(expense == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Delete confirm ───────────────────────────────────────────────────
  void _confirmDeleteExpense(
    BuildContext context,
    HomeProvider provider,
    String expenseId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          await provider.deleteSpecialEventExpense(event.id, expenseId);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final sym = settings.getCurrencySymbol(provider.appSettings.currency);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(event.title)),
      body: StreamBuilder<List<SpecialEventExpense>>(
        stream: provider.getSpecialEventExpenses(event.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snap.data ?? [];
          final totalSpent =
              expenses.fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              // ── Summary card ──
              Builder(builder: (context) {
                final isOverBudget = totalSpent > event.budget;
                return Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  color: isOverBudget ? Colors.red : const Color(0xFFE8F5E9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'Up to now total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: isOverBudget
                                ? Colors.white70
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$sym ${totalSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isOverBudget ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Budget: $sym ${event.budget.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isOverBudget
                                ? Colors.white70
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ── Expenses list ──
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 12),
                            const Text('No expenses yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: expenses.length,
                        itemBuilder: (context, i) {
                          final exp = expenses[i];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.25),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exp.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$sym ${exp.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          DateFormat('MMM d, yyyy')
                                              .format(exp.date),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            size: 20, color: Colors.grey),
                                        onPressed: () => _showExpenseDialog(
                                            context, provider,
                                            expense: exp),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        onPressed: () =>
                                            _confirmDeleteExpense(
                                                context, provider, exp.id),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }
}
