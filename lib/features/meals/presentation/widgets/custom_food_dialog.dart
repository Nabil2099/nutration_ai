import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CustomFoodDraft {
  const CustomFoodDraft({
    required this.name,
    required this.servingGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String name;
  final double servingGrams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

Future<CustomFoodDraft?> showCustomFoodDialog(
  BuildContext context, {
  required String mealType,
}) => showDialog<CustomFoodDraft>(
  context: context,
  builder: (_) => _CustomFoodDialog(mealType: mealType),
);

class _CustomFoodDialog extends StatefulWidget {
  const _CustomFoodDialog({required this.mealType});

  final String mealType;

  @override
  State<_CustomFoodDialog> createState() => _CustomFoodDialogState();
}

class _CustomFoodDialogState extends State<_CustomFoodDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _grams = TextEditingController(text: '100');
  final _calories = TextEditingController();
  final _protein = TextEditingController(text: '0');
  final _carbs = TextEditingController(text: '0');
  final _fat = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [_name, _grams, _calories, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _requiredNonNegative(String? v, {bool positive = false}) {
    final parsed = double.tryParse((v ?? '').trim());
    if (parsed == null) return 'Enter a number';
    if (positive && parsed <= 0) return 'Must be > 0';
    if (!positive && parsed < 0) return 'Must be >= 0';
    return null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      CustomFoodDraft(
        name: _name.text.trim(),
        servingGrams: double.parse(_grams.text.trim()),
        calories: double.parse(_calories.text.trim()),
        proteinG: double.parse(_protein.text.trim()),
        carbsG: double.parse(_carbs.text.trim()),
        fatG: double.parse(_fat.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Add Custom ${widget.mealType}'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Meal or food name',
                hintText: 'e.g. Homemade Shakshuka',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a meal name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _grams,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Serving (g)'),
                    validator: (v) => _requiredNonNegative(v, positive: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _calories,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                    ),
                    validator: _requiredNonNegative,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _protein,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                    validator: _requiredNonNegative,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _carbs,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    validator: _requiredNonNegative,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fat (g)'),
                    validator: _requiredNonNegative,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _save,
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
        child: const Text('Add Meal'),
      ),
    ],
  );
}

