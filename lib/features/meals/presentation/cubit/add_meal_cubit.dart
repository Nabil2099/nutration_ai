import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/meal_analysis.dart';
import '../../data/models/suggested_food.dart';
import '../../data/services/meal_photo_analyzer.dart';
import 'add_meal_state.dart';

typedef MealSaver = Future<void> Function({
  required String name,
  required String mealType,
  required double servingGrams,
  required double caloriesKcal,
  required double proteinG,
  required double carbsG,
  required double fatG,
});

class AddMealCubit extends Cubit<AddMealState> {
  AddMealCubit({this.onSave, this.photoAnalyzer})
    : super(
        AddMealState(
          mealType: 'Lunch',
          query: '',
          portions: {SuggestedFood.suggestions.first.name: 100},
        ),
      );

  final MealSaver? onSave;
  final MealPhotoAnalyzerFn? photoAnalyzer;

  void selectMealType(String mealType) {
    if (AddMealState.mealTypes.contains(mealType)) {
      emit(_copyWith(mealType: mealType, clearError: true));
    }
  }

  void search(String query) => emit(_copyWith(query: query.trim()));

  void toggleFood(SuggestedFood food) {
    final portions = Map<String, int>.from(state.portions);
    if (portions.containsKey(food.name)) {
      portions.remove(food.name);
    } else {
      portions[food.name] = 100;
    }
    emit(_copyWith(portions: portions, clearError: true));
  }

  void setPortion(SuggestedFood food, int grams) {
    final portions = Map<String, int>.from(state.portions);
    if (grams <= 0) {
      portions.remove(food.name);
    } else {
      portions[food.name] = grams.clamp(0, 2000);
    }
    emit(_copyWith(portions: portions, clearError: true));
  }

  void toggleFilterByMealType() =>
      emit(_copyWith(filterByMealType: !state.filterByMealType));

  /// Adds a user-defined custom food/meal and selects it with [servingGrams].
  void addCustomFood({
    required String name,
    required double servingGrams,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    String emoji = '🍽️',
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || servingGrams <= 0) return;
    final factor = 100 / servingGrams;
    final custom = SuggestedFood(
      name: trimmed,
      subtitle: 'Custom · ${state.mealType}',
      caloriesPer100g: calories * factor,
      proteinPer100g: proteinG * factor,
      carbsPer100g: carbsG * factor,
      fatPer100g: fatG * factor,
      emoji: emoji,
      mealTypes: {state.mealType},
    );
    final updatedCustom = [
      custom,
      ...state.customFoods.where((f) => f.name != trimmed),
    ];
    final portions = Map<String, int>.from(state.portions);
    portions[trimmed] = servingGrams.round().clamp(1, 2000);
    emit(
      _copyWith(
        customFoods: updatedCustom,
        portions: portions,
        clearError: true,
      ),
    );
  }

  /// Analyzes a meal photo via AI, then pre-selects every detected food at
  /// its estimated portion. Returns an error message on failure, or `null`
  /// on success.
  Future<String?> analyzePhoto(Uint8List imageBytes) async {
    final analyzer = photoAnalyzer;
    if (analyzer == null) {
      return 'Photo scan will be available when the AI service is connected.';
    }
    if (state.analyzing) return null;

    emit(_copyWith(analyzing: true));
    try {
      final analysis = await analyzer(
        imageBytes,
        mealTypeHint: state.mealType,
      );
      if (isClosed) return null;

      // Portion every detected food at its estimated weight; drop items from
      // a previous scan that no longer appear in this one.
      final newNames = {for (final item in analysis.items) item.name};
      final oldNames = {for (final food in state.scannedFoods) food.name};
      final portions = Map<String, int>.from(state.portions)
        ..removeWhere(
          (name, _) => oldNames.contains(name) && !newNames.contains(name),
        );
      for (final item in analysis.items) {
        portions[item.name] = item.grams.round().clamp(1, 2000);
      }

      emit(
        _copyWith(
          analyzing: false,
          analysis: analysis,
          portions: portions,
          // Make sure freshly scanned foods are visible regardless of the
          // previous search term.
          query: '',
          clearError: true,
        ),
      );
      return null;
    } on MealPhotoAnalyzerException catch (e) {
      if (!isClosed) emit(_copyWith(analyzing: false));
      return e.message;
    } catch (_) {
      if (!isClosed) emit(_copyWith(analyzing: false));
      return 'Could not analyze the photo. Check your connection and try again.';
    }
  }

  /// Removes the latest scan result and deselects its foods.
  void clearScan() {
    if (state.analysis == null) return;
    final scannedNames = {for (final food in state.scannedFoods) food.name};
    final portions = Map<String, int>.from(state.portions)
      ..removeWhere((name, _) => scannedNames.contains(name));
    emit(_copyWith(clearAnalysis: true, portions: portions, clearError: true));
  }

  /// Persists the selected foods as a single meal entry. Returns `true` if
  /// saved successfully, `false` otherwise.
  Future<bool> submit() async {
    final foods = state.selectedFoods;
    if (foods.isEmpty || state.saving) return false;
    final save = onSave;
    if (save == null) {
      emit(
        _copyWith(
          errorMessage: 'Meal selected. Saving will be enabled when the meal service is connected.',
        ),
      );
      return false;
    }
    emit(_copyWith(saving: true, clearError: true));
    final joinedName = foods.map((f) => f.name).join(' + ');
    final safeName = joinedName.length > 200
        ? joinedName.substring(0, 200)
        : joinedName;
    final totalGrams = foods.fold<double>(
      0,
      (sum, f) => sum + (state.portions[f.name] ?? 0),
    );
    try {
      await save(
        name: safeName,
        mealType: state.mealType.toLowerCase(),
        servingGrams: totalGrams,
        caloriesKcal: state.calories,
        proteinG: state.protein,
        carbsG: state.carbs,
        fatG: state.fat,
      );
      if (!isClosed) emit(_copyWith(saving: false));
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(
          _copyWith(
            saving: false,
            errorMessage:
                'Could not save meal. Check your connection and retry.',
          ),
        );
      }
      return false;
    }
  }

  AddMealState _copyWith({
    String? mealType,
    String? query,
    Map<String, int>? portions,
    List<SuggestedFood>? customFoods,
    bool? filterByMealType,
    bool? saving,
    bool? analyzing,
    MealAnalysis? analysis,
    bool clearAnalysis = false,
    String? errorMessage,
    bool clearError = false,
  }) => AddMealState(
    mealType: mealType ?? state.mealType,
    query: query ?? state.query,
    portions: portions ?? state.portions,
    customFoods: customFoods ?? state.customFoods,
    filterByMealType: filterByMealType ?? state.filterByMealType,
    saving: saving ?? state.saving,
    analyzing: analyzing ?? state.analyzing,
    analysis: clearAnalysis ? null : (analysis ?? state.analysis),
    errorMessage: clearError ? null : (errorMessage ?? state.errorMessage),
  );
}
