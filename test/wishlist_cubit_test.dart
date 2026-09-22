import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_order_app/features/products/data/models/product_model.dart';
import 'package:product_order_app/features/wishlist/data/wishlist_repository.dart';
import 'package:product_order_app/features/wishlist/logic/wishlist_cubit.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

void main() {
  late WishlistRepository mockRepository;
  late WishlistCubit wishlistCubit;

  const sampleProduct = ProductModel(
    id: 42,
    title: 'Wireless Headphones',
    description: 'Noise cancelling',
    category: 'electronics',
    price: 99.0,
    discountPercentage: 15.0,
    rating: 4.8,
    stock: 10,
    brand: 'AudioTech',
    images: ['https://dummyjson.com/hp.png'],
    thumbnail: 'https://dummyjson.com/hp_thumb.png',
  );

  setUp(() {
    mockRepository = MockWishlistRepository();
    when(() => mockRepository.getUserWishlist(any())).thenReturn([]);
    when(() => mockRepository.saveUserWishlist(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.clearUserWishlist(any())).thenAnswer((_) async {});
    wishlistCubit = WishlistCubit(mockRepository);
  });

  tearDown(() {
    wishlistCubit.close();
  });

  group('WishlistCubit Tests', () {
    test('initial state has empty items', () {
      expect(wishlistCubit.state.items, isEmpty);
      expect(wishlistCubit.state.isFavorite(sampleProduct.id), false);
    });

    test('toggleWishlist adds item when not present', () async {
      wishlistCubit.initializeForUser('emilys');

      await wishlistCubit.toggleWishlist(sampleProduct);

      expect(wishlistCubit.state.items.length, 1);
      expect(wishlistCubit.state.isFavorite(sampleProduct.id), true);
      verify(() => mockRepository.saveUserWishlist('emilys', any())).called(1);
    });

    test('toggleWishlist removes item when already present', () async {
      wishlistCubit.initializeForUser('emilys');

      await wishlistCubit.toggleWishlist(sampleProduct);
      expect(wishlistCubit.state.items.length, 1);

      await wishlistCubit.toggleWishlist(sampleProduct);
      expect(wishlistCubit.state.items, isEmpty);
      expect(wishlistCubit.state.isFavorite(sampleProduct.id), false);
    });

    test('removeFromWishlist removes target item', () async {
      wishlistCubit.initializeForUser('emilys');

      await wishlistCubit.toggleWishlist(sampleProduct);
      expect(wishlistCubit.state.items.length, 1);

      await wishlistCubit.removeFromWishlist(sampleProduct.id);
      expect(wishlistCubit.state.items, isEmpty);
    });
  });
}
