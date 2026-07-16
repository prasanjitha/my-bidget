import 'package:cloud_firestore/cloud_firestore.dart';

class Savings {
  final String id;
  final String userId;
  final String month; // Format: "YYYY-MM"
  final double amount;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Savings({
    required this.id,
    required this.userId,
    required this.month,
    required this.amount,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory Savings.fromMap(Map<String, dynamic> map, String id) {
    return Savings(
      id: id,
      userId: map['userId'] as String,
      month: map['month'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'month': month,
      'amount': amount,
      'currency': currency,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  Savings copyWith({
    double? amount,
    String? currency,
    DateTime? updatedAt,
  }) {
    return Savings(
      id: id,
      userId: userId,
      month: month,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
