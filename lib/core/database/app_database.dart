import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/cart/data/models/cart_item_model.dart';
import '../../features/products/data/models/product_model.dart';

/// Production-ready SQLite Database Helper for local offline caching & relational persistence
class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ecommerce_store.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Products Table (Offline catalog caching & SQL filtering)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        discountPercentage REAL,
        rating REAL,
        stock INTEGER,
        brand TEXT,
        thumbnail TEXT,
        images TEXT,
        warrantyInformation TEXT,
        shippingInformation TEXT,
        returnPolicy TEXT
      )
    ''');

    // 2. Cart Items Table (Multi-user isolated cart persistence)
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        product_json TEXT NOT NULL,
        UNIQUE(user_id, product_id) ON CONFLICT REPLACE
      )
    ''');

    // 3. Wishlist Items Table (Multi-user isolated wishlist persistence)
    await db.execute('''
      CREATE TABLE wishlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        product_json TEXT NOT NULL,
        UNIQUE(user_id, product_id) ON CONFLICT REPLACE
      )
    ''');
  }

  // ==================== PRODUCTS CRUD ====================

  Future<void> insertOrUpdateProducts(List<ProductModel> products) async {
    final db = await database;
    final batch = db.batch();
    for (final p in products) {
      batch.insert(
        'products',
        p.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id ASC');
    if (maps.isEmpty) return [];
    return maps.map((m) => ProductModel.fromSqliteMap(m)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'title LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => ProductModel.fromSqliteMap(m)).toList();
  }

  // ==================== CART CRUD (USER ISOLATED) ====================

  Future<void> saveUserCart(String userId, List<CartItemModel> items) async {
    final db = await database;
    final batch = db.batch();

    // Clear previous items for this user
    batch.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);

    // Insert updated items
    for (final item in items) {
      batch.insert('cart_items', {
        'user_id': userId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'product_json': jsonEncode(item.product.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<CartItemModel>> getUserCart(String userId) async {
    final db = await database;
    final maps = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((row) {
      final productMap = jsonDecode(row['product_json'] as String) as Map<String, dynamic>;
      return CartItemModel(
        product: ProductModel.fromJson(productMap),
        quantity: row['quantity'] as int? ?? 1,
      );
    }).toList();
  }

  Future<void> clearUserCart(String userId) async {
    final db = await database;
    await db.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ==================== WISHLIST CRUD (USER ISOLATED) ====================

  Future<void> saveUserWishlist(String userId, List<ProductModel> items) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('wishlist_items', where: 'user_id = ?', whereArgs: [userId]);

    for (final item in items) {
      batch.insert('wishlist_items', {
        'user_id': userId,
        'product_id': item.id,
        'product_json': jsonEncode(item.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<ProductModel>> getUserWishlist(String userId) async {
    final db = await database;
    final maps = await db.query(
      'wishlist_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((row) {
      final productMap = jsonDecode(row['product_json'] as String) as Map<String, dynamic>;
      return ProductModel.fromJson(productMap);
    }).toList();
  }

  Future<void> clearUserWishlist(String userId) async {
    final db = await database;
    await db.delete('wishlist_items', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
