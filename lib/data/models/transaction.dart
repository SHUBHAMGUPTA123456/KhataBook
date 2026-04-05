import './category.dart';

class AppTransaction {
  int? id;
  int partyId;
  double amount;
  String type; // 'given' or 'received'
  DateTime date;
  String? note;
  Category? category;
  String? imagePath; // NEW: local file path to attached image

  AppTransaction({
    this.id,
    required this.partyId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.category,
    this.imagePath, // NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'category': category?.name,
      'imagePath': imagePath, // NEW
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    Category? category;
    if (map['category'] != null) {
      try {
        category = Category.values.byName(map['category']);
      } catch (e) {
        category = Category.others;
      }
    }

    return AppTransaction(
      id: map['id'],
      partyId: map['partyId'],
      amount: map['amount'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      category: category,
      imagePath: map['imagePath'], // NEW
    );
  }
}