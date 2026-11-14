// Shared read contract only. Meals owner supplies the service and CRUD.
class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.mealType,
    required this.consumedAt,
    required this.localDayKey,
    required this.servingGrams,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
  final String id, name, mealType, localDayKey;
  final DateTime consumedAt;
  final double servingGrams, caloriesKcal, proteinG, carbsG, fatG;
}
