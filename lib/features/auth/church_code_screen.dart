import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHURCH CODE SCREEN
//
// § 6.4 — User enters a 6-digit code to join a specific church.
//
// Layout: illustration → title → body → 6-box code input → button → link.
// Auto-focus next box on digit entry. Validation + success animation.
// ──────────────────────────────────────────────────────────────────────────────

class ChurchCodeScreen extends ConsumerStatefulWidget {
  const ChurchCodeScreen({super.key});

  @override
  ConsumerState<ChurchCodeScreen> createState() => _ChurchCodeScreenState();
}

class _ChurchCodeScreenState extends ConsumerState<ChurchCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _submitCode() async {
    final code = _code;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success =
        await ref.read(authNotifierProvider.notifier).verifyChurchCode(code);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Brief success pause, then navigate to profile setup.
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go(AppRoutes.profileSetup);
    } else {
      final authState = ref.read(authNotifierProvider);
      setState(() {
        _isLoading = false;
        _errorMessage = authState.error ?? 'Invalid church code.';
      });
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all 6 digits entered.
    if (_code.length == 6) {
      _submitCode();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sp8),

                // ── Illustration ─────────────────────────────────────────
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.skyDark : AppColors.skyLight,
                    shape: BoxShape.circle,
                  ),
                  child: _isSuccess
                      ? const Icon(
                          Icons.check_circle,
                          size: 72,
                          color: AppColors.success,
                        )
                      : Icon(
                          Icons.church_outlined,
                          size: 72,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                ),
                const SizedBox(height: AppSpacing.sp6),

                // ── Title ────────────────────────────────────────────────
                Text(
                  _isSuccess ? 'Welcome!' : 'Join Your Church',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),

                // ── Body ─────────────────────────────────────────────────
                Text(
                  _isSuccess
                      ? "You're all set. Let's get started!"
                      : 'Enter the 6-digit code your church provided.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp8),

                // ── Error ────────────────────────────────────────────────
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                ],

                // ── 6-digit code boxes ───────────────────────────────────
                if (!_isSuccess)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 48,
                          height: 56,
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) => _onKeyEvent(i, event),
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: AppTextStyles.headingMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderRadiusSm,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.borderRadiusSm,
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onDigitChanged(i, v),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: AppSpacing.sp6),

                // ── Join button ──────────────────────────────────────────
                if (!_isSuccess)
                  AppPrimaryButton(
                    label: 'Join Church',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submitCode,
                  ),
                const SizedBox(height: AppSpacing.sp4),

                // ── Browse link ──────────────────────────────────────────
                if (!_isSuccess)
                  AppGhostButton(
                    label: "Don't have a code? Browse churches",
                    onPressed: () {
                      // TODO: Navigate to church browser.
                    },
                  ),
                const SizedBox(height: AppSpacing.sp8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
