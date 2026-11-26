import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/meals/data/models/meal_analysis.dart';
import 'package:nutration_ai/features/meals/data/services/meal_photo_analyzer.dart';
import 'package:nutration_ai/features/meals/data/services/meal_photo_picker.dart';
import 'package:nutration_ai/features/meals/presentation/screens/add_meal_screen.dart';
import 'package:nutration_ai/features/meals/presentation/widgets/suggested_food_card.dart';

void main() {
  const analysis = MealAnalysis(
    title: 'Salmon rice bowl',
    items: [
      AnalyzedMealItem(
        name: 'Salmon Fillet',
        grams: 150,
        caloriesKcal: 316,
        proteinG: 30,
        carbsG: 0,
        fatG: 20,
        emoji: '🍣',
      ),
      AnalyzedMealItem(
        name: 'Steamed Rice',
        grams: 180,
        caloriesKcal: 234,
        proteinG: 4,
        carbsG: 52,
        fatG: 1,
        emoji: '🍚',
      ),
    ],
  );

  Future<void> pumpScreen(WidgetTester tester, {required AddMealScreen screen}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: screen),
    );
    await tester.pump();
  }

  testWidgets('scan flow: sheet → analyzing → results pre-selected → clear', (
    tester,
  ) async {
    final gate = Completer<MealAnalysis>();
    var pickerCalls = 0;
    MealPhotoSource? pickedSource;

    await pumpScreen(
      tester,
      screen: AddMealScreen(
        photoAnalyzer: (bytes, {mealTypeHint}) => gate.future,
        photoPicker: (source) async {
          pickerCalls++;
          pickedSource = source;
          return Uint8List.fromList([1, 2, 3]);
        },
      ),
    );

    expect(find.text('Scan your meal'), findsOneWidget);

    await tester.tap(find.text('Scan your meal'));
    await tester.pumpAndSettle();
    expect(find.text('Add a meal photo'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);

    await tester.tap(find.text('Take photo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(pickerCalls, 1);
    expect(pickedSource, MealPhotoSource.camera);
    expect(find.text('Analyzing your meal…'), findsOneWidget);

    gate.complete(analysis);
    await tester.pumpAndSettle();

    // Success summary on the scan card.
    expect(find.text('Salmon rice bowl'), findsOneWidget);
    expect(find.byTooltip('Clear scan results'), findsOneWidget);

    // Both detected foods are pre-selected at their estimated portions.
    expect(find.text('Salmon Fillet'), findsOneWidget);
    expect(find.text('AI scan · ~150 g'), findsOneWidget);
    expect(find.byTooltip('Remove Salmon Fillet'), findsOneWidget);
    expect(find.byTooltip('Remove Steamed Rice'), findsOneWidget);
    expect(find.text('316 kcal'), findsOneWidget);

    // Scanned foods are sorted above the built-in suggestions.
    final firstCard = tester.widget<SuggestedFoodCard>(
      find.byType(SuggestedFoodCard).first,
    );
    expect(firstCard.food.name, 'Salmon Fillet');

    // Summary includes the pre-selected grilled chicken (220) + 316 + 234.
    expect(find.text('770 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear scan results'));
    await tester.pumpAndSettle();

    expect(find.text('Salmon rice bowl'), findsNothing);
    expect(find.text('Salmon Fillet'), findsNothing);
    expect(find.text('Scan your meal'), findsOneWidget);
    // Baseline selection only: Grilled Chicken Breast at 100 g.
    expect(find.text('220 kcal'), findsNWidgets(2));
  });

  testWidgets('gallery source and analyzer errors surface as a snackbar', (
    tester,
  ) async {
    MealPhotoSource? pickedSource;

    await pumpScreen(
      tester,
      screen: AddMealScreen(
        photoAnalyzer: (bytes, {mealTypeHint}) async {
          throw const MealPhotoAnalyzerException(
            'No food was detected in that photo. Try a clearer shot of the meal.',
          );
        },
        photoPicker: (source) async {
          pickedSource = source;
          return Uint8List.fromList([9, 9, 9]);
        },
      ),
    );

    await tester.tap(find.text('Scan your meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(pickedSource, MealPhotoSource.gallery);
    expect(
      find.text(
        'No food was detected in that photo. Try a clearer shot of the meal.',
      ),
      findsOneWidget,
    );
    // The card returns to its resting CTA instead of sticking on "analyzing".
    expect(find.text('Scan your meal'), findsOneWidget);
  });

  testWidgets('cancelling the source sheet leaves everything untouched', (
    tester,
  ) async {
    var pickerCalls = 0;

    await pumpScreen(
      tester,
      screen: AddMealScreen(
        photoAnalyzer: (bytes, {mealTypeHint}) async => analysis,
        photoPicker: (source) async {
          pickerCalls++;
          return Uint8List.fromList([1]);
        },
      ),
    );

    await tester.tap(find.text('Scan your meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(pickerCalls, 0);
    expect(find.text('Scan your meal'), findsOneWidget);
    expect(find.text('Salmon Fillet'), findsNothing);
  });
}
