/*
import 'package:flutter/material.dart';
import 'package:parts_adda/features/profile/domain/models/address_model.dart';
import 'package:parts_adda/shared/widgets/app_button.dart';
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

  String get apiKey {
    switch (this) {
      case _PayMethod.razorpay:
        return "online";
      case _PayMethod.upi:
        return "online";
      case _PayMethod.cod:
        return "cod";
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PayMethod _payMethod = _PayMethod.razorpay;
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = context.read<ProfileProvider>();
      final cartProvider = context.read<CartProvider>();

      await Future.wait([
        profileProvider.loadAddresses(),
        cartProvider.loadCart(context),
      ]);

      if (!mounted) return;

      setState(() {
        _selectedAddress = profileProvider.defaultAddress;
      });
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
    final cart = cartProvider.cart;

    if (cart == null || cart.items.isEmpty) {
      _toast("Your cart is empty", isDarkMode);
      return;
    }

    final cartItems = cart.items;
    final items = cartItems
        .map(
          (e) => {
            "partId": e.partId,
            "partName": e.partName,
            "price": e.price,
            "quantity": e.quantity,
            "image": e.partImage,
            "partSku": e.partSku,
            "sellerName": e.sellerName,
            "sellerId": e.sellerId,
          },
        )
        .toList();

    String paymentMethod;

    switch (_payMethod) {
      case _PayMethod.cod:
        paymentMethod = "cod";
        break;
      case _PayMethod.upi:
        paymentMethod = "upi";
        break;
      default:
        paymentMethod = "online";
    }

    final ok = await orderProvider.placeOrder(
      paymentMethod: paymentMethod,
      items: items,
      shippingAddress: _selectedAddress!.toJson(),
      subtotal: cartProvider.cart?.subtotal ?? 0,
      discount: cartProvider.cart?.discount ?? 0,
      deliveryCharge: cartProvider.cart?.deliveryCharge ?? 99,
      gst: cartProvider.cart?.gst ?? 18,
      total: cartProvider.cart?.total ?? 0,
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
          _TitleHeader(title: 'Delivery Address'),
          const SizedBox(height: 10),
          _selectedAddress == null
              ? _AddAddressCard(onTap: _selectAddress)
              : _SelectedAddressCard(
                  address: _selectedAddress!,
                  onChange: _selectAddress,
                ),
          const SizedBox(height: 20),

          // ── Step 2: Order Summary ────────────────────────
          _TitleHeader(title: 'Order Summary'),
          const SizedBox(height: 10),
          _OrderItemsList(items: cart.items, fmt: _fmt),
          const SizedBox(height: 20),

          // ── Step 3: Apply Coupon ─────────────────────────
          _TitleHeader(title: 'Coupon / Promo'),
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
          _TitleHeader(title: 'Payment Method'),
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

class _TitleHeader extends StatelessWidget {
  final String title;

  const _TitleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [Text(title, style: AppTextStyles.labelMd(isDarkMode))],
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
                  child: AppButton(
                    label: 'Place Order',
                    isLoading: isLoading,
                    trailingIcon: Icons.arrow_forward,
                    onTap: canPlace ? onTap : null
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
*/
import 'package:flutter/material.dart';
import 'package:parts_adda/features/profile/domain/models/address_model.dart';
import 'package:parts_adda/shared/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PayMethod _payMethod = _PayMethod.razorpay;
  AddressModel? _selectedAddress;

  // ── Razorpay instance ─────────────────────────────────────
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    // Razorpay setup
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = context.read<ProfileProvider>();
      final cartProvider = context.read<CartProvider>();

      await Future.wait([
        profileProvider.loadAddresses(),
        cartProvider.loadCart(context),
      ]);

      if (!mounted) return;

      setState(() {
        _selectedAddress = profileProvider.defaultAddress;
      });
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // Razorpay callbacks
  // ─────────────────────────────────────────────────────────

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    // Payment verified on device → now submit order to backend
    _submitOrder(
      paymentMethod: 'online',
      razorpayPaymentId: response.paymentId,
    );
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    _toast('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _toast('Wallet selected: ${response.walletName}');
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Future<void> _selectAddress() async {
    final addr = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen(selectMode: true)),
    );
    if (addr != null) setState(() => _selectedAddress = addr);
  }

  void _toast(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.bodyMd(isDark)),
        backgroundColor: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Place Order — entry point (routes by payment method)
  // ─────────────────────────────────────────────────────────

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      _toast('Please select a delivery address');
      return;
    }

    final cart = context.read<CartProvider>().cart;
    if (cart == null || cart.items.isEmpty) {
      _toast('Your cart is empty');
      return;
    }

    switch (_payMethod) {
      // ── UPI: not live yet ────────────────────────────────
      case _PayMethod.upi:
        _toast('UPI payments coming soon! Please use another method.');
        return;

      // ── COD: place order directly ────────────────────────
      case _PayMethod.cod:
        await _submitOrder(paymentMethod: 'cod');
        return;

      // ── Razorpay: open payment gateway first ─────────────
      case _PayMethod.razorpay:
        _openRazorpay(cart);
        return;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Open Razorpay checkout sheet
  // ─────────────────────────────────────────────────────────

  void _openRazorpay(CartModel cart) {
    // Razorpay requires amount in paise (₹ × 100)
    final amountInPaise = (cart.total * 100).toInt();

    final address = _selectedAddress;
    final profile = context.read<ProfileProvider>();

    final options = <String, dynamic>{
      'key': 'rzp_test_XXXXXXXXXXXXXXXX', // 🔑 Replace with your Razorpay key
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'Parts Adda',
      'description': 'Auto Parts Order',
      'prefill': {
        'name': address?.fullName ?? '',
        'contact': address?.phone ?? '',
        'email': profile.user?.email ?? '',
      },
      'theme': {
        'color': '#FF6B35', // AppColors.primary hex — update if different
      },
      'retry': {'enabled': true, 'max_count': 2},
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _toast('Unable to open payment gateway. Try again.');
    }
  }

  // ─────────────────────────────────────────────────────────
  // Submit order to backend
  //   Called directly for COD
  //   Called from _onRazorpaySuccess for online payments
  // ─────────────────────────────────────────────────────────

  Future<void> _submitOrder({
    required String paymentMethod,
    String?
    razorpayPaymentId, // pass to backend if you do server-side verification
  }) async {
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    final cart = cartProvider.cart;

    if (cart == null || _selectedAddress == null) return;

    final items = cart.items
        .map(
          (e) => {
            'partId': e.partId,
            'partName': e.partName,
            'price': e.price,
            'quantity': e.quantity,
            'image': e.partImage,
            'partSku': e.partSku,
            'sellerName': e.sellerName,
            'sellerId': e.sellerId,
          },
        )
        .toList();

    final ok = await orderProvider.placeOrder(
      paymentMethod: paymentMethod,
      items: items,
      shippingAddress: _selectedAddress!.toJson(),
      subtotal: cart.subtotal,
      discount: cart.discount,
      deliveryCharge: cart.deliveryCharge,
      gst: cart.gst,
      total: cart.total,
      // Uncomment if your backend needs Razorpay payment ID for verification:
      // razorpayPaymentId: razorpayPaymentId,
    );

    if (!mounted) return;

    if (ok) {
      await cartProvider.loadCart(context);
      final orderId = orderProvider.placedOrderId;
      context.go(AppRoutes.orderSuccess, extra: orderId);
    } else {
      _toast(orderProvider.error ?? 'Failed to place order. Try again.');
    }
  }

  // ─────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final isCartLoading = context.watch<CartProvider>().isLoading;
    final isPlacing = context.watch<OrderProvider>().isPlacingOrder;
    final profile = context.watch<ProfileProvider>();
    _selectedAddress ??= profile.defaultAddress;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCartLoading || cart == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColorsDark.bg : AppColorsLight.bg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColorsDark.bg : AppColorsLight.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        title: Text('Checkout', style: AppTextStyles.headingSm(isDark)),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _TitleHeader(title: 'Delivery Address'),
          const SizedBox(height: 10),
          _selectedAddress == null
              ? _AddAddressCard(onTap: _selectAddress)
              : _SelectedAddressCard(
                  address: _selectedAddress!,
                  onChange: _selectAddress,
                ),
          const SizedBox(height: 20),

          _TitleHeader(title: 'Order Summary'),
          const SizedBox(height: 10),
          _OrderItemsList(items: cart.items, fmt: _fmt),
          const SizedBox(height: 20),

          _TitleHeader(title: 'Coupon / Promo'),
          const SizedBox(height: 10),
          _CouponField(
            currentCode: cart.couponCode,
            onApply: (code) async {
              final ok = await context.read<CartProvider>().applyCoupon(code);
              if (!ok && mounted) _toast('Invalid or expired coupon code');
            },
            onRemove: () => context.read<CartProvider>().removeCoupon(),
          ),
          const SizedBox(height: 20),

          _TitleHeader(title: 'Payment Method'),
          const SizedBox(height: 10),
          ..._PayMethod.values.map(
            (m) => _PayMethodTile(
              method: m,
              isSelected: _payMethod == m,
              onTap: () => setState(() => _payMethod = m),
            ),
          ),
          const SizedBox(height: 20),

          _PriceBreakdown(cart: cart, fmt: _fmt),
        ],
      ),

      bottomNavigationBar: _PlaceOrderBar(
        total: _fmt(cart.total),
        isLoading: isPlacing,
        canPlace: _selectedAddress != null && !isPlacing,
        payMethod: _payMethod,
        onTap: _placeOrder,
      ),
    );
  }
}

