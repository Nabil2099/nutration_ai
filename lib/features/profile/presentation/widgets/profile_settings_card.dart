import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_state.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.units,
    required this.onEditProfile,
    required this.onUnitsChanged,
    required this.onLogOut,
  });

  final ProfileUnits units;
  final ValueChanged<ProfileUnits> onUnitsChanged;
  final VoidCallback onEditProfile;
  final VoidCallback onLogOut;

  Future<void> _chooseUnits(BuildContext context) async {
    final selected = await showModalBottomSheet<ProfileUnits>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Measurement units',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            for (final option in ProfileUnits.values)
              ListTile(
                title: Text(
                  option == ProfileUnits.metric ? 'Metric' : 'Imperial',
                ),
                trailing: option == units
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onUnitsChanged(selected);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      children: [
        _SettingsRow(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
          onTap: onEditProfile,
        ),
        const Divider(height: 1, indent: 28, color: AppColors.border),
        _SettingsRow(
          icon: Icons.straighten_rounded,
          label: 'Units',
          onTap: () => _chooseUnits(context),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                units == ProfileUnits.metric ? 'Metric' : 'Imperial',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 28, color: AppColors.border),
        _SettingsRow(
          icon: Icons.logout_rounded,
          label: 'Log Out',
          onTap: onLogOut,
        ),
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 52,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          ?trailing,
        ],
      ),
    ),
  );
}
