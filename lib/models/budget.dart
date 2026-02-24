import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String category;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime month;
  
  @HiveField(4)
  final DateTime createdAt;

  Budget({
    String? id,
    required this.category,
    required this.amount,
    required this.month,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? month,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      month: DateTime.parse(map['month']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Get month key for storage (YYYY-MM format)
  String get monthKey => '${month.year}-${month.month.toString().padLeft(2, '0')}';
}
