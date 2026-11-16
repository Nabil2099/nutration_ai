import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/meals/presentation/screens/add_meal_screen.dart';
import '../theme/app_colors.dart';
import 'main_destination.dart';

class TeamScreens {
  const TeamScreens({this.analytics, this.coach, this.profile, this.addMeal});

  final WidgetBuilder? analytics;
  final WidgetBuilder? coach;
  final WidgetBuilder? profile;
  final WidgetBuilder? addMeal;

  TeamScreens withProfileFallback(WidgetBuilder fallback) => TeamScreens(
    analytics: analytics,
    coach: coach,
    profile: profile ?? fallback,
    addMeal: addMeal,
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.screens = const TeamScreens()});

  final TeamScreens screens;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  MainDestination _selected = MainDestination.home;

  void _select(MainDestination destination) =>
      setState(() => _selected = destination);

  void _log() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: widget.screens.addMeal ?? (_) => const AddMealScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.mintBadge,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_outlined,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              switch (_selected) {
                MainDestination.home => 'Home Dashboard',
                MainDestination.analytics => 'Analytics',
                MainDestination.coach => 'AI Coach',
                MainDestination.profile => 'Profile',
              },
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => context.read<AppCubit>().signOut(),
            tooltip: 'Sign out',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(36, 36),
            ),
            icon: const Icon(Icons.person_outline, size: 18),
          ),
        ),
      ],
    ),
    body: IndexedStack(
      index: _selected.index,
      children: [
        HomeScreen(
          onLog: _log,
          onProfile: () => _select(MainDestination.profile),
          onCoach: () => _select(MainDestination.coach),
        ),
        widget.screens.analytics?.call(context) ??
            const IntegrationPlaceholder(name: 'Analytics'),
        widget.screens.coach?.call(context) ??
            const IntegrationPlaceholder(name: 'AI Coach'),
        widget.screens.profile?.call(context) ??
            const IntegrationPlaceholder(name: 'Profile'),
      ],
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140A5438),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              _destination(MainDestination.home, Icons.home_rounded, 'Home'),
              _destination(
                MainDestination.analytics,
                Icons.bar_chart_rounded,
                'Analytics',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: IconButton.filled(
                  onPressed: _log,
                  tooltip: 'Add Meal',
                  icon: const Icon(Icons.add, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(50, 50),
                  ),
                ),
              ),
              _destination(
                MainDestination.coach,
                Icons.auto_awesome_outlined,
                'AI Coach',
              ),
              _destination(
                MainDestination.profile,
                Icons.person_outline,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _destination(
    MainDestination destination,
    IconData icon,
    String label,
  ) {
    final selected = _selected == destination;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _select(destination),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IntegrationPlaceholder extends StatelessWidget {
  const IntegrationPlaceholder({
    super.key,
    required this.name,
    this.standalone = false,
  });

  final String name;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$name integration pending. This screen is owned by another team member.',
          textAlign: TextAlign.center,
        ),
      ),
    );
    return standalone
        ? Scaffold(
            appBar: AppBar(title: Text(name)),
            body: body,
          )
        : body;
  }
}
