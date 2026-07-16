import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialEvent {
  final String id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final DateTime? createdAt;

  SpecialEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.createdAt,
  });

  factory SpecialEvent.fromMap(Map<String, dynamic> map, String id) {
    return SpecialEvent(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      budget: map['budget'] != null
          ? (map['budget'] as num).toDouble()
          : 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'budget': budget,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  SpecialEvent copyWith({
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) {
    return SpecialEvent(
      id: id,
      userId: userId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      createdAt: createdAt,
    );
  }
}
