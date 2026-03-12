class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String b2bRegister = '/register/b2b';

  // Main tabs
  static const String home = '/home';
  static const String search = '/search';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String settings = '/settings';

  static const String dealerHome = '/dealer/home';
  static const String dealerOrders = '/dealer/orders';
  static const String dealerInventory = '/dealer/inventory';
  static const String dealerProfile = '/dealer/profile';

  // Catalog
  static const String allCategories = '/categories';
  static const String subCategory   = '/category/:id/sub';
  static const String category = '/category/:id';
  static const String partDetail = '/parts/:id';
  static const String filters = '/search/filters';

  // Checkout
  static const String checkout = '/checkout';
  static const String selectAddress = '/checkout/address';
  static const String orderSuccess = '/order/success';

  // Orders
  static const String orderDetail = '/orders/:id';
  static const String tracking = '/orders/:id/track';

  // Profile sub-screens
  static const String savedAddresses = '/profile/addresses';
  static const String myVehicles = '/profile/vehicles';
  static const String notifications = '/profile/notifications';
  static const String editProfile = '/profile/edit';


  // Product
  static const String addProduct = '/dealer/inventory/add';


  // Helpers
  static String categoryPath(String id, String name) =>
      '/category/$id?name=$name';
  static String subCategoryPath(String id, String name) =>
      '/category/$id/sub?name=$name';
  static String partsPath(String categoryId, String categoryName) =>
      '/category/$categoryId?name=$categoryName';
  static String partDetailPath(String id) => '/parts/$id';
  static String orderDetailPath(String id) => '/orders/$id';
  static String trackingPath(String id) => '/orders/$id/track';
  static String searchPath({String? query}) =>
      query != null ? '/search?q=$query' : '/search';
}
