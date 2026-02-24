import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  @HiveField(6, defaultValue: false)
  final bool isRecurring;

  @HiveField(7)
  final String? frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(8)
  final DateTime? nextDueDate;

  @HiveField(9)
  final DateTime? endDate;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.frequency,
    this.nextDueDate,
    this.endDate,
  }) : id = id ?? const Uuid().v4();

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool? isRecurring,
    String? frequency,
    DateTime? nextDueDate,
    DateTime? endDate,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'isRecurring': isRecurring,
      'frequency': frequency,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      isRecurring: map['isRecurring'] ?? false,
      frequency: map['frequency'],
      nextDueDate: map['nextDueDate'] != null
          ? DateTime.parse(map['nextDueDate'])
          : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}
