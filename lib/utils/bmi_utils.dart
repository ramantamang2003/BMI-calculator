import '../models/gender.dart';

class BmiResult {
  const BmiResult({
    required this.value,
    required this.category,
    required this.message,
  });

  final double value;
  final String category;
  final String message;
}

class BmiUtils {
  static BmiResult calculate({
    required int weightKg,
    required double heightCm,
  }) {
    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);
    final String category = categoryFromBmi(bmi);

    return BmiResult(
      value: bmi,
      category: category,
      message: healthMessageFromCategory(category),
    );
  }

  static String categoryFromBmi(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    }
    if (bmi < 25) {
      return 'Normal';
    }
    if (bmi < 30) {
      return 'Overweight';
    }
    return 'Obese';
  }

  static String healthMessageFromCategory(String category) {
    switch (category) {
      case 'Underweight':
        return 'Plan to move toward normal: increase calorie intake with protein-rich meals, add 3 to 4 strength sessions per week, and track weight weekly. Aim for slow, steady gain.';
      case 'Normal':
        return 'You are in the normal range. Maintain it with balanced meals, regular exercise, good sleep, and monthly weight checks so you stay on track.';
      case 'Overweight':
        return 'Plan to reach normal: reduce sugary drinks and oversized portions, walk or exercise most days, and use a small calorie deficit. Target gradual fat loss.';
      default:
        return 'Plan to improve safely: speak with a healthcare professional, follow a calorie-controlled meal plan, start low-impact activity, and aim for gradual weight loss toward the normal range.';
    }
  }

  static String? validateInputs({
    required Gender? gender,
    required int age,
    required int weightKg,
    required double heightCm,
  }) {
    if (gender == null) {
      return 'Please select a gender before calculating BMI.';
    }
    if (age < 1 || age > 120) {
      return 'Age must be between 1 and 120.';
    }
    if (weightKg < 1 || weightKg > 300) {
      return 'Weight must be between 1 and 300 kg.';
    }
    if (heightCm < 80 || heightCm > 250) {
      return 'Height must be between 80 and 250 cm.';
    }
    return null;
  }
}
