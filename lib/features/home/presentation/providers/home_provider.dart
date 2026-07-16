import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/savings.dart';
import '../../data/repositories/home_repository.dart';

class HomeProvider with ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  String? _userId;
  UserProfile? _userProfile;
  AppSettings _appSettings = AppSettings();
  List<Category> _categories = [];
  List<Expense> _expenses = [];

  StreamSubscription? _profileSubscription;
  StreamSubscription? _appSettingsSubscription;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _expensesSubscription;

  UserProfile? get userProfile => _userProfile;
  AppSettings get appSettings => _appSettings;
  List<Category> get categories => _categories;
  List<Expense> get expenses => _expenses;

  String get currentBudgetCycle {
    return _repository.getCurrentBudgetCycle(_appSettings.budgetCycleStartDay);
  }

  String getBudgetCycleForDate(DateTime date) {
    return _repository.getBudgetCycleForDate(
      date,
      _appSettings.budgetCycleStartDay,
    );
  }

  Stream<List<Expense>> getExpensesForCycle(String budgetCycle) {
    return _repository.getExpenses(budgetCycle);
  }

  double get totalSpent {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBalance {
    return _appSettings.monthlyAllocation - totalSpent;
  }

  void initialize(String userId) {
    _userId = userId;
    _loadData();
    _repository.initializeDefaultCategories();
  }

  void _loadData() {
    if (_userId == null) return;

    // Listen to app settings (shared for all users)
    _appSettingsSubscription?.cancel();
    _appSettingsSubscription = _repository.getAppSettings().listen((settings) {
      _appSettings = settings;
      notifyListeners();
      _loadExpenses();
    });

    // Listen to user profile (user-specific data like name)
    _profileSubscription?.cancel();
    _profileSubscription = _repository.getUserProfile(_userId!).listen((profile) {
      _userProfile = profile;
      notifyListeners();
    });

    // Listen to categories (shared for all users)
    _categoriesSubscription?.cancel();
    _categoriesSubscription = _repository.getCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  void _loadExpenses() {
    _expensesSubscription?.cancel();
    _expensesSubscription = _repository
        .getExpenses(currentBudgetCycle)
        .listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  /// Public method to force reload expenses
  void reloadExpenses() {
    _loadExpenses();
  }

  Future<void> setMonthlyBudget(double amount, String currency) async {
    await _repository.setMonthlyBudget(amount, currency);
  }

  Future<void> updateUserName(String name) async {
    if (_userId == null) return;
    await _repository.updateUserProfile(_userId!, {'name': name});
  }

  Future<void> updateBudgetCycleStartDay(int startDay) async {
    await _repository.updateAppSettings({'budgetCycleStartDay': startDay});
    // Expenses will be reloaded automatically via stream
  }

  Future<void> updateCurrency(String currency) async {
    await _repository.updateAppSettings({'currency': currency});
  }

  Future<String> createCategory(String categoryName) async {
    return await _repository.createCategory(categoryName);
  }

  Future<void> updateCategory(String categoryId, String categoryName) async {
    await _repository.updateCategory(categoryId, categoryName);
  }

  Future<void> updateCategoryBudget(String categoryId, double budget) async {
    await _repository.updateCategoryBudget(categoryId, budget);
  }

  Future<double> getCategorySpent(String categoryId) async {
    return await _repository.getCategorySpent(categoryId, currentBudgetCycle);
  }

  Future<void> addExpense({
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final budgetCycle = _repository.getBudgetCycleForDate(
      date,
      _appSettings.budgetCycleStartDay,
    );

    await _repository.addExpense(
      userId: _userId!,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
      budgetCycle: budgetCycle,
    );

    // Force reload to ensure UI updates
    _loadExpenses();
    notifyListeners();
  }

  Future<void> updateExpense({
    required String expenseId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final budgetCycle = _repository.getBudgetCycleForDate(
      date,
      _appSettings.budgetCycleStartDay,
    );

    await _repository.updateExpense(
      expenseId: expenseId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
      budgetCycle: budgetCycle,
    );

    // Force reload to ensure UI updates
    _loadExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    await _repository.deleteExpense(expenseId);

    // Force reload to ensure UI updates
    _loadExpenses();
    notifyListeners();
  }

  Future<bool> categoryHasExpenses(String categoryId) async {
    return await _repository.categoryHasExpenses(
      categoryId,
      currentBudgetCycle,
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    final hasExpenses = await categoryHasExpenses(categoryId);
    if (hasExpenses) {
      throw Exception('Cannot delete category with expenses in current cycle');
    }

    await _repository.deleteCategory(categoryId);
  }

  Future<double> getTodaySpent() async {
    return await _repository.getTodaySpent();
  }

  Stream<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _repository.getExpensesByDateRange(startDate, endDate);
  }

  Future<Map<String, double>> getMonthlySummary(String budgetCycle) async {
    return await _repository.getMonthlySummary(budgetCycle);
  }

  Future<List<String>> getPastBudgetCycles(int count) async {
    return await _repository.getPastBudgetCycles(
      _appSettings.budgetCycleStartDay,
      count,
    );
  }

  // Savings methods
  Stream<List<Savings>> getSavings() {
    return _repository.getSavings();
  }

  Future<String> addSavings({
    required String month,
    required double amount,
  }) async {
    if (_userId == null) throw Exception('User not logged in');
    return await _repository.addSavings(
      userId: _userId!,
      month: month,
      amount: amount,
      currency: _appSettings.currency,
    );
  }

  Future<void> updateSavings(String savingsId, double amount) async {
    await _repository.updateSavings(savingsId, amount);
  }

  Future<void> deleteSavings(String savingsId) async {
    await _repository.deleteSavings(savingsId);
  }

  Future<double> getTotalSavings() async {
    return await _repository.getTotalSavings();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _appSettingsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _expensesSubscription?.cancel();
    super.dispose();
  }
}
