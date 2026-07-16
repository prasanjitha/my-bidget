import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';
import '../../domain/models/category.dart';
import 'category_progress_bar.dart';
import '../../../../core/utils/number_input_formatter.dart';
import '../../../../core/utils/toast_utils.dart';

class CategoryBudgetCard extends StatefulWidget {
  const CategoryBudgetCard({super.key});

  @override
  State<CategoryBudgetCard> createState() => _CategoryBudgetCardState();
}

class _CategoryBudgetCardState extends State<CategoryBudgetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final categories = homeProvider.categories;
    final currency = homeProvider.appSettings.currency;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Color(0xFF333333),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No categories yet. Add one below!',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ...categories.asMap().entries.map((entry) => _buildCategoryItem(
                  context,
                  entry.value,
                  currency,
                  homeProvider,
                  entry.key,
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context, homeProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'Add New Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Category category,
    String currency,
    HomeProvider provider,
    int index,
  ) {
    final spent = provider.getCategorySpent(category.id);
    final allocated = category.allocatedBudget;
    final remaining = allocated - spent;

    // Different colors for each category
    final colors = [
      {'bg': const Color(0xFFFFF3E0), 'icon': Colors.orange.shade700},
      {'bg': const Color(0xFFE8F5E9), 'icon': Colors.green.shade700},
      {'bg': const Color(0xFFF3E5F5), 'icon': Colors.purple.shade700},
      {'bg': const Color(0xFFE1F5FE), 'icon': Colors.blue.shade700},
      {'bg': const Color(0xFFFCE4EC), 'icon': Colors.pink.shade700},
      {'bg': const Color(0xFFFFF9C4), 'icon': Colors.amber.shade800},
    ];
    final colorSet = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: colorSet['bg'] as Color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (colorSet['icon'] as Color).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: colorSet['icon'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        color: colorSet['icon'] as Color,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showSetCategoryBudgetDialog(
                    context,
                    provider,
                    category,
                    currency,
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    foregroundColor: colorSet['icon'] as Color,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SET',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CategoryProgressBar(spent: spent, allocated: allocated),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allocated: ${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(allocated)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: (colorSet['icon'] as Color).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  'Remaining: ${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(remaining)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: remaining < 0 ? Colors.red.shade700 : Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSetCategoryBudgetDialog(
    BuildContext context,
    HomeProvider provider,
    Category category,
    String currency,
  ) {
    // Format initial value with commas
    final initialValue = category.allocatedBudget > 0
        ? NumberFormat('#,##0.##').format(category.allocatedBudget)
        : '';

    final budgetController = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${category.name}'),
        content: TextField(
          controller: budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            ThousandsSeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            border: const OutlineInputBorder(),
            prefixText: '${_getCurrencySymbol(currency)} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Remove commas before parsing
              final cleanText = budgetController.text.replaceAll(',', '');
              final budget = double.tryParse(cleanText);

              if (budget == null || budget < 0) {
                ToastUtils.showError(context, 'Please enter a valid amount');
                return;
              }

              await provider.updateCategoryBudget(category.id, budget);
              if (context.mounted) {
                Navigator.of(context).pop();
                ToastUtils.showSuccess(context, 'Category budget updated');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, HomeProvider provider) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ToastUtils.showError(context, 'Please enter a category name');
                return;
              }

              try {
                await provider.createCategory(name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ToastUtils.showSuccess(context, 'Category created successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showError(context, e.toString());
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
