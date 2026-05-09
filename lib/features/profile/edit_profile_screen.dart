import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/user_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN
//
// Full form: avatar with crop placeholder, display name, email, phone,
// department picker, bio textarea, save button.
// Now wired to userNotifierProvider.updateProfile().
// ──────────────────────────────────────────────────────────────────────────────

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;

  String _selectedDepartment = 'None';
  bool _saving = false;

  static const _departments = [
    'Media',
    'Worship',
    'Children',
    'Ushering',
    'Hospitality',
    'Outreach',
    'Prayer',
    'Administration',
    'Youth',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userNotifierProvider).profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _selectedDepartment = profile?.department ?? 'None';
    if (!_departments.contains(_selectedDepartment)) {
      _selectedDepartment = 'None';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success =
        await ref.read(userNotifierProvider.notifier).updateProfile(
              name: _nameCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              bio: _bioCtrl.text.trim(),
              department: _selectedDepartment,
            );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSm),
      ));
      Navigator.of(context).pop();
    } else {
      final err = ref.read(userNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Failed to update profile'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusSm),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'U';
    final profile = ref.watch(userNotifierProvider).profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Edit Profile', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sp6),

            // ── Avatar ─────────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: isDark
                          ? AppColors.primaryLight
                          : AppColors.skyLight,
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Text(
                              initial.toUpperCase(),
                              style: AppTextStyles.displayLarge.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showAvatarOptions(context, isDark),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  isDark ? AppColors.bgDark : AppColors.surface,
                              width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp2),
            Text('Tap to change photo',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled)),

            const SizedBox(height: AppSpacing.sp6),

            // ── Form fields ────────────────────────────────────────────
            AppTextField(
              controller: _nameCtrl,
              label: 'Display Name',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.sp4),

            AppTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.sp4),

            AppTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppSpacing.sp4),

            // ── Department picker ──────────────────────────────────────
            _DepartmentPicker(
              value: _selectedDepartment,
              departments: _departments,
              isDark: isDark,
              onChanged: (d) => setState(() => _selectedDepartment = d),
            ),

            const SizedBox(height: AppSpacing.sp4),

            AppTextField(
              controller: _bioCtrl,
              label: 'Bio',
              hint: 'Tell us a little about yourself...',
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: AppSpacing.sp8),

            AppPrimaryButton(
              label: 'Save Changes',
              isLoading: _saving,
              onPressed: _save,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.sp3),

            AppGhostButton(
              label: 'Cancel',
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              onPressed: () => Navigator.of(context).pop(),
            ),

            const SizedBox(height: AppSpacing.sp10),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.sp6,
            AppSpacing.sp3,
            AppSpacing.sp6,
            MediaQuery.of(context).padding.bottom + AppSpacing.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.inactive,
                  borderRadius: AppRadius.borderRadiusFull),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text('Change Photo',
                style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sp5),
            _AvatarOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
            const AppDivider(height: 1),
            _AvatarOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
            const AppDivider(height: 1),
            _AvatarOption(
              icon: Icons.delete_outline,
              label: 'Remove Photo',
              isDark: isDark,
              isDestructive: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Department Picker ────────────────────────────────────────────────────────

class _DepartmentPicker extends StatelessWidget {
  const _DepartmentPicker({
    required this.value,
    required this.departments,
    required this.isDark,
    required this.onChanged,
  });

  final String value;
  final List<String> departments;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Department',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sp1),
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.inputFill,
              borderRadius: AppRadius.borderRadiusSm,
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.inputBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.work_outline,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: Text(value,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                ),
                Icon(Icons.keyboard_arrow_down,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.sp6,
            AppSpacing.sp3,
            AppSpacing.sp6,
            MediaQuery.of(context).padding.bottom + AppSpacing.sp4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.inactive,
                  borderRadius: AppRadius.borderRadiusFull),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text('Select Department',
                style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sp4),
            ...departments.map((d) => ListTile(
                  title: Text(d,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: d == value
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary))),
                  trailing: d == value
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onChanged(d);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ── Avatar option tile ───────────────────────────────────────────────────────

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: AppTextStyles.bodyLarge.copyWith(color: color)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
