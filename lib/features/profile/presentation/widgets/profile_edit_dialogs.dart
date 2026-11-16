import 'package:flutter/material.dart';

import '../../../../core/data/models/nutrition_goals.dart';

Future<String?> showProfileNameDialog(
  BuildContext context, {
  required String initialName,
}) => showDialog<String>(
  context: context,
  builder: (_) => _ProfileNameDialog(initialName: initialName),
);

Future<NutritionGoals?> showNutritionGoalsDialog(
  BuildContext context, {
  required NutritionGoals initialGoals,
}) => showDialog<NutritionGoals>(
  context: context,
  builder: (_) => _NutritionGoalsDialog(initialGoals: initialGoals),
);

class _ProfileNameDialog extends StatefulWidget {
  const _ProfileNameDialog({required this.initialName});
  final String initialName;

  @override
  State<_ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<_ProfileNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit profile'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Name'),
        validator: (value) {
          final length = value?.trim().length ?? 0;
          return length < 2 ? 'Enter at least 2 characters.' : null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, _controller.text.trim());
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class _NutritionGoalsDialog extends StatefulWidget {
  const _NutritionGoalsDialog({required this.initialGoals});
  final NutritionGoals initialGoals;

  @override
  State<_NutritionGoalsDialog> createState() => _NutritionGoalsDialogState();
}

class _NutritionGoalsDialogState extends State<_NutritionGoalsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final goals = widget.initialGoals;
    _controllers = [
      TextEditingController(text: goals.calories.round().toString()),
      TextEditingController(text: goals.proteinG.round().toString()),
      TextEditingController(text: goals.carbsG.round().toString()),
      TextEditingController(text: goals.fatG.round().toString()),
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit daily goals'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _goalField(_controllers[0], 'Calories (kcal)', max: 10000, min: 1),
            _goalField(_controllers[1], 'Protein (g)', max: 1000),
            _goalField(_controllers[2], 'Carbs (g)', max: 1000),
            _goalField(_controllers[3], 'Fats (g)', max: 1000),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            NutritionGoals(
              calories: double.parse(_controllers[0].text),
              proteinG: double.parse(_controllers[1].text),
              carbsG: double.parse(_controllers[2].text),
              fatG: double.parse(_controllers[3].text),
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}

Widget _goalField(
  TextEditingController controller,
  String label, {
  required double max,
  double min = 0,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      final number = double.tryParse(value ?? '');
      if (number == null || !number.isFinite || number < min || number > max) {
        return 'Enter a value from $min to $max.';
      }
      return null;
    },
  ),
);
