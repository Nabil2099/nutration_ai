import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../theme/app_colors.dart';
import 'main_destination.dart';

class TeamScreens {
  const TeamScreens({this.analytics, this.coach, this.profile, this.addMeal});
  final WidgetBuilder? analytics, coach, profile, addMeal;
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
      builder:
          widget.screens.addMeal ??
          (_) =>
              const IntegrationPlaceholder(name: 'Add Meal', standalone: true),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(switch (_selected) {
        MainDestination.home => 'Home Dashboard',
        MainDestination.analytics => 'Analytics',
        MainDestination.coach => 'AI Coach',
        MainDestination.profile => 'Profile',
      }),
      actions: [
        IconButton(
          onPressed: () => context.read<AppCubit>().signOut(),
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
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
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _destination(MainDestination.home, Icons.home_outlined, 'Home'),
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
                    icon: const Icon(Icons.add, size: 30),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
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
    ),
  );
  Widget _destination(
    MainDestination destination,
    IconData icon,
    String label,
  ) => Expanded(
    child: Semantics(
      selected: _selected == destination,
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _select(destination),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: _selected == destination
                ? AppColors.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
