import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parts_adda/features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/b2b_register_screen.dart';
import '../../features/category/presentation/screens/all_categories_screen.dart';
import '../../features/category/presentation/screens/category_screen.dart';
import '../../features/category/presentation/screens/sub_category_screen.dart';
import '../../features/dealer/presentation/screens/dashboard_screen.dart';
import '../../features/dealer/presentation/screens/inventory_screen.dart';
import '../../features/dealer/presentation/screens/orders_screen.dart';
import '../../features/dealer/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/search/presentation/screens/filter_screen.dart';
import '../../features/parts/presentation/screens/part_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/address_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/tracking_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/saved_addresses_screen.dart';
import '../../features/profile/presentation/screens/my_vehicles_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/profile/presentation/screens/notifications_screen.dart';
import '../../shared/widgets/dealer_shell.dart';
import '../../shared/widgets/main_shell.dart';
import 'app_routes.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final customerShellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'customerShell',
  );
  static final _dealerShellKey = GlobalKey<NavigatorState>(
    debugLabel: 'dealerShell',
  );

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootKey;

  static GoRouter router(AuthProvider authProvider) => GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final role = authProvider.user?.role.name;
      final location = state.uri.path;
      final seenOnboarding = authProvider.seenOnboarding;

      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.b2bRegister;

      if (status == AuthStatus.initial) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // First launch → onboarding
      if (!seenOnboarding) {
        return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      // Authenticated users
      if (status == AuthStatus.authenticated) {
        if (location == AppRoutes.splash ||
            location == AppRoutes.onboarding ||
            isAuthRoute) {
          return role == "dealer" ? AppRoutes.dealerHome : AppRoutes.home;
        }

        if (role == "dealer" && !location.startsWith("/dealer")) {
          return AppRoutes.dealerHome;
        }

        if (role != "dealer" && location.startsWith("/dealer")) {
          return AppRoutes.home;
        }
      }

      if (status == AuthStatus.unauthenticated) {
        if (location == AppRoutes.splash || location == AppRoutes.onboarding) {
          return AppRoutes.home;
        }
        if (location.startsWith("/dealer")) return AppRoutes.home;
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: "splash",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: "onboarding",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const OnboardingScreen()),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: "login",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: "register",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.b2bRegister,
        name: "b2bRegister",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const B2bRegisterScreen()),
      ),

      // ── Bottom-nav shell
      ShellRoute(
        navigatorKey: customerShellNavigatorKey,
        parentNavigatorKey: _rootKey,
        builder: (_, _, child) => CustomerMainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: "home",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const HomeScreen()),
          ),

          GoRoute(
            path: AppRoutes.wishlist,
            name: "wishlist",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const WishlistScreen()),
          ),

          GoRoute(
            path: AppRoutes.cart,
            name: "cart",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const CartScreen()),
          ),

          GoRoute(
            path: AppRoutes.orders,
            name: "orders",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const OrdersScreen()),
          ),

          GoRoute(
            path: AppRoutes.settings,
            name: "settings",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const SettingsScreen()),
          ),
        ],
      ),

      ShellRoute(
        navigatorKey: _dealerShellKey,
        parentNavigatorKey: _rootKey,
        builder: (_, _, child) => DealerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dealerHome,
            name: "dealerHome",
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const DealerDashboardScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.dealerOrders,
            name: "dealerOrders",
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const DealerOrdersScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.dealerInventory,
            name: "dealerInventory",
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const InventoryScreen(),
            ),
          ),

          GoRoute(
            path: AppRoutes.dealerProfile,
            name: "dealerProfile",
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: "editProfile",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const EditProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        name: "addProduct",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AddProductScreen()),
      ),
      GoRoute(
        path: AppRoutes.allCategories,
        name: "allCategories",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AllCategoriesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.subCategory,
        name: "subCategory",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: SubCategoryScreen(
            categoryId: state.pathParameters['id']!,
            categoryName: state.uri.queryParameters['name'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.category,
        name: "category",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: CategoryScreen(
            categoryId: state.pathParameters['id']!,
            categoryName: state.uri.queryParameters['name'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.partDetail,
        name: "partDetail",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: PartDetailScreen(partId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.filters,
        name: "filters",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const FilterScreen()),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: "search",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: SearchScreen(initialQuery: state.uri.queryParameters['q']),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: "checkout",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.selectAddress,
        name: "selectAddress",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AddressScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        name: "orderSuccess",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: OrderSuccessScreen(orderId: state.extra as String? ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        name: "orderDetail",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: OrderDetailScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        name: "tracking",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: TrackingScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.savedAddresses,
        name: "savedAddresses",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SavedAddressesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.myVehicles,
        name: "myVehicles",
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MyVehiclesScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: "notifications",
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
    ],
  );
}
