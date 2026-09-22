import 'package:flutter_bloc/flutter_bloc.dart';
import '../../products/data/models/product_model.dart';
import '../data/cart_repository.dart';
import '../data/models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(const CartState());

  void initializeForUser(String userId) {
    if (userId.isEmpty) {
      emit(const CartState());
      return;
    }
    final items = _cartRepository.getUserCart(userId);
    emit(CartState(items: items, userId: userId));
  }

  Future<void> addToCart(ProductModel product, [int quantity = 1]) async {
    final currentUserId = state.userId;
    final currentItems = List<CartItemModel>.from(state.items);

    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existingItem = currentItems[existingIndex];
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      currentItems.add(CartItemModel(
        product: product,
        quantity: quantity,
      ));
    }

    emit(state.copyWith(items: currentItems));
    if (currentUserId.isNotEmpty) {
      await _cartRepository.saveUserCart(currentUserId, currentItems);
    }
  }

  Future<void> incrementQuantity(int productId) async {
    final currentUserId = state.userId;
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final item = currentItems[index];
      currentItems[index] = item.copyWith(quantity: item.quantity + 1);
      emit(state.copyWith(items: currentItems));
      if (currentUserId.isNotEmpty) {
        await _cartRepository.saveUserCart(currentUserId, currentItems);
      }
    }
  }

  Future<void> decrementQuantity(int productId) async {
    final currentUserId = state.userId;
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final item = currentItems[index];
      if (item.quantity > 1) {
        currentItems[index] = item.copyWith(quantity: item.quantity - 1);
      } else {
        currentItems.removeAt(index);
      }
      emit(state.copyWith(items: currentItems));
      if (currentUserId.isNotEmpty) {
        await _cartRepository.saveUserCart(currentUserId, currentItems);
      }
    }
  }

  Future<void> removeFromCart(int productId) async {
    final currentUserId = state.userId;
    final currentItems = List<CartItemModel>.from(state.items)
      ..removeWhere((item) => item.product.id == productId);

    emit(state.copyWith(items: currentItems));
    if (currentUserId.isNotEmpty) {
      await _cartRepository.saveUserCart(currentUserId, currentItems);
    }
  }

  Future<void> clearCart() async {
    final currentUserId = state.userId;
    emit(state.copyWith(items: const []));
    if (currentUserId.isNotEmpty) {
      await _cartRepository.clearUserCart(currentUserId);
    }
  }
}
