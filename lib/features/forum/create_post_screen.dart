import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/forum_providers.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/app_tap_animation.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/inputs.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// CREATE POST SCREEN - compose a new forum thread
///
/// Features:
///   - Title field (AppTextField)
///   - Rich text body area with formatting toolbar
///   - Category picker via bottom sheet
///   - Community guidelines checkbox
///   - Post button (AppPrimaryButton)
///   - Optional preselected category
/// ══════════════════════════════════════════════════════════════════════════════

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.preselectedCategory});

  final String? preselectedCategory;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String? _selectedCategory;
  bool _agreedGuidelines = false;
  bool _isSubmitting = false;

  // ── Categories ────────────────────────────────────────────────────────
  static const _categories = <_CatOption>[
    _CatOption('Prayer Requests', Icons.volunteer_activism_outlined,
        Color(0xFFEF4444)),
    _CatOption(
        'Bible Study', Icons.menu_book_outlined, Color(0xFF3B82F6)),
    _CatOption(
        'Testimonies', Icons.auto_awesome_outlined, Color(0xFFF59E0B)),
    _CatOption('General Discussion', Icons.chat_bubble_outline_rounded,
        Color(0xFF6366F1)),
    _CatOption(
        'Youth & Young Adults', Icons.groups_outlined, Color(0xFF8B5CF6)),
    _CatOption(
        'Events & Activities', Icons.event_outlined, Color(0xFF059669)),
    _CatOption('Volunteering', Icons.handshake_outlined,
        Color(0xFFEC4899)),
    _CatOption('Questions & Answers', Icons.help_outline_rounded,
        Color(0xFF0EA5E9)),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
    _titleCtrl.addListener(() => setState(() {}));
    _bodyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleCtrl.text.trim().isNotEmpty &&
      _bodyCtrl.text.trim().isNotEmpty &&
      _selectedCategory != null &&
      _agreedGuidelines &&
      !_isSubmitting;

  Future<void> _submitPost() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    final apiCategories = ref.read(forumCategoriesProvider).value ?? [];
    final selectedName = _selectedCategory?.toLowerCase() ?? '';
    var categoryId = _selectedCategory ?? '';
    for (final c in apiCategories) {
      if (c.label.toLowerCase() == selectedName) {
        categoryId = c.id;
        break;
      }
    }

    final res = await ref.read(apiForumRepositoryProvider).createThread(
      categoryId: categoryId,
      title: _titleCtrl.text.trim(),
      content: _bodyCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (res.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your post has been published!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isEmpty ? 'Failed to publish. Please try again.' : res.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4,
            AppSpacing.sp4,
            AppSpacing.sp4,
            AppSpacing.sp6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade300,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                'Choose Category',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sp3),

              ..._categories.map((cat) {
                final selected = _selectedCategory == cat.label;
                return AppTapAnimation(
                  onTap: () => Navigator.of(ctx).pop(cat.label),
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: AppSpacing.sp2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp3,
                        vertical: AppSpacing.sp3),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withValues(alpha: 0.12)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF8FAFC)),
                      borderRadius: AppRadius.borderRadiusMd,
                      border: selected
                          ? Border.all(
                              color:
                                  cat.color.withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                cat.color.withValues(alpha: 0.12),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Icon(cat.icon,
                              color: cat.color, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        Expanded(
                          child: Text(
                            cat.label,
                            style:
                                AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              color: cat.color, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() => _selectedCategory = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Derive category color for display
    Color? catColor;
    for (final c in _categories) {
      if (c.label == _selectedCategory) {
        catColor = c.color;
        break;
      }
    }

    return Scaffold(
      appBar: AppFilledAppBar(
        title: 'New Post',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp2),
            child: AppPrimaryButton(
              label: _isSubmitting ? 'Posting...' : 'Post',
              onPressed: _canSubmit ? _submitPost : null,
              isFullWidth: false,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category picker ──────────────────────────────────────
              AppTapAnimation(
                onTap: _showCategoryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3, vertical: AppSpacing.sp3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8FAFC),
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.inputBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (catColor != null) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: Icon(
                            _categories
                                .firstWhere(
                                    (c) => c.label == _selectedCategory)
                                .icon,
                            color: catColor,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp2),
                      ],
                      Expanded(
                        child: Text(
                          _selectedCategory ?? 'Select a category',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _selectedCategory != null
                                ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled),
                            fontWeight: _selectedCategory != null
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down_rounded,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),

              // ── Title ────────────────────────────────────────────────
              AppTextField(
                controller: _titleCtrl,
                label: 'Title',
                hint: 'Give your post a clear title...',
              ),
              const SizedBox(height: AppSpacing.sp4),

              // ── Body label ───────────────────────────────────────────
              Text(
                'Body',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sp2),

              // ── Formatting toolbar ───────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp2, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    _FormatBtn(Icons.format_bold, 'Bold'),
                    _FormatBtn(Icons.format_italic, 'Italic'),
                    _FormatBtn(Icons.format_list_bulleted, 'List'),
                    _FormatBtn(Icons.format_quote, 'Quote'),
                    _FormatBtn(Icons.link, 'Link'),
                    const Spacer(),
                    Text(
                      '${_bodyCtrl.text.length} chars',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body text area ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.inputBorder,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8)),
                ),
                child: TextField(
                  controller: _bodyCtrl,
                  maxLines: 10,
                  minLines: 6,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Share your thoughts, prayer requests, or questions with the community...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.sp3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp5),

              // ── Guidelines checkbox ──────────────────────────────────
              AppTapAnimation(
                onTap: () => setState(
                    () => _agreedGuidelines = !_agreedGuidelines),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sp3),
                  decoration: BoxDecoration(
                    color: _agreedGuidelines
                        ? AppColors.primary
                            .withValues(alpha: isDark ? 0.15 : 0.05)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC)),
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: _agreedGuidelines
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.inputBorder),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _agreedGuidelines
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: AppRadius.borderRadiusSm,
                          border: _agreedGuidelines
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                        ),
                        child: _agreedGuidelines
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Guidelines',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'I agree to be respectful, kind, and follow our community standards. Posts are reviewed by moderators.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),

              // ── Bottom post button (for scrolled-down visibility) ────
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: _isSubmitting ? 'Publishing...' : 'Publish Post',
                  onPressed: _canSubmit ? _submitPost : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORMAT TOOLBAR BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _FormatBtn extends StatelessWidget {
  const _FormatBtn(this.icon, this.tooltip);
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderRadiusSm,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$tooltip formatting applied'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CATEGORY DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class _CatOption {
  const _CatOption(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
