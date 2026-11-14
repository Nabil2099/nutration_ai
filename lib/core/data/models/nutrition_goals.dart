class NutritionGoals {
  const NutritionGoals({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
  static const defaults = NutritionGoals(
    calories: 2000,
    proteinG: 120,
    carbsG: 220,
    fatG: 65,
  );
  final double calories, proteinG, carbsG, fatG;
  factory NutritionGoals.fromMap(Map<String, dynamic> map) {
    double read(String key) {
      final value = map[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw FormatException('Invalid goal: $key');
      }
      return value.toDouble();
    }

    return NutritionGoals(
      calories: read('calories'),
      proteinG: read('proteinG'),
      carbsG: read('carbsG'),
      fatG: read('fatG'),
    );
  }
  bool get isValid =>
      calories.isFinite &&
      calories > 0 &&
      calories <= 10000 &&
      [proteinG, carbsG, fatG].every((v) => v.isFinite && v >= 0 && v <= 1000);
  Map<String, dynamic> toMap() => {
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };
}
