import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/suggested_food.dart';
import 'add_meal_state.dart';

class AddMealCubit extends Cubit<AddMealState> {
  AddMealCubit()
    : super(
        AddMealState(
          mealType: 'Lunch',
          query: '',
          portions: {SuggestedFood.suggestions.first.name: 100},
        ),
      );

  void selectMealType(String mealType) {
    if (AddMealState.mealTypes.contains(mealType)) {
      emit(_copyWith(mealType: mealType));
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
    emit(_copyWith(portions: portions));
  }

  void setPortion(SuggestedFood food, int grams) {
    final portions = Map<String, int>.from(state.portions);
    if (grams <= 0) {
      portions.remove(food.name);
    } else {
      portions[food.name] = grams.clamp(0, 2000);
    }
    emit(_copyWith(portions: portions));
  }

  AddMealState _copyWith({
    String? mealType,
    String? query,
    Map<String, int>? portions,
  }) => AddMealState(
    mealType: mealType ?? state.mealType,
    query: query ?? state.query,
    portions: portions ?? state.portions,
  );
}
