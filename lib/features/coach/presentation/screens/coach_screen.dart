import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/services/meal_reader.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/ai_coach_service.dart';
import '../cubit/coach_cubit.dart';
import '../cubit/coach_state.dart';
import '../widgets/coach_composer.dart';
import '../widgets/coach_message_bubble.dart';
import '../widgets/sage_status_card.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key, this.profile, this.mealReader, this.service});

  final UserProfile? profile;
  final MealPeriodReader? mealReader;
  final AiCoachService? service;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = CoachCubit(
        service: service ?? AiCoachService(),
        profile: profile,
        mealReader: mealReader,
      );
      final uid = profile?.uid;
      if (uid != null && uid.isNotEmpty) {
        cubit.start(uid);
      }
      return cubit;
    },
    child: const _CoachView(),
  );
}

class _CoachView extends StatefulWidget {
  const _CoachView();

  @override
  State<_CoachView> createState() => _CoachViewState();
}

class _CoachViewState extends State<_CoachView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? overrideText]) async {
    final text = overrideText ?? _controller.text;
    if (text.trim().isEmpty) return;
    if (overrideText == null) _controller.clear();
    await context.read<CoachCubit>().ask(text);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CoachCubit, CoachState>(
    listenWhen: (prev, curr) =>
        curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
    listener: (context, state) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      context.read<CoachCubit>().clearError();
    },
    builder: (context, state) {
      final todayLabel =
          'Today • ${DateFormat('h:mm a').format(DateTime.now())}';
      final carbsGoal = state.profile?.dailyGoals.carbsG ?? 220;

      return Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                const SageStatusCard(),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      todayLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < state.messages.length; i++)
                  CoachMessageBubble(
                    message: state.messages[i],
                    meals: state.meals,
                    carbsGoalG: carbsGoal,
                    onQuickPrompt: i == state.messages.length - 1
                        ? (prompt) => _send(prompt)
                        : null,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: CoachComposer(
              controller: _controller,
              sending: state.sending,
              onSend: _send,
            ),
          ),
        ],
      );
    },
  );
}
