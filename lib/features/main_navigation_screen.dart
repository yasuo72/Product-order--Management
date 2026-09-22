import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import 'auth/logic/auth_cubit.dart';
import 'cart/logic/cart_cubit.dart';
import 'cart/logic/cart_state.dart';
import 'cart/presentation/cart_screen.dart';
import 'products/logic/product_list_cubit.dart';
import 'products/presentation/product_list_screen.dart';
import 'wishlist/logic/wishlist_cubit.dart';
import 'wishlist/logic/wishlist_state.dart';
import 'wishlist/presentation/wishlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final cartCubit = context.read<CartCubit>();
        if (cartCubit.state.userId != user.username) {
          cartCubit.initializeForUser(user.username);
        }
        final wishlistCubit = context.read<WishlistCubit>();
        if (wishlistCubit.state.userId != user.username) {
          wishlistCubit.initializeForUser(user.username);
        }
      }
      final productCubit = context.read<ProductListCubit>();
      if (productCubit.state.products.isEmpty) {
        productCubit.fetchInitial();
      }
    });
  }

  void _goToBrowse() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const ProductListScreen(),
      WishlistScreen(onBrowseProducts: _goToBrowse),
      CartScreen(onBrowseProducts: _goToBrowse),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primary.withAlpha(40),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primary),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: BlocBuilder<WishlistCubit, WishlistState>(
                    builder: (context, state) {
                      if (state.items.isEmpty) {
                        return const Icon(Icons.favorite_border_rounded);
                      }
                      return Badge(
                        label: Text('${state.items.length}'),
                        backgroundColor: AppColors.error,
                        child: const Icon(Icons.favorite_border_rounded),
                      );
                    },
                  ),
                  selectedIcon: BlocBuilder<WishlistCubit, WishlistState>(
                    builder: (context, state) {
                      if (state.items.isEmpty) {
                        return const Icon(Icons.favorite_rounded, color: AppColors.error);
                      }
                      return Badge(
                        label: Text('${state.items.length}'),
                        backgroundColor: AppColors.error,
                        child: const Icon(Icons.favorite_rounded, color: AppColors.error),
                      );
                    },
                  ),
                  label: 'Wishlist',
                ),
                NavigationDestination(
                  icon: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state.totalQuantity == 0) {
                        return const Icon(Icons.shopping_bag_outlined);
                      }
                      return Badge(
                        label: Text('${state.totalQuantity}'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.shopping_bag_outlined),
                      );
                    },
                  ),
                  selectedIcon: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state.totalQuantity == 0) {
                        return const Icon(Icons.shopping_bag_rounded, color: AppColors.primary);
                      }
                      return Badge(
                        label: Text('${state.totalQuantity}'),
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                      );
                    },
                  ),
                  label: 'Cart',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
