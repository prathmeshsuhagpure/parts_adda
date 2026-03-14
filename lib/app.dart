import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parts_adda/features/dealer/presentation/providers/inventory_provider.dart';
import 'package:parts_adda/features/profile/presentation/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/provider/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/category/data/catalog_repository.dart';
import 'features/category/presentation/providers/catalog_provider.dart';
import 'features/dealer/presentation/providers/dealer_order_provider.dart';
import 'features/search/data/search_repository.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/orders/data/order_repository.dart';
import 'features/orders/presentation/providers/order_provider.dart';
import 'features/profile/data/user_repository.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

class PartsAddaApp extends StatefulWidget {
  const PartsAddaApp({super.key});

  @override
  State<PartsAddaApp> createState() => _PartsAddaAppState();
}

class _PartsAddaAppState extends State<PartsAddaApp> {
  // ── Repositories (singletons)
  late final AuthRepository _authRepo;
  late final CartRepository _cartRepo;
  late final CatalogRepository _catalogRepo;
  late final SearchRepository _searchRepo;
  late final OrderRepository _orderRepo;
  late final UserRepository _userRepo;

  // ── Providers that live for the whole app lifetime
  late final AuthProvider _authProvider;
  late final CartProvider _cartProvider;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final dio = ApiClient.instance;
    _authRepo = AuthRepository(dio: dio);
    _cartRepo = CartRepository(dio: dio);
    _catalogRepo = CatalogRepository(dio: dio);
    _searchRepo = SearchRepository(dio: dio);
    _orderRepo = OrderRepository(dio: dio);
    _userRepo = UserRepository(dio: dio);

    _authProvider = AuthProvider(repo: _authRepo);
    _authProvider.initialize();
    _cartProvider = CartProvider(repo: _cartRepo);
    _router = AppRouter.router(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _cartProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Long-lived providers
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _cartProvider),

        // ── Repositories (for per-screen provider creation)
        Provider.value(value: _catalogRepo),
        Provider.value(value: _searchRepo),
        Provider.value(value: _orderRepo),
        Provider.value(value: _userRepo),

        // ── Per-feature providers (recreated lazily)
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(repo: _catalogRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(repo: _searchRepo),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider(repo: _orderRepo)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(repo: _userRepo)),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => DealerOrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Parts Adda',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
