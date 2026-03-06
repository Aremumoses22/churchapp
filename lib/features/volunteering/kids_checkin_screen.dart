import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// KIDS CHECK-IN SCREEN
//
// Parent flow: select child → assign classroom → generate QR code,
// pickup verification badge.
// ──────────────────────────────────────────────────────────────────────────────

class KidsCheckinScreen extends StatefulWidget {
  const KidsCheckinScreen({super.key});

  @override
  State<KidsCheckinScreen> createState() => _KidsCheckinScreenState();
}

class _KidsCheckinScreenState extends State<KidsCheckinScreen> {
  int _step = 0; // 0 = select children, 1 = assign rooms, 2 = QR result

  final List<_ChildData> _children = [
    _ChildData(
        name: 'Ethan', age: 7, allergies: 'None', photo: 'E', selected: false),
    _ChildData(
        name: 'Olivia',
        age: 4,
        allergies: 'Peanuts',
        photo: 'O',
        selected: false),
    _ChildData(
        name: 'Noah', age: 2, allergies: 'None', photo: 'N', selected: false),
  ];

  final Map<String, String> _roomAssignments = {};

  List<_ChildData> get _selectedChildren =>
      _children.where((c) => c.selected).toList();

  static const _rooms = {
    '0-2': ['Nursery A — Room 101', 'Nursery B — Room 102'],
    '3-5': [
      'Little Lambs — Room 201',
      'Tiny Treasures — Room 202',
    ],
    '6-8': [
      'Mighty Warriors — Room 301',
      'Faith Explorers — Room 302',
    ],
    '9-12': ['Trailblazers — Room 401', 'Young Disciples — Room 402'],
  };

  String _ageGroup(int age) {
    if (age <= 2) return '0-2';
    if (age <= 5) return '3-5';
    if (age <= 8) return '6-8';
    return '9-12';
  }

