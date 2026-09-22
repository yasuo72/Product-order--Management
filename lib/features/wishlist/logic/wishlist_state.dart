import 'package:equatable/equatable.dart';
import '../../products/data/models/product_model.dart';

class WishlistState extends Equatable {
  final List<ProductModel> items;
  final String userId;

  const WishlistState({
    this.items = const [],
    this.userId = '',
  });

  bool isFavorite(int productId) {
    return items.any((item) => item.id == productId);
  }

  WishlistState copyWith({
    List<ProductModel>? items,
    String? userId,
  }) {
    return WishlistState(
      items: items ?? this.items,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [items, userId];
}
