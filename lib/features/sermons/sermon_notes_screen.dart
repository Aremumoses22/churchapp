import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON NOTES SCREEN
//
// Rich note-taking during a sermon, auto-tagged to the sermon being played,
// bullet/numbered list, save & export.
// ──────────────────────────────────────────────────────────────────────────────

class SermonNotesScreen extends StatefulWidget {
  const SermonNotesScreen({
    super.key,
    this.sermonId,
    this.sermonTitle,
    this.sermonSpeaker,
    this.sermonDate,
  });

  final String? sermonId;
  final String? sermonTitle;
  final String? sermonSpeaker;
  final String? sermonDate;

  @override
  State<SermonNotesScreen> createState() => _SermonNotesScreenState();
}

class _SermonNotesScreenState extends State<SermonNotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocus = FocusNode();
  bool _isSaved = false;
  _ListMode _listMode = _ListMode.none;
  int _bulletCount = 0;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.sermonTitle ?? 'Untitled Notes';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _saveNotes() {
    HapticFeedback.mediumImpact();
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notes saved'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSaved = false);
    });
  }

  void _insertBullet() {
    final text = _notesController.text;
    final selection = _notesController.selection;
    final cursorPos = selection.baseOffset;

    String prefix;
    if (_listMode == _ListMode.bullet) {
      prefix = '\n\u2022 ';
    } else if (_listMode == _ListMode.numbered) {
      _bulletCount++;
      prefix = '\n$_bulletCount. ';
    } else {
      return;
    }

    final newText =
        text.substring(0, cursorPos) + prefix + text.substring(cursorPos);
    _notesController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPos + prefix.length,
      ),
    );
  }

  void _toggleListMode(_ListMode mode) {
    setState(() {
      if (_listMode == mode) {
        _listMode = _ListMode.none;
        _bulletCount = 0;
      } else {
        _listMode = mode;
        _bulletCount = 0;
        if (mode == _ListMode.bullet) {
          _insertPrefix('\u2022 ');
        } else if (mode == _ListMode.numbered) {
          _bulletCount = 1;
          _insertPrefix('1. ');
        }
      }
    });
  }

  void _insertPrefix(String prefix) {
    final text = _notesController.text;
    final selection = _notesController.selection;
    final cursorPos = selection.baseOffset;

    // If cursor is at the start or after a newline, insert prefix
    if (cursorPos == 0 ||
        (cursorPos > 0 && text[cursorPos - 1] == '\n')) {
      final newText =
          text.substring(0, cursorPos) + prefix + text.substring(cursorPos);
      _notesController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: cursorPos + prefix.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sermon Notes',
          style: AppTextStyles.headingMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          // Export
          IconButton(
            icon: Icon(
              Icons.ios_share_outlined,
              size: 22,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            onPressed: () => _showExportOptions(),
            tooltip: 'Export',
          ),
          // Save
          AppTapAnimation(
            onTap: _saveNotes,
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.sp4),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp3,
                vertical: AppSpacing.sp1 + 2,
              ),
              decoration: BoxDecoration(
                color: _isSaved
                    ? AppColors.success
                    : (isDark ? AppColors.primaryLight : AppColors.primary),
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSaved ? Icons.check : Icons.save_outlined,
                    size: 16,
                    color: AppColors.textInverse,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSaved ? 'Saved' : 'Save',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.divider,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sp5),

                  // ── Sermon Tag ───────────────────────────────────────────
                  if (widget.sermonTitle != null) ...[
                    _SermonTag(
                      title: widget.sermonTitle!,
                      speaker: widget.sermonSpeaker,
                      date: widget.sermonDate,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sp5),
                  ],

                  // ── Title Field ──────────────────────────────────────────
                  TextField(
                    controller: _titleController,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note Title',
                      hintStyle: AppTextStyles.headingLarge.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp2),

                  // ── Divider ──────────────────────────────────────────────
                  Container(
                    height: 2,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp5),

                  // ── Notes Body ───────────────────────────────────────────
                  TextField(
                    controller: _notesController,
                    focusNode: _notesFocus,
                    maxLines: null,
                    minLines: 20,
                    textInputAction: TextInputAction.newline,
                    onChanged: (value) {
                      // Auto-insert bullets on newline
                      if (value.endsWith('\n') &&
                          _listMode != _ListMode.none) {
                        _insertBullet();
                      }
                    },
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.8,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Start taking notes...\n\nTap the formatting toolbar below to add bullet points or numbered lists.',
                      hintStyle: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 16,
                        height: 1.8,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp12),
                ],
              ),
            ),
          ),

          // ── Formatting Toolbar ───────────────────────────────────────────
          _FormattingToolbar(
            listMode: _listMode,
            isDark: isDark,
            onBulletTap: () => _toggleListMode(_ListMode.bullet),
            onNumberedTap: () => _toggleListMode(_ListMode.numbered),
            onTimestamp: () {
              final time = TimeOfDay.now().format(context);
              final text = _notesController.text;
              final pos = _notesController.selection.baseOffset;
              final stamp = '[$time] ';
              _notesController.value = TextEditingValue(
                text: text.substring(0, pos) + stamp + text.substring(pos),
                selection: TextSelection.collapsed(
                  offset: pos + stamp.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.sp6,
          right: AppSpacing.sp6,
          top: AppSpacing.sp6,
          bottom: AppSpacing.sp6 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.inactive,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text(
              'Export Notes',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            _ExportOption(
              icon: Icons.copy_outlined,
              label: 'Copy to Clipboard',
              isDark: isDark,
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text:
                      '${_titleController.text}\n\n${_notesController.text}',
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            _ExportOption(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Export as PDF',
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: export as PDF
              },
            ),
            _ExportOption(
              icon: Icons.text_snippet_outlined,
              label: 'Export as Text',
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: export as text
              },
            ),
            _ExportOption(
              icon: Icons.share_outlined,
              label: 'Share',
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: share notes
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Enums ────────────────────────────────────────────────────────────────────

enum _ListMode { none, bullet, numbered }

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _SermonTag extends StatelessWidget {
  const _SermonTag({
    required this.title,
    required this.isDark,
    this.speaker,
    this.date,
  });

  final String title;
  final String? speaker;
  final String? date;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.skyLight,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            size: 16,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sp2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linked to: $title',
                  style: AppTextStyles.labelSmall.copyWith(
                    color:
                        isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                if (speaker != null || date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [if (speaker != null) speaker, if (date != null) date]
                        .join(' \u00B7 '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  const _FormattingToolbar({
    required this.listMode,
    required this.isDark,
    required this.onBulletTap,
    required this.onNumberedTap,
    required this.onTimestamp,
  });

  final _ListMode listMode;
  final bool isDark;
  final VoidCallback onBulletTap;
  final VoidCallback onNumberedTap;
  final VoidCallback onTimestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sp4,
        right: AppSpacing.sp4,
        top: AppSpacing.sp3,
        bottom: AppSpacing.sp3 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          _ToolButton(
            icon: Icons.format_list_bulleted,
            isActive: listMode == _ListMode.bullet,
            isDark: isDark,
            onTap: onBulletTap,
            tooltip: 'Bullet list',
          ),
          const SizedBox(width: AppSpacing.sp3),
          _ToolButton(
            icon: Icons.format_list_numbered,
            isActive: listMode == _ListMode.numbered,
            isDark: isDark,
            onTap: onNumberedTap,
            tooltip: 'Numbered list',
          ),
          const SizedBox(width: AppSpacing.sp3),
          _ToolButton(
            icon: Icons.schedule,
            isActive: false,
            isDark: isDark,
            onTap: onTimestamp,
            tooltip: 'Insert timestamp',
          ),
          const Spacer(),
          // Word count
          Text(
            'Notes',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AppTapAnimation(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sp4),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