  List<String> _roomsForChild(_ChildData child) {
    return _rooms[_ageGroup(child.age)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Kids Check-In', showBack: true),
      body: Column(
        children: [
          // ── Step indicator ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalPadding,
                AppSpacing.sp4,
                AppSpacing.screenHorizontalPadding,
                0),
            child: Row(
              children: List.generate(3, (i) {
                final labels = ['Select', 'Room', 'Done'];
                final active = i <= _step;
                return Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (i > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: i <= _step
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.inputBorder),
                              ),
                            ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.cardDark
                                      : AppColors.inputFill),
                              border: active
                                  ? null
                                  : Border.all(
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.inputBorder),
                            ),
                            child: Center(
                              child: i < _step
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : Text('${i + 1}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: active
                                              ? Colors.white
                                              : (isDark
                                                  ? AppColors.textSecondaryDark
                                                  : AppColors.textDisabled),
                                          fontSize: 11)),
                            ),
                          ),
                          if (i < 2)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: i < _step
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.inputBorder),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i],
                          style: AppTextStyles.bodySmall.copyWith(
                              color: active
                                  ? (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textDisabled),
                              fontSize: 10)),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: AppSpacing.sp5),

          // ── Step content ──────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _step == 0
                  ? _buildSelectStep(isDark)
                  : _step == 1
                      ? _buildRoomStep(isDark)
                      : _buildQrStep(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 0: Select children ─────────────────────────────────────────────

  Widget _buildSelectStep(bool isDark) {
    return Column(
      key: const ValueKey(0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Who's checking in today?",
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Select one or more children',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            itemCount: _children.length + 1, // +1 for add child
            itemBuilder: (context, i) {
              if (i == _children.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sp2),
                  child: AppGhostButton(
                    label: 'Add a Child',
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Child registration would open here.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSm),
                      ));
                    },
                  ),
                );
              }
              final child = _children[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                child: _ChildSelectCard(
                  child: child,
                  isDark: isDark,
                  onTap: () => setState(() => child.selected = !child.selected),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.sp4,
              AppSpacing.sp2,
              AppSpacing.sp4,
              MediaQuery.of(context).padding.bottom + AppSpacing.sp4),
          child: AppPrimaryButton(
            label: 'Next — Assign Rooms',
            isFullWidth: true,
            onPressed: _selectedChildren.isEmpty
                ? null
                : () => setState(() => _step = 1),
          ),
        ),
      ],
    );
  }

  // ── Step 1: Assign rooms ────────────────────────────────────────────────

  Widget _buildRoomStep(bool isDark) {
    return Column(
      key: const ValueKey(1),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assign Classrooms',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Choose a room for each child',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            itemCount: _selectedChildren.length,
            itemBuilder: (context, i) {
              final child = _selectedChildren[i];
              final rooms = _roomsForChild(child);
              final assigned = _roomAssignments[child.name];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sp4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.surface,
                    borderRadius: AppRadius.borderRadiusLg,
                    boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(child.photo,
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: AppColors.primary)),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.name,
                                  style:
                                      AppTextStyles.bodyLargeSemiBold.copyWith(
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary)),
                              Text('Age ${child.age} • ${_ageGroup(child.age)} group',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                          if (child.allergies != 'None') ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: AppRadius.borderRadiusFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      size: 12, color: AppColors.warning),
                                  const SizedBox(width: 3),
                                  Text(child.allergies,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.warning,
                                          fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      ...rooms.map((room) {
                        final isSel = assigned == room;
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sp2),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _roomAssignments[child.name] = room),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sp3,
                                  vertical: AppSpacing.sp2 + 2),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : (isDark
                                        ? AppColors.bgDark
                                        : AppColors.warmWhite),
                                borderRadius: AppRadius.borderRadiusMd,
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.inputBorder),
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSel
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: isSel
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textDisabled),
                                  ),
                                  const SizedBox(width: AppSpacing.sp2),
                                  Text(room,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: isSel
                                              ? AppColors.primary
                                              : (isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary))),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.sp4,
              AppSpacing.sp2,
              AppSpacing.sp4,
              MediaQuery.of(context).padding.bottom + AppSpacing.sp4),
          child: Row(
            children: [
              Expanded(
                child: AppGhostButton(
                  label: 'Back',
                  onPressed: () => setState(() => _step = 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  label: 'Check In',
                  isFullWidth: true,
                  onPressed:
                      _roomAssignments.length < _selectedChildren.length
                          ? null
                          : () => setState(() => _step = 2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: QR Code result ──────────────────────────────────────────────

  Widget _buildQrStep(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sp4),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 36, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text('Check-In Complete!',
              style: AppTextStyles.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sp2),
          Text(
              '${_selectedChildren.length} ${_selectedChildren.length == 1 ? 'child' : 'children'} checked in',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)),

          const SizedBox(height: AppSpacing.sp6),

          // QR Code placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.inputBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2,
                    size: 100,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
                const SizedBox(height: AppSpacing.sp2),
                Text('Pickup Code',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
                Text('PKU-4821',
                    style: AppTextStyles.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.primary,
                        letterSpacing: 2)),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp5),

          // Child summary cards
          ..._selectedChildren.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sp3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.surface,
                    borderRadius: AppRadius.borderRadiusMd,
                    boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(child.photo,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(child.name,
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary)),
                            Text(
                                _roomAssignments[child.name] ?? 'Unassigned',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          size: 20, color: AppColors.success),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: AppSpacing.sp5),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                const SizedBox(width: AppSpacing.sp2),
                Expanded(
                  child: Text(
                    'Show this QR code at pickup. Only authorized guardians can pick up children.',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info, height: 1.4, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp5),
          AppPrimaryButton(
            label: 'Done',
            isFullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpacing.sp8),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _ChildData {
  _ChildData({
    required this.name,
    required this.age,
    required this.allergies,
    required this.photo,
    required this.selected,
  });

  final String name;
  final int age;
  final String allergies;
  final String photo;
  bool selected;
}

// ── Child selection card ─────────────────────────────────────────────────────

class _ChildSelectCard extends StatelessWidget {
  const _ChildSelectCard({
    required this.child,
    required this.isDark,
    required this.onTap,
  });

  final _ChildData child;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
          border: child.selected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: child.selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark ? AppColors.skyDark : AppColors.inputFill),
              child: Text(child.photo,
                  style: AppTextStyles.headingSmall.copyWith(
                      color: child.selected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary))),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name,
                      style: AppTextStyles.bodyLargeSemiBold.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Age ${child.age}',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary)),
                ],
              ),
            ),
            if (child.allergies != 'None')
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sp2),
                child: Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppColors.warning),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: child.selected
                    ? AppColors.primary
                    : Colors.transparent,
                border: child.selected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.inputBorder,
                        width: 2),
              ),
              child: child.selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
