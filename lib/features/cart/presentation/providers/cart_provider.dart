import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/cart_repository.dart';
import '../../domain/models/cart_model.dart';

enum CartStatus { initial, loading, loaded, updating, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repo;

  CartProvider({required CartRepository repo}) : _repo = repo;

  // ── State
  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;

  // ── Getters
  CartStatus get status => _status;

  CartModel? get cart => _cart;

  String? get error => _error;

  bool get isLoading => _status == CartStatus.loading;

  bool get isUpdating => _status == CartStatus.updating;

  int get itemCount => _cart?.items.length ?? 0;

  double get total => _cart?.total ?? 0;

  Future<void> loadCart(BuildContext context) async {
    final token = await SecureStorage.getAccessToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login to view cart items"),
        ),
      );
      //context.go("/login");
      return;
    }
    _status = CartStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _cart = await _repo.getCart();
      _status = CartStatus.loaded;
    } catch (e) {
      _status = CartStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> addItem({
    required String partId,
    required String sellerId,
    required String partName,
    required String partSku,
    required String? partImage,
    required String sellerName,
    required double price,
    double? mrp,
    int quantity = 1,
  }) async {
    _setUpdating();
    try {
      _cart = await _repo.addItem(
        partId: partId,
        sellerId: sellerId,
        quantity: quantity,
        partName: partName,
        partSku: partSku,
        partImage: partImage,
        sellerName: sellerName,
        price: price,
        mrp: mrp,
      );
      _status = CartStatus.loaded;
      _error = null;
    } catch (e) {
      _status = CartStatus.loaded; // revert to showing current cart
      _error = e.toString();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Update quantity (with optimistic update)
  // ─────────────────────────────────────────────────────────
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
    required BuildContext context,
  }) async {
    // Optimistic: update locally first
    if (_cart != null) {
      final updatedItems = _cart!.items
          .map((i) => i.id == itemId ? i.copyWith(quantity: quantity) : i)
          .toList();
      _cart = _cart!.copyWith(items: updatedItems);
      notifyListeners();
    }

    try {
      _cart = await _repo.updateItem(itemId: itemId, quantity: quantity);
    } catch (e) {
      _error = e.toString();
      // Reload to get true state
      await loadCart(context);
      return;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Remove item (with optimistic update)
  // ─────────────────────────────────────────────────────────
  Future<void> removeItem(String itemId, BuildContext context) async {
    // Optimistic: remove locally first
    if (_cart != null) {
      final updatedItems = _cart!.items.where((i) => i.id != itemId).toList();
      _cart = _cart!.copyWith(items: updatedItems);
      notifyListeners();
    }

    try {
      _cart = await _repo.removeItem(itemId: itemId);
    } catch (e) {
      _error = e.toString();
      await loadCart(context);
      return;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Apply coupon
  // ─────────────────────────────────────────────────────────
  Future<bool> applyCoupon(String code) async {
    _setUpdating();
    try {
      _cart = await _repo.applyCoupon(couponCode: code);
      _status = CartStatus.loaded;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = CartStatus.loaded;
      _error = 'Invalid coupon code';
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Remove coupon
  // ─────────────────────────────────────────────────────────
  Future<void> removeCoupon() async {
    try {
      _cart = await _repo.removeCoupon();
      notifyListeners();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // Clear error
  // ─────────────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers
  void _setUpdating() {
    _status = CartStatus.updating;
    _error = null;
    notifyListeners();
  }
}
