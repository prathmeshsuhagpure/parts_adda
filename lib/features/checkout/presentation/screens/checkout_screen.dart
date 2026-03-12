import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/cart/domain/models/cart_model.dart';
import '../../../../features/cart/presentation/providers/cart_provider.dart';
import '../../../../features/orders/presentation/providers/order_provider.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import 'address_screen.dart';

enum _PayMethod { razorpay, upi, cod }

extension _PayLabel on _PayMethod {
  String get label {
    switch (this) {
      case _PayMethod.razorpay:
        return 'Card / Net Banking';
      case _PayMethod.upi:
        return 'UPI';
      case _PayMethod.cod:
        return 'Cash on Delivery';
    }
  }

  String get subtitle {
    switch (this) {
      case _PayMethod.razorpay:
        return 'Visa, Mastercard, HDFC, ICICI…';
      case _PayMethod.upi:
        return 'GPay, PhonePe, Paytm, BHIM';
      case _PayMethod.cod:
        return 'Pay when your order arrives';
    }
  }

  IconData get icon {
    switch (this) {
      case _PayMethod.razorpay:
        return Icons.credit_card_outlined;
      case _PayMethod.upi:
        return Icons.account_balance_outlined;
      case _PayMethod.cod:
        return Icons.payments_outlined;
    }
  }

  String get apiKey => name;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PayMethod _payMethod = _PayMethod.razorpay;
  dynamic _selectedAddress; // AddressModel

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>();
      profile.loadAddresses();
      _selectedAddress = profile.defaultAddress;

      context.read<CartProvider>().loadCart(context);
    });
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Future<void> _selectAddress() async {
    final addr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen(selectMode: true)),
    );
    if (addr != null) setState(() => _selectedAddress = addr);
  }

  Future<void> _placeOrder() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_selectedAddress == null) {
      _toast('Please select a delivery address', isDarkMode);
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();

    final ok = await orderProvider.placeOrder(
      addressId: _selectedAddress!.id,
      paymentMethod: _payMethod.apiKey,
    );

    if (!mounted) return;

    if (ok) {
      await cartProvider.loadCart(context);
      final orderId = orderProvider.placedOrderId;
      context.go(AppRoutes.orderSuccess, extra: orderId);
    } else {
      _toast(
        orderProvider.error ?? 'Failed to place order. Try again.',
        isDarkMode,
      );
    }
  }

  void _toast(String msg, bool isDarkMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.bodyMd(isDarkMode)),
        backgroundColor: isDarkMode
            ? AppColorsDark.bgCard
            : AppColorsLight.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final isCartLoading = context.watch<CartProvider>().isLoading;
    final isPlacing = context.watch<OrderProvider>().isPlacingOrder;
    final profile = context.watch<ProfileProvider>();
    _selectedAddress ??= profile.defaultAddress;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isCartLoading || cart == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDarkMode
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        title: Text('Checkout', style: AppTextStyles.headingSm(isDarkMode)),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Step 1: Delivery Address ─────────────────────
          _StepHeader(number: '1', title: 'Delivery Address'),
          const SizedBox(height: 10),
          _selectedAddress == null
              ? _AddAddressCard(onTap: _selectAddress)
              : _SelectedAddressCard(
                  address: _selectedAddress!,
                  onChange: _selectAddress,
                ),
          const SizedBox(height: 20),

          // ── Step 2: Order Summary ────────────────────────
          _StepHeader(number: '2', title: 'Order Summary'),
          const SizedBox(height: 10),
          _OrderItemsList(items: cart.items, fmt: _fmt),
          const SizedBox(height: 20),

          // ── Step 3: Apply Coupon ─────────────────────────
          _StepHeader(number: '3', title: 'Coupon / Promo'),
          const SizedBox(height: 10),
          _CouponField(
            currentCode: cart.couponCode,
            onApply: (code) async {
              final ok = await context.read<CartProvider>().applyCoupon(code);
              if (!ok && mounted) {
                _toast('Invalid or expired coupon code', isDarkMode);
              }
            },
            onRemove: () => context.read<CartProvider>().removeCoupon(),
          ),
          const SizedBox(height: 20),

          // ── Step 4: Payment Method ───────────────────────
          _StepHeader(number: '4', title: 'Payment Method'),
          const SizedBox(height: 10),
          ..._PayMethod.values.map(
            (m) => _PayMethodTile(
              method: m,
              isSelected: _payMethod == m,
              onTap: () => setState(() => _payMethod = m),
            ),
          ),
          const SizedBox(height: 20),

          // ── Price Breakdown ──────────────────────────────
          _PriceBreakdown(cart: cart, fmt: _fmt),
        ],
      ),

      // ── Place Order bottom bar ─────────────────────────────
      bottomNavigationBar: _PlaceOrderBar(
        total: _fmt(cart.total),
        isLoading: isPlacing,
        canPlace: _selectedAddress != null && !isPlacing,
        onTap: _placeOrder,
      ),
    );
  }
}

