import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_order_app/features/cart/data/cart_repository.dart';
import 'package:product_order_app/features/cart/data/models/cart_item_model.dart';
import 'package:product_order_app/features/cart/logic/cart_cubit.dart';
import 'package:product_order_app/features/products/data/models/product_model.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late CartRepository mockRepository;
  late CartCubit cartCubit;

  const sampleProduct = ProductModel(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    description: 'Popular mascara',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 10.0,
    rating: 4.9,
    stock: 25,
    brand: 'Essence',
    images: ['https://dummyjson.com/image.png'],
    thumbnail: 'https://dummyjson.com/thumb.png',
  );

  setUp(() {
    mockRepository = MockCartRepository();
    when(() => mockRepository.getUserCart(any())).thenReturn([]);
    when(() => mockRepository.saveUserCart(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.clearUserCart(any())).thenAnswer((_) async {});
    cartCubit = CartCubit(mockRepository);
  });

  tearDown(() {
    cartCubit.close();
  });

  group('CartCubit Tests', () {
    test('initial state has empty items', () {
      expect(cartCubit.state.items, isEmpty);
      expect(cartCubit.state.totalQuantity, 0);
      expect(cartCubit.state.totalAmount, 0.0);
    });

    test('initializeForUser sets userId and loads cached items', () {
      final cachedItems = [
        const CartItemModel(product: sampleProduct, quantity: 2),
      ];
      when(() => mockRepository.getUserCart('emilys')).thenReturn(cachedItems);

      cartCubit.initializeForUser('emilys');

      expect(cartCubit.state.userId, 'emilys');
      expect(cartCubit.state.items.length, 1);
      expect(cartCubit.state.totalQuantity, 2);
    });

    test('addToCart adds new item and saves to user repository', () async {
      cartCubit.initializeForUser('emilys');

      await cartCubit.addToCart(sampleProduct);

      expect(cartCubit.state.items.length, 1);
      expect(cartCubit.state.items.first.product.id, sampleProduct.id);
      expect(cartCubit.state.items.first.quantity, 1);
      verify(() => mockRepository.saveUserCart('emilys', any())).called(1);
    });

    test('addToCart increments quantity when item already in cart', () async {
      cartCubit.initializeForUser('emilys');

      await cartCubit.addToCart(sampleProduct);
      await cartCubit.addToCart(sampleProduct);

      expect(cartCubit.state.items.length, 1);
      expect(cartCubit.state.items.first.quantity, 2);
    });

    test('incrementQuantity and decrementQuantity update count', () async {
      cartCubit.initializeForUser('emilys');

      await cartCubit.addToCart(sampleProduct, 2);
      expect(cartCubit.state.items.first.quantity, 2);

      await cartCubit.incrementQuantity(sampleProduct.id);
      expect(cartCubit.state.items.first.quantity, 3);

      await cartCubit.decrementQuantity(sampleProduct.id);
      expect(cartCubit.state.items.first.quantity, 2);
    });

    test('decrementQuantity removes item when count reaches 0', () async {
      cartCubit.initializeForUser('emilys');

      await cartCubit.addToCart(sampleProduct, 1);
      expect(cartCubit.state.items.length, 1);

      await cartCubit.decrementQuantity(sampleProduct.id);
      expect(cartCubit.state.items, isEmpty);
    });

    test('clearCart empties items and invokes clear on repository', () async {
      cartCubit.initializeForUser('emilys');
      await cartCubit.addToCart(sampleProduct);

      await cartCubit.clearCart();

      expect(cartCubit.state.items, isEmpty);
      verify(() => mockRepository.clearUserCart('emilys')).called(1);
    });
  });
}
