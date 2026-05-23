import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHURCH DIRECTORY SCREEN
//
// Searchable member list from backend API, alphabetical index,
// avatar + name + department, tap to view profile card (bottom sheet).
// ──────────────────────────────────────────────────────────────────────────────

class ChurchDirectoryScreen extends ConsumerStatefulWidget {
  const ChurchDirectoryScreen({super.key});

  @override
  ConsumerState<ChurchDirectoryScreen> createState() =>
      _ChurchDirectoryScreenState();
}

class _ChurchDirectoryScreenState
    extends ConsumerState<ChurchDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MemberData> _filter(List<_MemberData> src) {
    if (_searchQuery.isEmpty) return src;
    final q = _searchQuery.toLowerCase();
    return src
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.department.toLowerCase().contains(q) ||
              m.role.toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String, List<_MemberData>> _group(List<_MemberData> members) {
    final map = <String, List<_MemberData>>{};
    for (final m in members) {
      final letter =
          m.name.trim().isNotEmpty ? m.name.trim()[0].toUpperCase() : '#';
      map.putIfAbsent(letter, () => []).add(m);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncDir = ref.watch(directoryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Church Directory',
        showBack: true,
      ),
      body: asyncDir.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load directory',
            subtitle: 'Pull down to retry',
          ),
        ),
        data: (apiMembers) {
          final members = apiMembers
              .map(
                (m) => _MemberData(
                  id: m.id,
                  name: m.name,
                  department: m.department ?? '',
                  role: '',
                  joinedYear: m.joinedDate ?? '',
                ),
              )
              .toList();
          final filtered = _filter(members);
          final grouped = _group(filtered);

          return Column(
            children: [
              // ── Search bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(
                  AppSpacing.screenHorizontalPadding,
                ),
                child: AppSearchBar(
                  controller: _searchController,
                  hint: 'Search members...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),

              // ── Member count ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} members',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sp2),

              // ── List ──────────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: AppEmptyState(
                          icon: _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.people_outline,
                          title: _searchQuery.isNotEmpty
                              ? 'No Members Found'
                              : 'Directory is Empty',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'No members have opted in yet',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontalPadding,
                        ),
                        itemCount: grouped.length,
                        itemBuilder: (context, sectionIndex) {
                          final entry =
                              grouped.entries.elementAt(sectionIndex);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sp3,
                                  bottom: AppSpacing.sp2,
                                ),
                                child: Text(
                                  entry.key,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              ...entry.value.map((m) => _MemberTile(
                                    member: m,
                                    isDark: isDark,
                                    onTap: () => _showMemberProfile(
                                        context, m, isDark),
                                  )),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMemberProfile(
    BuildContext context,
    _MemberData member,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MemberProfileCard(
        id: member.id,
        name: member.name,
        department: member.department,
        role: member.role,
        joinedYear: member.joinedYear,
        isDark: isDark,
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _MemberData {
  const _MemberData({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.joinedYear,
  });

  final String id;
  final String name;
  final String department;
  final String role;
  final String joinedYear;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isDark,
    required this.onTap,
  });

  final _MemberData member;
  final bool isDark;
  final VoidCallback onTap;

  Color get _departmentColor {
    switch (member.department) {
      case 'Music Ministry':
        return const Color(0xFF7C3AED);
      case 'Children Ministry':
        return const Color(0xFFEC4899);
      case 'Youth Ministry':
        return const Color(0xFFEA580C);
      case 'Prayer Team':
        return const Color(0xFF0891B2);
      case 'Outreach':
        return const Color(0xFF059669);
      case 'Media':
        return const Color(0xFF2563EB);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = member.name
        .trim()
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join();

    return AppTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _departmentColor.withValues(alpha: 0.12),
                child: Text(
                  initials.isNotEmpty ? initials : '?',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _departmentColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.role.isNotEmpty
                          ? '${member.department}  •  ${member.role}'
                          : member.department,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.inactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// MEMBER PROFILE CARD (Bottom Sheet)
// ──────────────────────────────────────────────────────────────────────────────

class MemberProfileCard extends ConsumerStatefulWidget {
  const MemberProfileCard({
    super.key,
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.joinedYear,
    required this.isDark,
  });

  final String id;
  final String name;
  final String department;
  final String role;
  final String joinedYear;
  final bool isDark;

  @override
  ConsumerState<MemberProfileCard> createState() => _MemberProfileCardState();
}

class _MemberProfileCardState extends ConsumerState<MemberProfileCard> {
  bool _isCreatingChat = false;

  Future<void> _sendMessage() async {
    if (_isCreatingChat || widget.id.isEmpty) return;
    setState(() => _isCreatingChat = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final convoId = await repo.createConversation(
        type: 'DIRECT',
        memberIds: [widget.id],
      );
      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push(
        '${AppRoutes.chatConversation.replaceAll(':id', convoId)}'
        '?name=${Uri.encodeComponent(widget.name)}',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCreatingChat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start conversation. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _prayForThem() async {
    final contentCtrl = TextEditingController();
    bool isSubmitting = false;
    String? errorText;

    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Pray for ${widget.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a prayer for ${widget.name} and it will be sent.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                autofocus: true,
                onChanged: (_) {
                  if (errorText != null) {
                    setDialogState(() => errorText = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Lord, I pray for...',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final content = contentCtrl.text.trim();
                      if (content.length < 10) {
                        setDialogState(
                          () => errorText = 'Please write at least 10 characters',
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final repo = ref.read(prayerRepositoryProvider);
                      final res = await repo.submitRequest(
                        title: 'Prayer for ${widget.name}',
                        content: content,
                        isAnonymous: false,
                        isUrgent: false,
                      );
                      if (ctx.mounted) Navigator.pop(ctx, res.success);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Prayer'),
            ),
          ],
        ),
      ),
    );

    contentCtrl.dispose();

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prayer sent for ${widget.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.name
        .trim()
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join();

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusXlTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sp3),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.borderDark : AppColors.inactive,
              borderRadius: AppRadius.borderRadiusFull,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp6),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: widget.isDark
                      ? AppColors.primaryLight
                      : AppColors.skyLight,
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  widget.name,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: widget.isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp1),
                Text(
                  widget.role.isNotEmpty
                      ? '${widget.role}  •  ${widget.department}'
                      : widget.department,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                if (widget.joinedYear.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3,
                      vertical: AppSpacing.sp1,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.skyDark
                          : AppColors.skyLight,
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Text(
                      'Member since ${widget.joinedYear}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sp6),
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Pray for Them',
                        onPressed: _prayForThem,
                        icon: const Icon(
                          Icons.volunteer_activism_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: _isCreatingChat
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : AppSecondaryButton(
                              label: 'Send Message',
                              onPressed: _sendMessage,
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      AppSpacing.sp4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

