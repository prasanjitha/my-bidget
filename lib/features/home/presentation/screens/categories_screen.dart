import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../domain/models/category.dart';
import '../widgets/category_dialog.dart';
import '../../../../core/utils/toast_utils.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final categories = homeProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        elevation: 0,
      ),
      body: categories.isEmpty
          ? _buildEmptyState(context)
          : _buildCategoryList(context, categories),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No categories yet',
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
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    // Group categories
    final defaultCategories = categories.where((c) => c.isDefault).toList();
    final customCategories = categories.where((c) => !c.isDefault).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (defaultCategories.isNotEmpty) ...[
          Text(
            'Default Categories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ...defaultCategories.map((category) => _buildCategoryTile(context, category)),
          const SizedBox(height: 24),
        ],
        if (customCategories.isNotEmpty) ...[
          Text(
            'Custom Categories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ...customCategories.map((category) => _buildCategoryTile(context, category)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(category.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _confirmDelete(context, category),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: category.isDefault ? Colors.blue.shade100 : Colors.purple.shade100,
            child: Icon(
              Icons.category,
              color: category.isDefault ? Colors.blue.shade700 : Colors.purple.shade700,
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            category.isDefault ? 'Default Category' : 'Custom Category',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showCategoryDialog(context, category: category),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: () => _deleteCategory(context, category),
                tooltip: 'Delete',
              ),
            ],
          ),
          onLongPress: () => _showCategoryDialog(context, category: category),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    showDialog(
      context: context,
      builder: (context) => CategoryDialog(category: category),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Category category) async {
    final homeProvider = context.read<HomeProvider>();

    // Check if category has expenses
    try {
      final hasExpenses = await homeProvider.categoryHasExpenses(category.id);

      if (hasExpenses) {
        if (context.mounted) {
          ToastUtils.showError(
            context,
            'Cannot delete "${category.name}" - it has expenses in current budget cycle',
          );
        }
        return false;
      }

      // Show confirmation dialog
      if (context.mounted) {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Category'),
                content: Text(
                  'Are you sure you want to delete "${category.name}"?',
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
            ) ??
            false;
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(
          context,
          'Error: ${e.toString().replaceAll("Exception: ", "")}',
        );
      }
    }

    return false;
  }

  Future<void> _deleteCategory(BuildContext context, Category category) async {
    final homeProvider = context.read<HomeProvider>();
    final confirmed = await _confirmDelete(context, category);
    if (!confirmed) return;

    try {
      await homeProvider.deleteCategory(category.id);

      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Category deleted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }
}
