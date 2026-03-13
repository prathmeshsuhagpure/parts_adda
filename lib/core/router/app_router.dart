import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parts_adda/features/catalog/presentation/screens/all_categories_screen.dart';
import 'package:parts_adda/features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/b2b_register_screen.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/presentation/screens/sub_category_screen.dart';
import '../../features/dealer/presentation/screens/dashboard_screen.dart';
import '../../features/dealer/presentation/screens/inventory_screen.dart';
import '../../features/dealer/presentation/screens/orders_screen.dart';
import '../../features/dealer/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/search/presentation/screens/filter_screen.dart';
import '../../features/catalog/presentation/screens/category_screen.dart';
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
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _customerShellKey = GlobalKey<NavigatorState>(
    debugLabel: 'customerShell',
  );
  static final _dealerShellKey = GlobalKey<NavigatorState>(
    debugLabel: 'dealerShell',
  );

  static GoRouter router(
    AuthProvider authProvider
  ) => GoRouter(
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
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.b2bRegister,
        builder: (_, _) => const B2bRegisterScreen(),
      ),

      // ── Bottom-nav shell
      ShellRoute(
        navigatorKey: _customerShellKey,
        builder: (_, _, child) => CustomerMainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const HomeScreen()),
          ),

          GoRoute(
            path: AppRoutes.wishlist,
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
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const OrdersScreen()),
          ),

          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: const SettingsScreen()),
          ),
        ],
      ),

      ShellRoute(
        navigatorKey: _dealerShellKey,
        builder: (_, _, child) => DealerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dealerHome,
            builder: (_, _) => const DealerDashboardScreen(),
          ),

          GoRoute(
            path: AppRoutes.dealerOrders,
            builder: (_, _) => const DealerOrdersScreen(),
          ),

          GoRoute(
            path: AppRoutes.dealerInventory,
            builder: (_, _) => const InventoryScreen(),
          ),

          GoRoute(
            path: AppRoutes.dealerProfile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, _) => EditProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.addProduct,
        builder: (_, _) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.allCategories,
        builder: (_, _) => AllCategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.subCategory,
        builder: (_, state) => SubCategoryScreen(
          categoryId: state.pathParameters['id']!,
          categoryName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.category,
        builder: (_, state) => CategoryScreen(
          categoryId: state.pathParameters['id']!,
          categoryName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.partDetail,
        builder: (_, state) =>
            PartDetailScreen(partId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.filters, builder: (_, _) => const FilterScreen()),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) =>
            SearchScreen(initialQuery: state.uri.queryParameters['q']),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (_, _) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectAddress,
        builder: (_, _) => const AddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (_, state) =>
            OrderSuccessScreen(orderId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (_, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, state) =>
            TrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.savedAddresses,
        builder: (_, _) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.myVehicles,
        builder: (_, _) => const MyVehiclesScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
    ],
  );
}
