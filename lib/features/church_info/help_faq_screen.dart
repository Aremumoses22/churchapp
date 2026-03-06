import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HELP & FAQ SCREEN
//
// Expandable accordion FAQ items, search bar, "Still need help?"
// contact button at bottom.
// ──────────────────────────────────────────────────────────────────────────────

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategory = 0;

  static const _categories = [
    'All',
    'Getting Started',
    'Account',
    'Giving',
    'Groups',
    'Events',
    'Technical',
  ];

  static const _faqs = [
    _FaqData(
      question: 'How do I create an account?',
      answer:
          'Tap "Get Started" on the welcome screen, then choose to sign up with your email or phone number. You will need to enter your church code to connect with your local church.',
      category: 'Getting Started',
    ),
    _FaqData(
      question: 'What is a church code?',
      answer:
          'A church code is a unique identifier for your church. Ask your pastor or church administrator for the code, or look for it on your church website or bulletin.',
      category: 'Getting Started',
    ),
    _FaqData(
      question: 'How do I reset my password?',
      answer:
          'On the login screen, tap "Forgot Password?" and enter your email address. We will send you a reset link that you can use to create a new password.',
      category: 'Account',
    ),
    _FaqData(
      question: 'How do I update my profile?',
      answer:
          'Go to your Profile tab, then tap "Edit Profile." You can update your name, photo, bio, and notification preferences from there.',
      category: 'Account',
    ),
    _FaqData(
      question: 'Is online giving secure?',
      answer:
          'Yes! We use industry-standard encryption and partner with trusted payment processors to ensure your financial information is fully protected.',
      category: 'Giving',
    ),
    _FaqData(
      question: 'How do I set up recurring giving?',
      answer:
          'On the Giving screen, select your amount and choose "Make Recurring." You can set weekly, bi-weekly, or monthly schedules. You can modify or cancel recurring gifts anytime.',
      category: 'Giving',
    ),
    _FaqData(
      question: 'How do I join a connect group?',
      answer:
          'Navigate to Connect Groups from the Community section. Browse available groups by category and tap "Join Group" on any open group. The group leader will be notified.',
      category: 'Groups',
    ),
    _FaqData(
      question: 'How do I register for an event?',
      answer:
          'Go to the Events tab, find the event you are interested in, and tap "Register." Some events may require additional information or have limited capacity.',
      category: 'Events',
    ),
    _FaqData(
      question: 'Can I watch services on my TV?',
      answer:
          'Yes! You can cast our live services to your TV using AirPlay or Chromecast. Open the live service and tap the cast icon in the player.',
      category: 'Technical',
    ),
    _FaqData(
      question: 'How do I enable notifications?',
      answer:
          'Go to Profile > Settings > Notifications. You can customize which notifications you receive, including prayer requests, events, sermons, and announcements.',
      category: 'Technical',
    ),
    _FaqData(
      question: 'The app is running slowly. What should I do?',
      answer:
          'Try closing and reopening the app. Make sure you are on the latest version. If issues persist, clear the app cache in your phone settings or reinstall the app.',
      category: 'Technical',
    ),
  ];

  List<_FaqData> get _filteredFaqs {
    var result = _faqs.toList();
    if (_selectedCategory > 0) {
      final cat = _categories[_selectedCategory];
      result = result.where((f) => f.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (f) =>
                f.question.toLowerCase().contains(q) ||
                f.answer.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Help & FAQ',
        showBack: true,
      ),
      body: Column(
        children: [
          // ── Search ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(
              AppSpacing.screenHorizontalPadding,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search for help...',
              onChanged: (val) => setState(() => _searchQuery = val),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // ── Category chips ─────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              itemCount: _categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.inputFill),
                      borderRadius: AppRadius.borderRadiusFull,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputBorder,
                              width: 1,
                            ),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.textInverse
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // ── FAQ list ───────────────────────────────────────────────
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.help_outline,
                      title: 'No Results',
                      subtitle:
                          'Try different search terms or category',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontalPadding,
                    ),
                    children: [
                      ..._filteredFaqs.map(
                        (faq) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sp3,
                          ),
                          child: _FaqAccordion(
                            faq: faq,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sp6),

                      // ── Still need help? ────────────────────────────
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppSpacing.sp6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.surface,
                          borderRadius: AppRadius.borderRadiusLg,
                          boxShadow: isDark
                              ? AppShadows.smDark
                              : AppShadows.sm,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.skyDark
                                    : AppColors.skyLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.headset_mic_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp3),
                            Text(
                              'Still Need Help?',
                              style: AppTextStyles.headingSmall
                                  .copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              'Our team is here to help you with any questions.',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sp4),
                            Row(
                              children: [
                                Expanded(
                                  child: AppPrimaryButton(
                                    label: 'Contact Us',
                                    onPressed: () {},
                                    icon: const Icon(Icons.mail_outlined, color: Colors.white, size: 18),
                                  ),
                                ),
                                const SizedBox(
                                    width: AppSpacing.sp3),
                                Expanded(
                                  child: AppSecondaryButton(
                                    label: 'Call Us',
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sp12),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _FaqData {
  const _FaqData({
    required this.question,
    required this.answer,
    required this.category,
  });

  final String question;
  final String answer;
  final String category;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion({
    required this.faq,
    required this.isDark,
  });

  final _FaqData faq;
  final bool isDark;

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: _toggle,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow:
              widget.isDark ? AppShadows.xsDark : AppShadows.xs,
          border: _isExpanded
              ? Border.all(
                  color: widget.isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          children: [
            // Question row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.skyDark
                          : AppColors.skyLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 22,
                      color: widget.isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),

            // Answer (expandable)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp4 + 28 + AppSpacing.sp3,
                  0,
                  AppSpacing.sp4,
                  AppSpacing.sp4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(
                        bottom: AppSpacing.sp3,
                      ),
                      color: widget.isDark
                          ? AppColors.borderDark
                          : AppColors.divider,
                    ),
                    Text(
                      widget.faq.answer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Row(
                      children: [
                        Text(
                          'Was this helpful?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.thumb_down_outlined,
                            size: 16,
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
