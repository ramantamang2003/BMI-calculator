import 'dart:convert';

class BmiRecord {
  const BmiRecord({
    required this.id,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.category,
    required this.message,
    required this.createdAtIso,
  });

  final String id;
  final String gender;
  final int age;
  final double heightCm;
  final int weightKg;
  final double bmi;
  final String category;
  final String message;
  final String createdAtIso;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bmi': bmi,
      'category': category,
      'message': message,
      'createdAtIso': createdAtIso,
    };
  }

  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      id: map['id'] as String,
      gender: map['gender'] as String,
      age: map['age'] as int,
      heightCm: (map['heightCm'] as num).toDouble(),
      weightKg: map['weightKg'] as int,
      bmi: (map['bmi'] as num).toDouble(),
      category: map['category'] as String,
      message: map['message'] as String,
      createdAtIso: map['createdAtIso'] as String,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory BmiRecord.fromJson(String source) {
    return BmiRecord.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
