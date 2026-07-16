import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/budget_cycle.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/budget_cycle_selector.dart';
import '../../../../core/utils/budget_cycle_util.dart';
import '../../../../core/utils/toast_utils.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  BudgetCycle? _selectedCycle;
  List<BudgetCycle> _budgetCycles = [];
  late BudgetCycle _currentCycle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final startDay = homeProvider.appSettings.budgetCycleStartDay;

      // Generate cycles for the last 12 months
      _currentCycle = BudgetCycleUtil.getCurrentCycle(startDay);
      _budgetCycles = BudgetCycleUtil.getPastCycles(12, startDay);

      setState(() {
        _selectedCycle = _currentCycle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_budgetCycles.isNotEmpty && _selectedCycle != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BudgetCycleSelector(
                currentCycle: _currentCycle,
                selectedCycle: _selectedCycle,
                cycles: _budgetCycles,
                onCycleSelected: (cycle) {
                  setState(() {
                    _selectedCycle = cycle;
                  });
                },
              ),
            ),
          Expanded(
            child: _selectedCycle == null
                ? const Center(child: CircularProgressIndicator())
                : _buildExpenseList(homeProvider, _selectedCycle!),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(HomeProvider homeProvider, BudgetCycle budgetCycle) {
    // Convert BudgetCycle to simple cycle string for backwards compatibility
    final cycleString = BudgetCycleUtil.getSimpleCycleString(budgetCycle.startDate, homeProvider.appSettings.budgetCycleStartDay);

    return StreamBuilder<List<Expense>>(
      stream: homeProvider.getExpensesForCycle(cycleString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final expenses = snapshot.data ?? [];

        if (expenses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No expenses for this cycle',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final groupedExpenses = _groupExpensesByDate(expenses);

        return ListView.builder(
          itemCount: groupedExpenses.length,
          itemBuilder: (context, index) {
            final dateGroup = groupedExpenses[index];
            return _buildDateGroup(dateGroup, homeProvider);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};

    for (var expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }

    final List<Map<String, dynamic>> result = [];
    grouped.forEach((dateKey, expenses) {
      result.add({
        'date': DateTime.parse(dateKey),
        'expenses': expenses,
      });
    });

    result.sort((a, b) => (b['date'] as DateTime).compareTo(a['date']));

    return result;
  }

  Widget _buildDateGroup(
      Map<String, dynamic> dateGroup, HomeProvider homeProvider) {
    final date = dateGroup['date'] as DateTime;
    final expenses = dateGroup['expenses'] as List<Expense>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Text(
            DateFormat('MMMM dd, EEEE').format(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ...expenses.map((expense) => _buildExpenseCard(expense, homeProvider)),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense, HomeProvider homeProvider) {
    final categories = homeProvider.categories;
    final category = categories.where((cat) => cat.id == expense.categoryId).firstOrNull;
    final currency = homeProvider.appSettings.currency;

    return ExpansionTile(
      leading: CircleAvatar(
        child: Icon(_getCategoryIcon(category?.name ?? '')),
      ),
      title: Text(
        expense.description,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(category?.name ?? 'Unknown'),
      trailing: Text(
        '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(expense.amount)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${DateFormat('MMM dd, yyyy').format(expense.date)}'),
                    Text('Category: ${category?.name ?? 'Unknown'}'),
                    Text('Budget Cycle: ${expense.budgetCycle}'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editExpense(expense),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteExpense(expense, homeProvider),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editExpense(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseBottomSheet(expense: expense),
    );
  }

  Future<void> _deleteExpense(
      Expense expense, HomeProvider homeProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await homeProvider.deleteExpense(expense.id);
        if (mounted) {
          ToastUtils.showSuccess(context, 'Expense deleted');
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showError(context, 'Error: ${e.toString()}');
        }
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'rent':
        return Icons.home;
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'utilities':
        return Icons.lightbulb;
      default:
        return Icons.category;
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
