import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/meal_photo_analyzer.dart';
import '../../data/services/meal_photo_picker.dart';
import '../cubit/add_meal_cubit.dart';
import '../cubit/add_meal_state.dart';
import '../widgets/add_meal_header.dart';
import '../widgets/add_meal_summary_bar.dart';
import '../widgets/coach_suggestion_banner.dart';
import '../widgets/custom_food_dialog.dart';
import '../widgets/meal_scan_card.dart';
import '../widgets/meal_search_field.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/suggested_food_card.dart';
import '../widgets/suggested_food_header.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({
    super.key,
    this.onSave,
    this.photoAnalyzer,
    this.photoPicker,
  });

  final MealSaver? onSave;

  /// AI analyzer for meal photos; defaults to the Gemini-backed service.
  final MealPhotoAnalyzerFn? photoAnalyzer;

  /// Camera/gallery picker; defaults to [MealPhotoPicker] (image_picker).
  final MealPhotoPickerFn? photoPicker;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AddMealCubit(
      onSave: onSave,
      photoAnalyzer: photoAnalyzer ?? MealPhotoAnalyzer().analyze,
    ),
    child: _AddMealView(photoPicker: photoPicker ?? const MealPhotoPicker().pick),
  );
}

class _AddMealView extends StatelessWidget {
  const _AddMealView({required this.photoPicker});

  final MealPhotoPickerFn photoPicker;

  /// Full scan flow: source sheet → capture/select → AI analysis. Errors are
  /// surfaced as snackbars; cancellation is silent.
  Future<void> _scanMeal(
    BuildContext context,
    AddMealCubit cubit,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    MealPhotoSource? source;
    try {
      source = await showMealPhotoSourceSheet(context);
    } catch (_) {
      return;
    }
    if (source == null || !context.mounted) return;
    try {
      final bytes = await photoPicker(source);
      if (bytes == null || !context.mounted) return;
      final error = await cubit.analyzePhoto(bytes);
      if (error != null && context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on MealPhotoPickerException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not open the photo picker. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
                          MealScanCard(
                            analyzing: state.analyzing,
                            analysis: state.analysis,
                            onTapScan: () => _scanMeal(context, cubit),
                            onClearScan: cubit.clearScan,
                          ),
                          const SizedBox(height: 16),
                          MealTypeSelector(
                            selected: state.mealType,
                            onSelected: cubit.selectMealType,
                          ),
                          const SizedBox(height: 16),
                          // Keyed on the scan result so a successful analysis
                          // resets any stale search text along with the query.
                          MealSearchField(
                            key: ValueKey(state.analysis),
                            onChanged: cubit.search,
                          ),
                          const SizedBox(height: 12),
                          const CoachSuggestionBanner(),
                          const SizedBox(height: 18),
                          SuggestedFoodHeader(
                            mealType: state.mealType,
                            filterByMealType: state.filterByMealType,
                            onToggleFilter: cubit.toggleFilterByMealType,
                            onAddCustom: () async {
                              final draft = await showCustomFoodDialog(
                                context,
                                mealType: state.mealType,
                              );
                              if (draft == null || !context.mounted) return;
                              cubit.addCustomFood(
                                name: draft.name,
                                servingGrams: draft.servingGrams,
                                calories: draft.calories,
                                proteinG: draft.proteinG,
                                carbsG: draft.carbsG,
                                fatG: draft.fatG,
                              );
                            },
                          ),
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
                saving: state.saving,
                onSubmit: () async {
                  final saved = await cubit.submit();
                  if (!context.mounted) return;
                  if (saved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to ${state.mealType} log.'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else if (cubit.state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(cubit.state.errorMessage!)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
