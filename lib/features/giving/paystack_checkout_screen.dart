import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/repositories/giving_repository.dart';
import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PAYSTACK CHECKOUT SCREEN
//
// Paystack-branded card entry form. Receives amount + categoryId + categoryName
// + paymentMethod as route query params. Calls donate() on Pay, then navigates
// to /giving/success on confirmation.
// ──────────────────────────────────────────────────────────────────────────────

class PaystackCheckoutScreen extends ConsumerStatefulWidget {
  const PaystackCheckoutScreen({
    super.key,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.paymentMethod,
  });

  final int amount;
  final String categoryId;
  final String categoryName;
  final String paymentMethod;

  @override
  ConsumerState<PaystackCheckoutScreen> createState() =>
      _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState
    extends ConsumerState<PaystackCheckoutScreen> {
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isProcessing = false;
  String? _error;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    final card = _cardCtrl.text.replaceAll(' ', '');
    final expiry = _expiryCtrl.text;
    final cvv = _cvvCtrl.text;
    return card.length == 16 &&
        expiry.length == 5 &&
        (cvv.length == 3 || cvv.length == 4) &&
        _nameCtrl.text.trim().isNotEmpty;
  }

  Future<void> _pay() async {
    if (!_isValid || _isProcessing) return;
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final repo = GivingRepository();
      final res = await repo.donate(
        amount: widget.amount.toDouble(),
        categoryId: widget.categoryId,
        paymentMethod: widget.paymentMethod,
      );

      if (!mounted) return;

      if (res.success) {
        final reference =
            (res.data?['reference'] as String?) ?? res.data?['id'] as String? ?? '';
        context.pushReplacement(
          '/giving/success'
          '?amount=${widget.amount}'
          '&ref=${Uri.encodeComponent(reference)}'
          '&category=${Uri.encodeComponent(widget.categoryName)}',
        );
      } else {
        setState(() {
          _isProcessing = false;
          _error = res.message.isNotEmpty
              ? res.message
              : 'Payment failed. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = 'Network error. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C3F7), // Paystack teal
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Secure Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.lock_outline, size: 18, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Paystack header band ─────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF00C3F7),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  // Merchant info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.church, color: Color(0xFF00C3F7), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Grace Community Church',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.categoryName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Amount
                  Text(
                    _formatAmount(widget.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pay with card',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Card form ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Cardholder Name'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _nameCtrl,
                          hint: 'Full name on card',
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        _label('Card Number'),
                        const SizedBox(height: 8),
                        _field(
                          controller: _cardCtrl,
                          hint: '0000  0000  0000  0000',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _CardNumberFormatter(),
                          ],
                          maxLength: 19,
                          suffix: _cardBrandIcon(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Expiry Date'),
                                  const SizedBox(height: 8),
                                  _field(
                                    controller: _expiryCtrl,
                                    hint: 'MM/YY',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _ExpiryFormatter(),
                                    ],
                                    maxLength: 5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('CVV'),
                                  const SizedBox(height: 8),
                                  _field(
                                    controller: _cvvCtrl,
                                    hint: '•••',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    maxLength: 4,
                                    obscure: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Test card hint ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C3F7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00C3F7).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Color(0xFF00A3D7)),
                            SizedBox(width: 6),
                            Text(
                              'Test Mode — use test card',
                              style: TextStyle(
                                color: Color(0xFF00A3D7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _testRow('Card', '4084 0840 8408 4081'),
                        _testRow('Expiry', '01/25'),
                        _testRow('CVV', '408'),
                        _testRow('PIN', '0000'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Pay button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedBuilder(
                      animation: _cardCtrl,
                      builder: (_, _) => ElevatedButton(
                        onPressed: (_isValid && !_isProcessing) ? _pay : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C3F7),
                          disabledBackgroundColor:
                              const Color(0xFF00C3F7).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Pay ${_formatAmount(widget.amount)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Paystack branding ──────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Secured by ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          'Paystack',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    Widget? suffix,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00C3F7), width: 1.5),
        ),
      ),
    );
  }

  Widget? _cardBrandIcon() {
    final digits = _cardCtrl.text.replaceAll(' ', '');
    if (digits.isEmpty) return null;
    IconData icon = Icons.credit_card;
    Color color = Colors.grey.shade400;
    if (digits.startsWith('4')) {
      icon = Icons.credit_card;
      color = const Color(0xFF1A1F71);
    } else if (digits.startsWith('5') || digits.startsWith('2')) {
      icon = Icons.credit_card;
      color = const Color(0xFFEB001B);
    }
    return Icon(icon, color: color, size: 20);
  }

  Widget _testRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00A3D7),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    final buf = StringBuffer('₦');
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ── Card Number Formatter ────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write('  ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Expiry Formatter ─────────────────────────────────────────────────────────

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
