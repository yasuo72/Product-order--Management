import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:product_order_app/core/constants/app_colors.dart';
import 'package:product_order_app/core/widgets/app_toast.dart';
import 'package:product_order_app/core/widgets/error_state_view.dart';
import 'package:product_order_app/features/cart/logic/cart_cubit.dart';
import 'package:product_order_app/features/cart/logic/cart_state.dart';
import 'package:product_order_app/features/main_navigation_screen.dart';
import 'package:product_order_app/features/products/data/product_repository.dart';
import 'package:product_order_app/features/products/logic/product_detail_cubit.dart';
import 'package:product_order_app/features/products/logic/product_detail_state.dart';
import 'package:product_order_app/features/wishlist/logic/wishlist_cubit.dart';
import 'package:product_order_app/features/wishlist/logic/wishlist_state.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailCubit(
        context.read<ProductRepository>(),
      )..fetchDetail(productId),
      child: ProductDetailView(productId: productId),
    );
  }
}

class ProductDetailView extends StatefulWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        if (state is ProductDetailLoading || state is ProductDetailInitial) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }

        if (state is ProductDetailFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorStateView(
              message: state.message,
              onRetry: () => context.read<ProductDetailCubit>().fetchDetail(widget.productId),
            ),
          );
        }

        final product = (state as ProductDetailSuccess).product;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            actions: [
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, wishlistState) {
                  final isFav = wishlistState.isFavorite(product.id);
                  return IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFav ? AppColors.error : null,
                      ),
                    ),
                    onPressed: () {
                      context.read<WishlistCubit>().toggleWishlist(product);
                      AppToast.showWishlist(
                        context: context,
                        product: product,
                        isAdded: !isFav,
                        onViewWishlist: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          MainNavigationScreen.switchTab(context, 1);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                SizedBox(
                  height: 310,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: product.images.isNotEmpty ? product.images.length : 1,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final imgUrl = product.images.isNotEmpty
                              ? product.images[index]
                              : product.thumbnail;
                          return Container(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.all(16),
                            child: CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),

                      // Page Indicators
                      if (product.images.length > 1)
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _currentImageIndex == index ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withAlpha(100),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Details Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (product.brand != null && product.brand!.isNotEmpty)
                            Text(
                              'Brand: ${product.brand}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Product Title
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Rating Bar & Review count
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star_rounded,
                              color: AppColors.accent,
                            ),
                            itemCount: 5,
                            itemSize: 18.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating.toStringAsFixed(1)} / 5.0',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: product.stock > 10 ? AppColors.success.withAlpha(25) : AppColors.warning.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.stock > 10 ? 'In Stock (${product.stock})' : 'Low Stock (${product.stock} left)',
                              style: TextStyle(
                                color: product.stock > 10 ? AppColors.success : AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Price & Discount Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      '\$${product.discountedPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (product.discountPercentage > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (product.discountPercentage > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.error, Color(0xFFFB7185)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Save ${product.discountPercentage.round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Specifications & Highlights (Key Refinement)
                      _buildSpecCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Warranty',
                        subtitle: product.warrantyInformation,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildSpecCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'Shipping',
                        subtitle: product.shippingInformation,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildSpecCard(
                        icon: Icons.replay_circle_filled_outlined,
                        title: 'Return Policy',
                        subtitle: product.returnPolicy,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  final inCart = cartState.isInCart(product.id);
                  final quantity = cartState.getProductQuantity(product.id);

                  if (inCart) {
                    return Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: () {
                                  context.read<CartCubit>().decrementQuantity(product.id);
                                },
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () {
                                  context.read<CartCubit>().incrementQuantity(product.id);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AppToast.showInfo(
                                context,
                                'Item is already in your cart',
                                actionLabel: 'VIEW CART',
                                onAction: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  MainNavigationScreen.switchTab(context, 2);
                                },
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('In Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartCubit>().addToCart(product);
                        AppToast.showAddToCart(
                          context: context,
                          product: product,
                          onViewCart: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            MainNavigationScreen.switchTab(context, 2);
                          },
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