// ─── Step Header ─────────────────────────────────────────────

class _TitleHeader extends StatelessWidget {
  final String title;

  const _TitleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [Text(title, style: AppTextStyles.labelMd(isDark))]);
  }
}

// ─── Address Cards ────────────────────────────────────────────

class _AddAddressCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
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
                isDark,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
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
                      isDark,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 5),
                Text(address.fullName, style: AppTextStyles.labelMd(isDark)),
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
                  style: AppTextStyles.bodyMd(isDark).copyWith(
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(address.phone, style: AppTextStyles.bodySm(isDark)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              'Change',
              style: AppTextStyles.bodySm(
                isDark,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
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
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: isDark
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
                                  color: isDark
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
                            style: AppTextStyles.labelMd(isDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${item.partSku}',
                            style: AppTextStyles.mono(isDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.sellerName ?? '',
                            style: AppTextStyles.bodySm(isDark),
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
                          style: AppTextStyles.bodyXs(isDark).copyWith(
                            color: isDark
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.currentCode != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColorsDark.success.withValues(alpha: 0.06)
              : AppColorsLight.success.withValues(alpha: 0.06),
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDark
                ? AppColorsDark.success.withValues(alpha: 0.3)
                : AppColorsLight.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isDark ? AppColorsDark.success : AppColorsLight.success,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupon applied!',
                    style: AppTextStyles.labelMd(isDark).copyWith(
                      color: isDark
                          ? AppColorsDark.success
                          : AppColorsLight.success,
                    ),
                  ),
                  Text(
                    widget.currentCode!.toUpperCase(),
                    style: AppTextStyles.mono(isDark).copyWith(
                      color: isDark
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
                style: AppTextStyles.bodySm(isDark).copyWith(
                  color: isDark ? AppColorsDark.error : AppColorsLight.error,
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
            style: AppTextStyles.bodyMd(isDark),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter coupon code',
              hintStyle: AppTextStyles.bodyMd(isDark).copyWith(
                color: isDark
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColorsDark.bgInput
                  : AppColorsLight.bgInput,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : (isDark ? AppColorsDark.border : AppColorsLight.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColorsDark.border : AppColorsLight.border),
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                method.icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColorsDark.textSecondary
                          : AppColorsLight.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(method.label, style: AppTextStyles.labelMd(isDark)),
                      // "Coming soon" badge on UPI
                      if (method == _PayMethod.upi) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColorsDark.warning.withValues(alpha: 0.15)
                                : AppColorsLight.warning.withValues(
                                    alpha: 0.12,
                                  ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Coming soon',
                            style: AppTextStyles.labelXs(isDark).copyWith(
                              color: isDark
                                  ? AppColorsDark.warning
                                  : AppColorsLight.warning,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    method.subtitle,
                    style: AppTextStyles.bodyXs(isDark).copyWith(
                      color: isDark
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // COD extra charge badge
            if (method == _PayMethod.cod)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsDark.warning.withValues(alpha: 0.12)
                      : AppColorsLight.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '+₹40',
                  style: AppTextStyles.labelXs(isDark).copyWith(
                    color: isDark
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDark ? AppColorsDark.border : AppColorsLight.border,
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
              valueColor: isDark
                  ? AppColorsDark.success
                  : AppColorsLight.success,
            ),
          ],
          if (cart.couponDiscount != null && cart.couponDiscount! > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Coupon (${cart.couponCode?.toUpperCase() ?? ''})',
              value: '-${fmt(cart.couponDiscount!)}',
              valueColor: isDark
                  ? AppColorsDark.success
                  : AppColorsLight.success,
            ),
          ],
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Delivery',
            value: cart.deliveryCharge == 0 ? 'FREE' : fmt(cart.deliveryCharge),
            valueColor: cart.deliveryCharge == 0
                ? (isDark ? AppColorsDark.success : AppColorsLight.success)
                : null,
          ),
          const SizedBox(height: 10),
          _PriceRow(label: 'GST (18%)', value: fmt(cart.gst)),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Total', style: AppTextStyles.heading(isDark)),
              ),
              Text(fmt(cart.total), style: AppTextStyles.priceLg()),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Inclusive of all taxes',
              style: AppTextStyles.bodyXs(isDark).copyWith(
                color: isDark
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd(isDark).copyWith(
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMd(isDark).copyWith(
            color:
                valueColor ??
                (isDark
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
  final _PayMethod payMethod;
  final VoidCallback onTap;

  const _PlaceOrderBar({
    required this.total,
    required this.isLoading,
    required this.canPlace,
    required this.payMethod,
    required this.onTap,
  });

  // Label changes based on selected payment method
  String get _buttonLabel {
    switch (payMethod) {
      case _PayMethod.cod:
        return 'Place Order';
      case _PayMethod.upi:
        return 'Pay via UPI';
      case _PayMethod.razorpay:
        return 'Pay Now';
    }
  }

  IconData get _buttonIcon {
    switch (payMethod) {
      case _PayMethod.cod:
        return Icons.arrow_forward;
      case _PayMethod.upi:
      case _PayMethod.razorpay:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColorsDark.border : AppColorsLight.border,
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
                      style: AppTextStyles.bodyXs(isDark).copyWith(
                        color: isDark
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
                  child: AppButton(
                    label: _buttonLabel,
                    isLoading: isLoading,
                    trailingIcon: _buttonIcon,
                    onTap: canPlace ? onTap : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'By placing order you agree to our Terms & Conditions',
              style: AppTextStyles.bodyXs(isDark).copyWith(
                color: isDark
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
