import 'package:flutter_bloc/flutter_bloc.dart';
import '../../products/data/models/product_model.dart';
import '../data/wishlist_repository.dart';
import 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _wishlistRepository;

  WishlistCubit(this._wishlistRepository) : super(const WishlistState());

  void initializeForUser(String userId) {
    if (userId.isEmpty) {
      emit(const WishlistState());
      return;
    }
    final items = _wishlistRepository.getUserWishlist(userId);
    emit(WishlistState(items: items, userId: userId));
  }

  Future<void> toggleWishlist(ProductModel product) async {
    final currentUserId = state.userId;
    final currentItems = List<ProductModel>.from(state.items);
    final exists = currentItems.any((item) => item.id == product.id);

    if (exists) {
      currentItems.removeWhere((item) => item.id == product.id);
    } else {
      currentItems.add(product);
    }

    emit(state.copyWith(items: currentItems));
    if (currentUserId.isNotEmpty) {
      await _wishlistRepository.saveUserWishlist(currentUserId, currentItems);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    final currentUserId = state.userId;
    final currentItems = List<ProductModel>.from(state.items)
      ..removeWhere((item) => item.id == productId);

    emit(state.copyWith(items: currentItems));
    if (currentUserId.isNotEmpty) {
      await _wishlistRepository.saveUserWishlist(currentUserId, currentItems);
    }
  }

  Future<void> clearWishlist() async {
    final currentUserId = state.userId;
    emit(state.copyWith(items: const []));
    if (currentUserId.isNotEmpty) {
      await _wishlistRepository.clearUserWishlist(currentUserId);
    }
  }
}
