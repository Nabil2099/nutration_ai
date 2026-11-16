import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/services/user_profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/daily_goals_card.dart';
import '../widgets/profile_edit_dialogs.dart';
import '../widgets/profile_heading.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/profile_settings_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.profiles,
    required this.onLogOut,
  });

  final UserProfile profile;
  final UserProfileService profiles;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProfileCubit(profile: profile, profiles: profiles),
    child: _ProfileView(onLogOut: onLogOut),
  );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.onLogOut});

  final VoidCallback onLogOut;

  Future<void> _editName(BuildContext context, ProfileState state) async {
    final name = await showProfileNameDialog(
      context,
      initialName: state.profile.name,
    );
    if (name == null || !context.mounted) return;
    final cubit = context.read<ProfileCubit>();
    await cubit.updateName(name);
    if (!context.mounted) return;
    _showResult(context, cubit.state.errorMessage);
  }

  Future<void> _editGoals(BuildContext context, ProfileState state) async {
    final goals = await showNutritionGoalsDialog(
      context,
      initialGoals: state.profile.dailyGoals,
    );
    if (goals == null || !context.mounted) return;
    final cubit = context.read<ProfileCubit>();
    await cubit.updateGoals(goals);
    if (!context.mounted) return;
    _showResult(context, cubit.state.errorMessage);
  }

  void _showResult(BuildContext context, String? error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error ?? 'Profile updated.')));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileHeading(),
          const SizedBox(height: 24),
          ProfileIdentityCard(
            profile: state.profile,
            onEdit: () => _editName(context, state),
          ),
          const SizedBox(height: 26),
          DailyGoalsCard(
            goals: state.profile.dailyGoals,
            onEdit: () => _editGoals(context, state),
          ),
          const SizedBox(height: 22),
          ProfileSettingsCard(
            units: state.units,
            onEditProfile: () => _editName(context, state),
            onUnitsChanged: context.read<ProfileCubit>().selectUnits,
            onLogOut: onLogOut,
          ),
          if (state.saving) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primaryBright,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ],
        ],
      ),
    ),
  );
}
