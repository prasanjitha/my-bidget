import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/expense.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import 'all_expenses_screen.dart';
import 'categories_screen.dart';
import '../../../../core/utils/toast_utils.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final expenses = homeProvider.expenses;
    final categories = homeProvider.categories;

    List<Expense> filteredExpenses = expenses;

    if (_searchQuery.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((expense) {
        final descriptionMatch = expense.description
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final amountMatch = expense.amount.toString().contains(_searchQuery);
        return descriptionMatch || amountMatch;
      }).toList();
    }

    if (_selectedCategoryFilter != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.categoryId == _selectedCategoryFilter)
          .toList();
    }

    final groupedExpenses = _groupExpensesByDate(filteredExpenses);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCategoryFilter(context, categories),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AllExpensesScreen(),
                ),
              );
            },
            tooltip: 'View All',
          ),
        ],
      ),
      body: expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add one',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : filteredExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No expenses found',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_selectedCategoryFilter != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Chip(
                          label: Text(
                            _getCategoryName(
                                _selectedCategoryFilter!, categories),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedCategoryFilter = null;
                            });
                          },
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // Refresh is automatic via streams
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          itemCount: groupedExpenses.length,
                          itemBuilder: (context, index) {
                            final dateGroup = groupedExpenses[index];
                            return _buildDateGroup(
                                dateGroup, homeProvider, categories);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildDateGroup(Map<String, dynamic> dateGroup,
      HomeProvider homeProvider, List categories) {
    final date = dateGroup['date'] as DateTime;
    final expenses = dateGroup['expenses'] as List<Expense>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            DateFormat('MMMM dd, EEEE').format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[700],
            ),
          ),
        ),
        ...expenses.map((expense) => _buildExpenseCard(
              expense,
              homeProvider,
              categories,
            )),
      ],
    );
  }

  Widget _buildExpenseCard(
      Expense expense, HomeProvider homeProvider, List categories) {
    final category = categories.where((cat) => cat.id == expense.categoryId).firstOrNull;
    final currency = homeProvider.appSettings.currency;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side - Category and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name with badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category?.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side - Amount and Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount
                Text(
                  '${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _editExpense(expense),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _deleteExpense(expense, homeProvider),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  void _showCategoryFilter(BuildContext context, List categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedCategoryFilter != null)
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Filter'),
                onTap: () {
                  setState(() {
                    _selectedCategoryFilter = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
            const Divider(),
            ...categories.map((category) => ListTile(
                  leading: Icon(_getCategoryIcon(category.name)),
                  title: Text(category.name),
                  trailing: _selectedCategoryFilter == category.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = category.id;
                    });
                    Navigator.of(context).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String categoryId, List categories) {
    final category = categories.where((cat) => cat.id == categoryId).firstOrNull;
    return category?.name ?? 'Unknown';
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
