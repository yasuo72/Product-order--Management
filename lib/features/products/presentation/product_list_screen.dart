import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_order_app/core/constants/app_colors.dart';
import 'package:product_order_app/core/services/connectivity_service.dart';
import 'package:product_order_app/core/theme/theme_cubit.dart';
import 'package:product_order_app/core/widgets/connectivity_banner.dart';
import 'package:product_order_app/core/widgets/empty_state_view.dart';
import 'package:product_order_app/core/widgets/error_state_view.dart';
import 'package:product_order_app/core/widgets/shimmer_placeholder.dart';
import 'package:product_order_app/features/auth/logic/auth_cubit.dart';
import 'package:product_order_app/features/products/logic/product_list_cubit.dart';
import 'package:product_order_app/features/products/logic/product_list_state.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProductListCubit>();
      if (cubit.state.products.isEmpty && cubit.state.status != ProductListStatus.loading) {
        cubit.fetchInitial();
      }
    });
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductListCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.auto_awesome_rounded;
      case 'beauty':
        return Icons.face_retouching_natural_rounded;
      case 'fragrances':
        return Icons.spa_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'groceries':
        return Icons.local_grocery_store_rounded;
      case 'home-decoration':
        return Icons.lightbulb_rounded;
      case 'kitchen-accessories':
        return Icons.soup_kitchen_rounded;
      case 'laptops':
        return Icons.laptop_mac_rounded;
      case 'mens-shirts':
      case 'mens-shoes':
      case 'mens-watches':
        return Icons.male_rounded;
      case 'womens-dresses':
      case 'womens-shoes':
      case 'womens-watches':
        return Icons.female_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = context.watch<AuthCubit>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Discover',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (currentUser != null)
              Text(
                'Signed in as @${currentUser.username}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryLight,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 18,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkCard : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.error,
              ),
            ),
            tooltip: 'Sign Out',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Sign Out'),
                  content: const Text(
                    'Are you sure you want to sign out? Your user-isolated cart and wishlist will remain preserved on this device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Connectivity Status Banner
          ConnectivityBanner(
            connectivityService: context.read<ConnectivityService>(),
            onRetry: () => context.read<ProductListCubit>().refresh(),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  context.read<ProductListCubit>().searchWithDebounce(query);
                },
                decoration: InputDecoration(
                  hintText: 'Search products by title or keyword...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ProductListCubit>().search('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips Bar
          BlocBuilder<ProductListCubit, ProductListState>(
            buildWhen: (prev, curr) =>
                prev.categories != curr.categories ||
                prev.selectedCategory != curr.selectedCategory,
            builder: (context, state) {
              return SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final isSelected = state.selectedCategory.toLowerCase() == category.toLowerCase();
                    final icon = _getCategoryIcon(category);

                    return GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        context.read<ProductListCubit>().selectCategory(category);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category[0].toUpperCase() + category.substring(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // Main Product Grid / States
          Expanded(
            child: BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) {
                if (state.status == ProductListStatus.loading && state.products.isEmpty) {
                  return const ProductGridSkeleton();
                }

                if (state.status == ProductListStatus.failure && state.products.isEmpty) {
                  return ErrorStateView(
                    message: state.errorMessage ?? 'Unable to fetch products.',
                    onRetry: () => context.read<ProductListCubit>().fetchInitial(),
                  );
                }

                if (state.products.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Products Found',
                    message: state.searchQuery.isNotEmpty
                        ? 'We couldn\'t find any match for "${state.searchQuery}". Try different keywords.'
                        : 'No products available in this category.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      context.read<ProductListCubit>().selectCategory('All');
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<ProductListCubit>().refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: state.products.length + (state.status == ProductListStatus.loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      return ProductCard(product: state.products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
