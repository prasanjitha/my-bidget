import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialEventExpense {
  final String id;
  final String eventId;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final DateTime? createdAt;

  SpecialEventExpense({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    this.createdAt,
  });

  factory SpecialEventExpense.fromMap(Map<String, dynamic> map, String id) {
    return SpecialEventExpense(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: map['amount'] != null
          ? (map['amount'] as num).toDouble()
          : 0.0,
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  SpecialEventExpense copyWith({
    String? title,
    double? amount,
    DateTime? date,
  }) {
    return SpecialEventExpense(
      id: id,
      eventId: eventId,
      userId: userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
