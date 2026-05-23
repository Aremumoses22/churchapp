import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/kids.dart';
import '../../core/providers/kids_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// KIDS CHECK-IN SCREEN
//
// Parent flow: select child → assign classroom → generate QR code,
// pickup verification badge.
// ──────────────────────────────────────────────────────────────────────────────

class KidsCheckinScreen extends ConsumerStatefulWidget {
  const KidsCheckinScreen({super.key});

  @override
  ConsumerState<KidsCheckinScreen> createState() => _KidsCheckinScreenState();
}

class _KidsCheckinScreenState extends ConsumerState<KidsCheckinScreen> {
  int _step = 0; // 0 = select children, 1 = assign rooms, 2 = QR result

  // Child IDs that are selected
  final Set<String> _childSelected = {};

  // childId → roomId
  final Map<String, String> _roomAssignments = {};

  // Check-in results from the API
  List<KidsCheckInResult> _checkInResults = [];
  bool _isCheckingIn = false;

  List<KidsChild> get _selectedChildren {
    final kidsState = ref.read(kidsNotifierProvider);
    return kidsState.children
        .where((c) => _childSelected.contains(c.id))
        .toList();
  }

  String _ageGroup(int age) {
    if (age <= 2) return '0-2';
    if (age <= 5) return '3-5';
    if (age <= 8) return '6-8';
    return '9-12';
  }

  List<KidsRoom> _roomsForChild(KidsChild child, List<KidsRoom> allRooms) {
    final group = _ageGroup(child.age);
    return allRooms.where((r) => r.ageGroup == group).toList();
  }

  Future<void> _doCheckIn() async {
    setState(() => _isCheckingIn = true);
    final repo = ref.read(kidsRepositoryProvider);
    final results = <KidsCheckInResult>[];
    try {
      for (final child in _selectedChildren) {
        final roomId = _roomAssignments[child.id];
        if (roomId == null) continue;
        final result = await repo.checkIn(childId: child.id, roomId: roomId);
        results.add(result);
      }
      setState(() {
        _checkInResults = results;
        _isCheckingIn = false;
        _step = 2;
      });
    } catch (e) {
      setState(() => _isCheckingIn = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Check-in failed: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
      }
    }
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
    final kidsState = ref.watch(kidsNotifierProvider);

    if (kidsState.isLoading) {
      return const Center(key: ValueKey(0), child: CircularProgressIndicator());
    }

    if (kidsState.error != null) {
      return Center(
        key: const ValueKey(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load children',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sp3),
            AppGhostButton(
              label: 'Retry',
              onPressed: () =>
                  ref.read(kidsNotifierProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    final children = kidsState.children;

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
            itemCount: children.length + 1, // +1 for add child
            itemBuilder: (context, i) {
              if (i == children.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sp2),
                  child: AppGhostButton(
                    label: 'Add a Child',
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => _showAddChildDialog(isDark),
                  ),
                );
              }
              final child = children[i];
              final isSelected = _childSelected.contains(child.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                child: _ChildSelectCard(
                  child: child,
                  isDark: isDark,
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    if (isSelected) {
                      _childSelected.remove(child.id);
                    } else {
                      _childSelected.add(child.id);
                    }
                  }),
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
            onPressed: _childSelected.isEmpty
                ? null
                : () => setState(() => _step = 1),
          ),
        ),
      ],
    );
  }

