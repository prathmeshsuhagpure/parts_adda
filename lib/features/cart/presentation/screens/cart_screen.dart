import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../../domain/models/cart_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/main_shell.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart(context);
    });
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        title: Consumer<CartProvider>(
          builder: (_, cart, _) {
            final count = cart.cart?.items.length ?? 0;
            return Text('My Cart ($count)');
          },
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) return const Center(child: AppLoadingIndicator());

          if (cart.status == CartStatus.error) {
            return Center(
              child: Text(
                cart.error ?? 'Error loading cart',
                style: AppTextStyles.bodyMd(isDarkMode),
              ),
            );
          }

          final cartData = cart.cart;
          if (cartData == null || cartData.items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add parts to get started',
              actionLabel: 'Browse Parts',
              onAction: () => context.go(AppRoutes.home),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...cartData.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CartItemCard(item: item),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CouponRow(
                      controller: _couponCtrl,
                      appliedCoupon: cartData.couponCode,
                      onApply: () async {
                        if (_couponCtrl.text.isEmpty) return;
                        final ok = await cart.applyCoupon(
                          _couponCtrl.text.trim(),
                        );
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(cart.error ?? 'Invalid coupon'),
                              backgroundColor: isDarkMode
                                  ? AppColorsDark.error
                                  : AppColorsLight.error,
                            ),
                          );
                        }
                      },
                      onRemove: () {
                        _couponCtrl.clear();
                        cart.removeCoupon();
                      },
                    ),
                    const SizedBox(height: 14),
                    _OrderSummary(cart: cartData, fmt: _fmt),
                  ],
                ),
              ),
              _BottomBar(cart: cartData, fmt: _fmt),
            ],
          );
        },
      ),
    );
  }
}

// ── Cart Item ──────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              color: isDarkMode
                  ? AppColorsDark.bgInput
                  : AppColorsLight.bgInput,
              child: item.partImage != null
                  ? CachedNetworkImage(
                      imageUrl: item.partImage!,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.settings,
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
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
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.partSku} · ${item.sellerName}',
                  style: AppTextStyles.bodyXs(isDarkMode),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: AppTextStyles.priceSm(),
                    ),
                    if (item.mrp != null && item.mrp! > item.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        '₹${item.mrp!.toStringAsFixed(0)}',
                        style: AppTextStyles.strikethrough(isDarkMode),
                      ),
                    ],
                    const Spacer(),
                    _QtyControl(item: item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final CartItemModel item;

  const _QtyControl({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cart = context.read<CartProvider>();
    return Row(
      children: [
        _QBtn(
          icon: item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
          isDestructive: item.quantity <= 1,
          onTap: () => item.quantity <= 1
              ? cart.removeItem(item.id, context)
              : cart.updateQuantity(
                  itemId: item.id,
                  quantity: item.quantity - 1,
                  context: context,
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            item.quantity.toString(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDarkMode
                  ? AppColorsDark.textPrimary
                  : AppColorsLight.textPrimary,
            ),
          ),
        ),
        _QBtn(
          icon: Icons.add,
          onTap: () => cart.updateQuantity(
            itemId: item.id,
            quantity: item.quantity + 1,
            context: context,
          ),
        ),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _QBtn({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDestructive
              ? (isDarkMode ? AppColorsDark.error : AppColorsLight.error)
              : (isDarkMode
                    ? AppColorsDark.textPrimary
                    : AppColorsLight.textPrimary),
        ),
      ),
    );
  }
}

// ── Coupon ─────────────────────────────────────────────────────────────────

class _CouponRow extends StatelessWidget {
  final TextEditingController controller;
  final String? appliedCoupon;
  final VoidCallback onApply, onRemove;

  const _CouponRow({
    required this.controller,
    required this.appliedCoupon,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColorsDark.success.withValues(alpha: 0.06)
              : AppColorsLight.success.withValues(alpha: 0.06),
          border: Border.all(
            color: isDarkMode
                ? AppColorsDark.success.withValues(alpha: 0.3)
                : AppColorsLight.success.withValues(alpha: 0.3),
          ),
          borderRadius: AppRadius.cardRadius,
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer,
              color: isDarkMode
                  ? AppColorsDark.success
                  : AppColorsLight.success,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'Coupon ',
                  style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                    color: isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: appliedCoupon!,
                      style: AppTextStyles.labelMd(isDarkMode).copyWith(
                        color: isDarkMode
                            ? AppColorsDark.success
                            : AppColorsLight.success,
                      ),
                    ),
                    const TextSpan(text: ' applied!'),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(
                'Remove',
                style: AppTextStyles.labelSm(isDarkMode).copyWith(
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMd(isDarkMode),
              decoration: InputDecoration(
                hintText: '🏷️  Enter coupon code',
                hintStyle: AppTextStyles.bodyMd(isDarkMode).copyWith(
                  color: isDarkMode
                      ? AppColorsDark.textMuted
                      : AppColorsLight.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: onApply,
            child: Text(
              'Apply',
              style: AppTextStyles.labelMd(
                isDarkMode,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary ────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final CartModel cart;
  final String Function(double) fmt;

  const _OrderSummary({required this.cart, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: [
          _Row('Subtotal', fmt(cart.subtotal)),
          if (cart.discount > 0)
            _Row(
              'Discount',
              '-${fmt(cart.discount)}',
              color: isDarkMode
                  ? AppColorsDark.success
                  : AppColorsLight.success,
            ),
          _Row(
            'Delivery',
            cart.deliveryCharge == 0 ? 'FREE' : fmt(cart.deliveryCharge),
            color: cart.deliveryCharge == 0 ? AppColorsDark.success : null,
          ),
          _Row('GST (18%)', fmt(cart.gst)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
              height: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headingSm(isDarkMode)),
              Text(fmt(cart.total), style: AppTextStyles.priceLg()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? color;

  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMd(
              isDarkMode,
            ).copyWith(color: color ?? AppColorsDark.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Bottom CTA ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final CartModel cart;
  final String Function(double) fmt;

  const _BottomBar({required this.cart, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fmt(cart.total), style: AppTextStyles.priceMd()),
              Text(
                '${cart.items.length} items',
                style: AppTextStyles.bodyXs(isDarkMode),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              label: 'Proceed to Checkout',
              onTap: () => context.push(AppRoutes.checkout),
              trailingIcon: Icons.arrow_forward,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