// ─── Step Header ─────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String number, title;

  const _StepHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelMd(isDarkMode)),
      ],
    );
  }
}

// ─── Address cards ────────────────────────────────────────────

class _AddAddressCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_location_alt_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Add Delivery Address',
              style: AppTextStyles.labelMd(
                isDarkMode,
              ).copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAddressCard extends StatelessWidget {
  final dynamic address;
  final VoidCallback onChange;

  const _SelectedAddressCard({required this.address, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        address.label,
                        style: AppTextStyles.labelXs(
                          isDarkMode,
                        ).copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address.fullName,
                  style: AppTextStyles.labelMd(isDarkMode),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                        address.line1,
                        address.line2,
                        address.city,
                        address.state,
                        address.pincode,
                      ]
                      .where((s) => s != null && (s as String).isNotEmpty)
                      .join(', '),
                  style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                    color: isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(address.phone, style: AppTextStyles.bodySm(isDarkMode)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              'Change',
              style: AppTextStyles.bodySm(
                isDarkMode,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Items List ─────────────────────────────────────────

class _OrderItemsList extends StatelessWidget {
  final List<CartItemModel> items;
  final String Function(double) fmt;

  const _OrderItemsList({required this.items, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              if (i > 0)
                Divider(
                  height: 1,
                  color: isDarkMode
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: isDarkMode
                            ? AppColorsDark.bgInput
                            : AppColorsLight.bgInput,
                        child: item.partImage != null
                            ? Image.network(
                                item.partImage!,
                                fit: BoxFit.contain,
                              )
                            : Center(
                                child: Icon(
                                  Icons.settings_outlined,
                                  size: 24,
                                  color: isDarkMode
                                      ? AppColorsDark.textMuted
                                      : AppColorsLight.textMuted,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.partName,
                            style: AppTextStyles.labelMd(isDarkMode),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${item.partSku}',
                            style: AppTextStyles.mono(isDarkMode),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.sellerName ?? "",
                            style: AppTextStyles.bodySm(isDarkMode),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmt(item.price * item.quantity),
                          style: AppTextStyles.priceSm(),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Qty: ${item.quantity}',
                          style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                            color: isDarkMode
                                ? AppColorsDark.textMuted
                                : AppColorsLight.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Coupon Field ─────────────────────────────────────────────

class _CouponField extends StatefulWidget {
  final String? currentCode;
  final Future<void> Function(String) onApply;
  final VoidCallback onRemove;

  const _CouponField({
    this.currentCode,
    required this.onApply,
    required this.onRemove,
  });

  @override
  State<_CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<_CouponField> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (widget.currentCode != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColorsDark.success.withValues(alpha: 0.06)
              : AppColorsLight.success.withValues(alpha: 0.06),
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDarkMode
                ? AppColorsDark.success.withValues(alpha: 0.3)
                : AppColorsLight.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isDarkMode
                  ? AppColorsDark.success
                  : AppColorsLight.success,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupon applied!',
                    style: AppTextStyles.labelMd(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.success
                          : AppColorsLight.success,
                    ),
                  ),
                  Text(
                    widget.currentCode!.toUpperCase(),
                    style: AppTextStyles.mono(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.success
                          : AppColorsLight.success,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onRemove,
              child: Text(
                'Remove',
                style: AppTextStyles.bodySm(isDarkMode).copyWith(
                  color: isDarkMode
                      ? AppColorsDark.error
                      : AppColorsLight.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: AppTextStyles.bodyMd(isDarkMode),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter coupon code',
              hintStyle: AppTextStyles.bodyMd(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppColorsDark.bgInput
                  : AppColorsLight.bgInput,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_ctrl.text.trim().isEmpty) return;
                  setState(() => _loading = true);
                  await widget.onApply(_ctrl.text.trim());
                  if (mounted) setState(() => _loading = false);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Apply', style: AppTextStyles.buttonSm),
        ),
      ],
    );
  }
}

// ─── Payment Method Tile ──────────────────────────────────────

class _PayMethodTile extends StatelessWidget {
  final _PayMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : (isDarkMode ? AppColorsDark.border : AppColorsLight.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDarkMode
                            ? AppColorsDark.border
                            : AppColorsLight.border),
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDarkMode
                          ? AppColorsDark.bgInput
                          : AppColorsLight.bgInput),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                method.icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : (isDarkMode
                          ? AppColorsDark.textSecondary
                          : AppColorsLight.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: AppTextStyles.labelMd(isDarkMode)),
                  Text(
                    method.subtitle,
                    style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (method == _PayMethod.cod)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColorsDark.warning.withValues(alpha: 0.12)
                      : AppColorsLight.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '+₹40',
                  style: AppTextStyles.labelXs(isDarkMode).copyWith(
                    color: isDarkMode
                        ? AppColorsDark.warning
                        : AppColorsLight.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Price Breakdown ──────────────────────────────────────────

class _PriceBreakdown extends StatelessWidget {
  final CartModel cart;
  final String Function(double) fmt;

  const _PriceBreakdown({required this.cart, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: fmt(cart.subtotal)),
          if (cart.discount > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Discount',
              value: '-${fmt(cart.discount)}',
              valueColor: isDarkMode
                  ? AppColorsDark.success
                  : AppColorsLight.success,
            ),
          ],
          if (cart.couponDiscount != null && cart.couponDiscount! > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Coupon (${cart.couponCode?.toUpperCase() ?? ''})',
              value: '-${fmt(cart.couponDiscount!)}',
              valueColor: isDarkMode
                  ? AppColorsDark.success
                  : AppColorsLight.success,
            ),
          ],
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Delivery',
            value: cart.deliveryCharge == 0 ? 'FREE' : fmt(cart.deliveryCharge),
            valueColor: cart.deliveryCharge == 0
                ? (isDarkMode ? AppColorsDark.success : AppColorsLight.success)
                : null,
          ),
          const SizedBox(height: 10),
          _PriceRow(label: 'GST (18%)', value: fmt(cart.gst)),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Total', style: AppTextStyles.heading(isDarkMode)),
              ),
              Text(fmt(cart.total), style: AppTextStyles.priceLg()),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Inclusive of all taxes',
              style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMd(isDarkMode).copyWith(
            color:
                valueColor ??
                (isDarkMode
                    ? AppColorsDark.textPrimary
                    : AppColorsLight.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ─── Place Order Bottom Bar ───────────────────────────────────

class _PlaceOrderBar extends StatelessWidget {
  final String total;
  final bool isLoading, canPlace;
  final VoidCallback onTap;

  const _PlaceOrderBar({
    required this.total,
    required this.isLoading,
    required this.canPlace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total payable',
                      style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                        color: isDarkMode
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                    ),
                    Text(
                      total,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canPlace ? onTap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: isDarkMode
                          ? AppColorsDark.bgInput
                          : AppColorsLight.bgInput,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Place Order',
                                style: AppTextStyles.button,
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'By placing order you agree to our Terms & Conditions',
              style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
