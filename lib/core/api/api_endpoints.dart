class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ── Dealer
  static const String applyForDealer = '/dealer/apply';
  static const String dealerStatus = '/dealer/status';

  // ── User / Profile
  static const String getUserProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String wishlist = '/users/wishlist';
  static String wishlistItem(String partId) => '/users/wishlist/$partId';
  static const String myVehicles = '/users/vehicles';

  // ── Addresses
  static const String getAddresses = '/users/addresses';
  static const String addAddresses = '/users/addresses';
  static String updateAddress(String id) => '/users/addresses/$id';
  static String addressById(String id) => '/users/addresses/$id';
  static String deleteAddress(String id) => '/users/addresses/$id';

  // ── Parts
  static const String parts = '/parts';
  static String partById(String id) => '/parts/$id';
  static String partsByOem(String oem) => '/parts/oem/$oem';
  static const String brands = '/brands';
  static String partsByCategory(String categoryId) =>
      '/parts/$categoryId/parts';

  // ── Categories
  static const String allCategories = '/categories';
  static const String rootCategories = '/categories/root';
  static String subCategories(String id) => '/categories/$id/sub';
  static const String treeCategory = '/categories/tree';

  // ── Search
  static const String search = '/search';
  static const String searchSuggestions = '/search/suggestions';

  // ── Vehicles
  static const String vehicleMakes = '/vehicles/makes';
  static String vehicleModels(String make) => '/vehicles/$make/models';
  static String vehicleYears(String make, String model) =>
      '/vehicles/$make/$model/years';
  static String vehicleVariants(String make, String model, String year) =>
      '/vehicles/$make/$model/$year/variants';
  static const String addVehicle = '/users/vehicles';
  static const String getVehicles = '/users/vehicles';
  static String removeVehicle(String id) => '/users/vehicles/$id';

  // ── Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String updateCartItem(String itemId) => '/cart/items/$itemId';
  static String removeCartItem(String itemId) => '/cart/items/$itemId';
  static const String cartCoupon = '/cart/coupon';
  static const String cartCouponRemove = '/cart/coupon/remove';

  // ── Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderInvoice(String id) => '/orders/$id/invoice';
  static String orderTrack(String id) => '/orders/$id/track';

  // ── Reviews
  static String partReviews(String partId) => '/parts/$partId/reviews';
  static const String postReview = '/reviews';

  // ── Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllRead = '/notifications/read-all';
  static const String registerFcmToken = '/notifications/fcm-token';
}
