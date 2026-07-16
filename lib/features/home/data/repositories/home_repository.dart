import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/savings.dart';
import '../../domain/models/special_event.dart';
import '../../domain/models/special_event_expense.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String appSettingsDocId = 'config';

  // App Settings methods
  Stream<AppSettings> getAppSettings() {
    return _firestore
        .collection('app_settings')
        .doc(appSettingsDocId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        // Return default settings if document doesn't exist
        return AppSettings();
      }
      return AppSettings.fromMap(snapshot.data()!);
    });
  }

  Future<void> updateAppSettings(Map<String, dynamic> data) async {
    await _firestore
        .collection('app_settings')
        .doc(appSettingsDocId)
        .set(data, SetOptions(merge: true));

    // If budget cycle start day is updated, recalculate all expenses
    if (data.containsKey('budgetCycleStartDay')) {
      final newStartDay = data['budgetCycleStartDay'] as int;
      await _recalculateAllExpenseCycles(newStartDay);
    }
  }

  Future<void> _recalculateAllExpenseCycles(int newStartDay) async {
    try {
      final snapshot = await _firestore.collection('expenses').get();

      final batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        final expenseData = doc.data();
        final date = (expenseData['date'] as Timestamp).toDate();
        final newCycle = getBudgetCycleForDate(date, newStartDay);

        batch.update(doc.reference, {'budgetCycle': newCycle});
        count++;

        // Commit batch every 500 operations (Firestore limit)
        if (count >= 500) {
          await batch.commit();
          count = 0;
        }
      }

      // Commit remaining operations
      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      // Log error but don't throw - allow settings update to succeed
    }
  }

  Future<void> setMonthlyBudget(double amount, String currency) async {
    await _firestore.collection('app_settings').doc(appSettingsDocId).set({
      'monthlyAllocation': amount,
      'currency': currency,
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> getUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return UserProfile.fromMap(snapshot.data()!, userId);
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  Stream<List<Category>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<String> createCategory(String categoryName) async {
    // Trim and validate
    final trimmedName = categoryName.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Category name is required');
    }

    if (trimmedName.length > 50) {
      throw Exception('Category name too long (max 50 characters)');
    }

    // Case-insensitive duplicate check
    final existingCategories = await _firestore
        .collection('categories')
        .get();

    final nameExists = existingCategories.docs.any((doc) {
      final existingName = (doc.data()['name'] as String).toLowerCase();
      return existingName == trimmedName.toLowerCase();
    });

    if (nameExists) {
      throw Exception('Category already exists');
    }

    final docRef = await _firestore
        .collection('categories')
        .add({
      'name': trimmedName,
      'isDefault': false,
      'allocatedBudget': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateCategory(String categoryId, String categoryName) async {
    // Trim and validate
    final trimmedName = categoryName.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Category name is required');
    }

    if (trimmedName.length > 50) {
      throw Exception('Category name too long (max 50 characters)');
    }

    // Case-insensitive duplicate check (excluding current category)
    final existingCategories = await _firestore
        .collection('categories')
        .get();

    final nameExists = existingCategories.docs.any((doc) {
      if (doc.id == categoryId) return false; // Skip current category
      final existingName = (doc.data()['name'] as String).toLowerCase();
      return existingName == trimmedName.toLowerCase();
    });

    if (nameExists) {
      throw Exception('Category name already exists');
    }

    await _firestore
        .collection('categories')
        .doc(categoryId)
        .update({
      'name': trimmedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategoryBudget(String categoryId, double budget) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .update({'allocatedBudget': budget});
  }

  Stream<List<Expense>> getExpenses(String budgetCycle) {
    return _firestore
        .collection('expenses')
        .where('budgetCycle', isEqualTo: budgetCycle)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<double> getCategorySpent(String categoryId, String budgetCycle) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('categoryId', isEqualTo: categoryId)
        .where('budgetCycle', isEqualTo: budgetCycle)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }
    return total;
  }

  Future<void> initializeDefaultCategories() async {
    // Check if any default categories already exist
    final defaultCategories = await _firestore
        .collection('categories')
        .where('isDefault', isEqualTo: true)
        .get();

    if (defaultCategories.docs.isNotEmpty) {
      return; // Default categories already exist
    }

    // Create default categories with retry logic
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final batch = _firestore.batch();

        final foodRef = _firestore
            .collection('categories')
            .doc();
        batch.set(foodRef, {
          'name': 'Food',
          'isDefault': true,
          'allocatedBudget': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final rentRef = _firestore
            .collection('categories')
            .doc();
        batch.set(rentRef, {
          'name': 'Rent',
          'isDefault': true,
          'allocatedBudget': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
        return; // Success
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          // Failed after max retries - allow app to continue
          return;
        }
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 100 * (1 << retryCount)));
      }
    }
  }

  String getCurrentBudgetCycle(int startDay) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (now.day < startDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    return '$year-${month.toString().padLeft(2, '0')}';
  }

  String getBudgetCycleForDate(DateTime date, int startDay) {
    int year = date.year;
    int month = date.month;

    if (date.day < startDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    return '$year-${month.toString().padLeft(2, '0')}';
  }

  Future<String> addExpense({
    required String userId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
    required String budgetCycle,
  }) async {
    final docRef = await _firestore.collection('expenses').add({
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'budgetCycle': budgetCycle,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateExpense({
    required String expenseId,
    required String categoryId,
    required double amount,
    required String description,
    required DateTime date,
    required String budgetCycle,
  }) async {
    await _firestore.collection('expenses').doc(expenseId).update({
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'budgetCycle': budgetCycle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  Future<bool> categoryHasExpenses(String categoryId, String budgetCycle) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('categoryId', isEqualTo: categoryId)
        .where('budgetCycle', isEqualTo: budgetCycle)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  Future<double> getTodaySpent() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }
    return total;
  }

  Stream<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Map<String, double>> getMonthlySummary(String budgetCycle) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('budgetCycle', isEqualTo: budgetCycle)
        .get();

    double totalSpent = 0.0;
    final Map<String, double> categorySpent = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num).toDouble();
      final categoryId = data['categoryId'] as String;

      totalSpent += amount;
      categorySpent[categoryId] = (categorySpent[categoryId] ?? 0.0) + amount;
    }

    return {
      'totalSpent': totalSpent,
      ...categorySpent,
    };
  }

  Future<List<String>> getPastBudgetCycles(int startDay, int count) async {
    final cycles = <String>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final date = DateTime(now.year, now.month - i, now.day);
      cycles.add(getBudgetCycleForDate(date, startDay));
    }

    return cycles;
  }

  // Savings methods
  Stream<List<Savings>> getSavings() {
    return _firestore
        .collection('savings')
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Savings.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<String> addSavings({
    required String userId,
    required String month,
    required double amount,
    required String currency,
  }) async {
    // Check for duplicate
    final existing = await _firestore
        .collection('savings')
        .where('month', isEqualTo: month)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Savings entry already exists for this month. Edit the existing entry instead.');
    }

    final docRef = await _firestore.collection('savings').add({
      'userId': userId,
      'month': month,
      'amount': amount,
      'currency': currency,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<void> updateSavings(String savingsId, double amount) async {
    await _firestore.collection('savings').doc(savingsId).update({
      'amount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSavings(String savingsId) async {
    await _firestore.collection('savings').doc(savingsId).delete();
  }

  Future<double> getTotalSavings() async {
    final snapshot = await _firestore
        .collection('savings')
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['amount'] as num).toDouble();
    }
    return total;
  }

  // ── Special Events ──────────────────────────────────────────────────

  Stream<List<SpecialEvent>> getSpecialEvents() {
    return _firestore
        .collection('special_events')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => SpecialEvent.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.startDate.compareTo(a.startDate));
      return list;
    });
  }

  Future<String> addSpecialEvent(SpecialEvent event) async {
    final ref = await _firestore.collection('special_events').add(event.toMap());
    return ref.id;
  }

  Future<void> updateSpecialEvent(String eventId, Map<String, dynamic> data) async {
    await _firestore.collection('special_events').doc(eventId).update(data);
  }

  Future<void> deleteSpecialEvent(String eventId) async {
    // Delete all sub-expenses first
    final expSnap = await _firestore
        .collection('special_events')
        .doc(eventId)
        .collection('expenses')
        .get();
    final batch = _firestore.batch();
    for (final doc in expSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.collection('special_events').doc(eventId));
    await batch.commit();
  }

  // ── Special Event Expenses (sub-collection) ─────────────────────────

  Stream<List<SpecialEventExpense>> getSpecialEventExpenses(String eventId) {
    return _firestore
        .collection('special_events')
        .doc(eventId)
        .collection('expenses')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => SpecialEventExpense.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<String> addSpecialEventExpense(SpecialEventExpense expense) async {
    final ref = await _firestore
        .collection('special_events')
        .doc(expense.eventId)
        .collection('expenses')
        .add(expense.toMap());
    return ref.id;
  }

  Future<void> updateSpecialEventExpense(
      String eventId, String expenseId, Map<String, dynamic> data) async {
    await _firestore
        .collection('special_events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .update(data);
  }

  Future<void> deleteSpecialEventExpense(String eventId, String expenseId) async {
    await _firestore
        .collection('special_events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
