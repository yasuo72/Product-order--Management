import 'package:flutter_test/flutter_test.dart';
import 'package:product_order_app/features/products/data/models/product_model.dart';

void main() {
  group('SQLite Database Mapping Tests', () {
    const testProduct = ProductModel(
      id: 42,
      title: 'Gaming Laptop',
      description: 'High performance laptop',
      category: 'laptops',
      price: 1299.99,
      discountPercentage: 15.5,
      rating: 4.8,
      stock: 12,
      brand: 'Asus',
      images: ['https://example.com/1.png', 'https://example.com/2.png'],
      thumbnail: 'https://example.com/thumb.png',
      warrantyInformation: '2 year warranty',
      shippingInformation: 'Free next-day delivery',
      returnPolicy: '14 days return policy',
    );

    test('toSqliteMap correctly serializes product for SQLite columns', () {
      final map = testProduct.toSqliteMap();

      expect(map['id'], 42);
      expect(map['title'], 'Gaming Laptop');
      expect(map['category'], 'laptops');
      expect(map['price'], 1299.99);
      expect(map['images'], 'https://example.com/1.png,https://example.com/2.png');
      expect(map['brand'], 'Asus');
    });

    test('fromSqliteMap correctly deserializes SQLite row back into ProductModel', () {
      final map = testProduct.toSqliteMap();
      final restored = ProductModel.fromSqliteMap(map);

      expect(restored.id, 42);
      expect(restored.title, 'Gaming Laptop');
      expect(restored.category, 'laptops');
      expect(restored.price, 1299.99);
      expect(restored.discountPercentage, 15.5);
      expect(restored.rating, 4.8);
      expect(restored.stock, 12);
      expect(restored.brand, 'Asus');
      expect(restored.images.length, 2);
      expect(restored.thumbnail, 'https://example.com/thumb.png');
    });
  });
}
