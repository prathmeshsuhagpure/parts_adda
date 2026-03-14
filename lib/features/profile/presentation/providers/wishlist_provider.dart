import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<String> _wishlist = [];

  List<String> get wishlist => _wishlist;

  bool isInWishlist(String partId) {
    return _wishlist.contains(partId);
  }

  void toggleWishlist(String partId) {
    if (_wishlist.contains(partId)) {
      _wishlist.remove(partId);
    } else {
      _wishlist.add(partId);
    }
    notifyListeners();
  }
}