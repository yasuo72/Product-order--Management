import 'package:equatable/equatable.dart';
import '../data/models/cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItemModel> items;
  final bool isLoading;
  final String userId;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.userId = '',
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    final sum = items.fold(0.0, (acc, item) => acc + item.totalPrice);
    return double.parse(sum.toStringAsFixed(2));
  }

  double get originalTotal {
    final sum = items.fold(0.0, (acc, item) => acc + (item.product.price * item.quantity));
    return double.parse(sum.toStringAsFixed(2));
  }

  double get totalSavings {
    final savings = originalTotal - subtotal;
    return savings > 0 ? double.parse(savings.toStringAsFixed(2)) : 0.0;
  }

  double get shippingFee => items.isEmpty ? 0.0 : 4.99;

  double get totalAmount {
    if (items.isEmpty) return 0.0;
    return double.parse((subtotal + shippingFee).toStringAsFixed(2));
  }

  bool isInCart(int productId) {
    return items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(int productId) {
    final item = items.where((element) => element.product.id == productId);
    return item.isNotEmpty ? item.first.quantity : 0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? userId,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, userId];
}