  void _showAddChildDialog(bool isDark) {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final allergyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Child'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastCtrl,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dobCtrl,
                decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: allergyCtrl,
                decoration:
                    const InputDecoration(labelText: 'Allergies (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (firstCtrl.text.isEmpty ||
                  lastCtrl.text.isEmpty ||
                  dobCtrl.text.isEmpty) {
                return;
              }
              try {
                await ref.read(kidsNotifierProvider.notifier).addChild(
                      firstCtrl.text.trim(),
                      lastCtrl.text.trim(),
                      dobCtrl.text.trim(),
                      allergyCtrl.text.trim().isEmpty
                          ? null
                          : allergyCtrl.text.trim(),
                    );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to add child: $e'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Assign rooms ────────────────────────────────────────────────

  Widget _buildRoomStep(bool isDark) {
    final allRooms = ref.watch(kidsNotifierProvider).rooms;
    final selected = _selectedChildren;

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
            itemCount: selected.length,
            itemBuilder: (context, i) {
              final child = selected[i];
              final rooms = _roomsForChild(child, allRooms);
              final assignedRoomId = _roomAssignments[child.id];

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
                            child: Text(child.initials,
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: AppColors.primary)),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.fullName,
                                  style:
                                      AppTextStyles.bodyLargeSemiBold.copyWith(
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary)),
                              Text(
                                  'Age ${child.age} • ${_ageGroup(child.age)} group',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                          if (child.hasAllergies) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: AppRadius.borderRadiusFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      size: 12, color: AppColors.warning),
                                  const SizedBox(width: 3),
                                  Text(child.allergies ?? '',
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
                      if (rooms.isEmpty)
                        Text(
                          'No rooms available for age group ${_ageGroup(child.age)}',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        )
                      else
                        ...rooms.map((room) {
                          final isSel = assignedRoomId == room.id;
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sp2),
                            child: GestureDetector(
                              onTap: room.isFull
                                  ? null
                                  : () => setState(
                                      () => _roomAssignments[child.id] = room.id),
                              child: Opacity(
                                opacity: room.isFull ? 0.5 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sp3,
                                      vertical: AppSpacing.sp2 + 2),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppColors.primary
                                            .withValues(alpha: 0.08)
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
                                      Expanded(
                                        child: Text(
                                            room.isFull
                                                ? '${room.name} (Full)'
                                                : room.name,
                                            style:
                                                AppTextStyles.bodyMedium.copyWith(
                                                    color: isSel
                                                        ? AppColors.primary
                                                        : (isDark
                                                            ? AppColors
                                                                .textPrimaryDark
                                                            : AppColors
                                                                .textPrimary))),
                                      ),
                                    ],
                                  ),
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
                  label: _isCheckingIn ? 'Checking In…' : 'Check In',
                  isFullWidth: true,
                  onPressed: (_roomAssignments.length < selected.length ||
                          _isCheckingIn)
                      ? null
                      : _doCheckIn,
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
    final selected = _selectedChildren;
    final firstResult =
        _checkInResults.isNotEmpty ? _checkInResults.first : null;

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
              '${selected.length} ${selected.length == 1 ? 'child' : 'children'} checked in',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)),

          const SizedBox(height: AppSpacing.sp6),

          // QR Code
          if (firstResult != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.inputBorder),
              ),
              child: firstResult.qrCode.isNotEmpty &&
                      firstResult.qrCode.contains(',')
                  ? ClipRRect(
                      borderRadius: AppRadius.borderRadiusLg,
                      child: Image.memory(
                        base64Decode(firstResult.qrCode.split(',').last),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Column(
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
                        Text(firstResult.securityCode,
                            style: AppTextStyles.headingSmall.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.primary,
                                letterSpacing: 2)),
                      ],
                    ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.inputBorder),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),

          if (firstResult != null) ...[
            const SizedBox(height: AppSpacing.sp3),
            Text('Security Code',
                style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              firstResult.securityCode,
              style: AppTextStyles.headingMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  letterSpacing: 3),
            ),
          ],

          const SizedBox(height: AppSpacing.sp5),

          // Child summary cards
          ..._checkInResults.map((result) {
            final childName = result.child?.fullName ?? '';
            final initials = result.child?.initials ?? '?';
            final roomName = result.room.name;
            return Padding(
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
                      child: Text(initials,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(childName,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                          Text(roomName,
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
            );
          }),

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

// ── Child selection card ─────────────────────────────────────────────────────

class _ChildSelectCard extends StatelessWidget {
  const _ChildSelectCard({
    required this.child,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  final KidsChild child;
  final bool isDark;
  final bool isSelected;
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
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark ? AppColors.skyDark : AppColors.inputFill),
              child: Text(child.initials,
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isSelected
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
                  Text(child.fullName,
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
            if (child.hasAllergies)
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
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.inputBorder,
                        width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
