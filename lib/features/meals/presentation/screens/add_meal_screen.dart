import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/add_meal_cubit.dart';
import '../cubit/add_meal_state.dart';
import '../widgets/add_meal_header.dart';
import '../widgets/add_meal_summary_bar.dart';
import '../widgets/coach_suggestion_banner.dart';
import '../widgets/meal_search_field.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/suggested_food_card.dart';
import '../widgets/suggested_food_header.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => AddMealCubit(), child: const _AddMealView());
}

class _AddMealView extends StatelessWidget {
  const _AddMealView();

  @override
  Widget build(BuildContext context) => BlocBuilder<AddMealCubit, AddMealState>(
    builder: (context, state) {
      final cubit = context.read<AddMealCubit>();
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const AddMealHeader(),
                          const SizedBox(height: 20),
                          MealTypeSelector(
                            selected: state.mealType,
                            onSelected: cubit.selectMealType,
                          ),
                          const SizedBox(height: 16),
                          MealSearchField(onChanged: cubit.search),
                          const SizedBox(height: 12),
                          const CoachSuggestionBanner(),
                          const SizedBox(height: 18),
                          const SuggestedFoodHeader(),
                          const SizedBox(height: 10),
                          for (final food in state.visibleFoods) ...[
                            SuggestedFoodCard(
                              food: food,
                              grams: state.portions[food.name],
                              onToggle: () => cubit.toggleFood(food),
                              onPortionChanged: (grams) =>
                                  cubit.setPortion(food, grams),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (state.visibleFoods.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'No foods found. Try another search.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              AddMealSummaryBar(
                mealType: state.mealType,
                foodCount: state.selectedFoods.length,
                calories: state.calories,
                protein: state.protein,
                carbs: state.carbs,
                fat: state.fat,
              ),
            ],
          ),
        ),
      );
    },
  );
}
