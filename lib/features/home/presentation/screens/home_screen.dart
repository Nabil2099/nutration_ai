import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/greeting_header.dart';
import '../widgets/calorie_budget_card.dart';
import '../widgets/daily_calories_chart.dart';
import '../widgets/macro_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onLog,
    required this.onProfile,
    required this.onCoach,
  });
  final VoidCallback onLog, onProfile, onCoach;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) {
      if (state.status == HomeStatus.loading ||
          state.status == HomeStatus.initial) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.status == HomeStatus.error) {
        return AppErrorView(
          message: state.message!,
          onRetry: () => context.read<HomeCubit>().refresh(),
        );
      }
      final summary = state.summary;
      final header = GreetingHeader(
        name: state.profile!.name,
        date: DateTime.now(),
        onProfile: widget.onProfile,
      );
      return RefreshIndicator(
        onRefresh: context.read<HomeCubit>().refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 24),
                    if (summary == null)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.link_off_outlined, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'No meal data connected',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'The Meals service has not been integrated yet. Your saved goals are available; calorie and macro totals will appear once the team connects meal data.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Daily calorie goal: ${state.profile!.dailyGoals.calories.round()} kcal',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: widget.onLog,
                                icon: const Icon(Icons.add),
                                label: const Text('Quick Log Meal'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (constraints.maxWidth >= 720)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CalorieBudgetCard(
                              summary: summary,
                              onLog: widget.onLog,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                DailyCaloriesChart(
                                  days: summary.sevenDayTotals,
                                  goal: summary.goalCalories,
                                ),
                                const SizedBox(height: 20),
                                MacroProgressCard(summary: summary),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      CalorieBudgetCard(summary: summary, onLog: widget.onLog),
                      const SizedBox(height: 20),
                      DailyCaloriesChart(
                        days: summary.sevenDayTotals,
                        goal: summary.goalCalories,
                      ),
                      const SizedBox(height: 20),
                      MacroProgressCard(summary: summary),
                    ],
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.auto_awesome_outlined),
                        title: const Text('AI Nutrition Coach'),
                        subtitle: const Text('Open your nutrition coach'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: widget.onCoach,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
