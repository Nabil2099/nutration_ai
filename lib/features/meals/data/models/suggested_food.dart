class SuggestedFood {
  const SuggestedFood({
    required this.name,
    required this.subtitle,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.emoji,
  });

  final String name;
  final String subtitle;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String emoji;

  static const suggestions = [
    SuggestedFood(
      name: 'Grilled Chicken Breast',
      subtitle: 'Lean poultry · Skinless',
      caloriesPer100g: 220,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
      emoji: '🍗',
    ),
    SuggestedFood(
      name: 'Steamed Broccoli',
      subtitle: 'Fresh vegetables · Steamed',
      caloriesPer100g: 37,
      proteinPer100g: 2.4,
      carbsPer100g: 7.2,
      fatPer100g: 0.4,
      emoji: '🥦',
    ),
    SuggestedFood(
      name: 'Brown Rice',
      subtitle: 'Whole grain · Cooked',
      caloriesPer100g: 123,
      proteinPer100g: 2.7,
      carbsPer100g: 25.6,
      fatPer100g: 1,
      emoji: '🍚',
    ),
  ];
}
