import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/logic/cart_cubit.dart';
import 'features/checkout/logic/checkout_cubit.dart';
import 'features/main_navigation_screen.dart';
import 'features/products/data/product_repository.dart';
import 'features/products/logic/product_list_cubit.dart';
import 'features/wishlist/data/wishlist_repository.dart';
import 'features/wishlist/logic/wishlist_cubit.dart';

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ConnectivityService connectivityService;
  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final WishlistRepository wishlistRepository;

  const MyApp({
    super.key,
    required this.storageService,
    required this.connectivityService,
    required this.authRepository,
    required this.productRepository,
    required this.cartRepository,
    required this.wishlistRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storageService),
        RepositoryProvider.value(value: connectivityService),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: cartRepository),
        RepositoryProvider.value(value: wishlistRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(storageService)),
          BlocProvider(create: (_) => AuthCubit(authRepository)..checkAuthStatus()),
          BlocProvider(
            create: (_) {
              final cubit = ProductListCubit(productRepository);
              if (authRepository.getCachedUser() != null) {
                cubit.fetchInitial();
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (_) {
              final cubit = CartCubit(cartRepository);
              final user = authRepository.getCachedUser();
              if (user != null) {
                cubit.initializeForUser(user.username);
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (_) {
              final cubit = WishlistCubit(wishlistRepository);
              final user = authRepository.getCachedUser();
              if (user != null) {
                cubit.initializeForUser(user.username);
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (ctx) => CheckoutCubit(cartCubit: ctx.read<CartCubit>()),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Product & Order Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // Initialize user-isolated cart, wishlist and catalog for this user
                final user = state.user;
                context.read<CartCubit>().initializeForUser(user.username);
                context.read<WishlistCubit>().initializeForUser(user.username);
                context.read<ProductListCubit>().fetchInitial();
              }
            },
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const MainNavigationScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
