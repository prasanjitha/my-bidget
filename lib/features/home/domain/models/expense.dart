import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final String budgetCycle;

  Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.budgetCycle,
  });

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      userId: map['userId'] as String? ?? '',
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      date: (map['date'] as Timestamp).toDate(),
      budgetCycle: map['budgetCycle'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'budgetCycle': budgetCycle,
    };
  }
}
