import '../../../core/database/app_database.dart';
import '../../../core/services/storage_service.dart';
import 'models/cart_item_model.dart';

class CartRepository {
  final StorageService storageService;
  final AppDatabase? database;

  CartRepository({
    required this.storageService,
    this.database,
  });

  List<CartItemModel> getUserCart(String userId) {
    if (userId.isEmpty) return [];
    final jsonList = storageService.getUserCart(userId);
    return jsonList.map((item) => CartItemModel.fromJson(item)).toList();
  }

  Future<void> saveUserCart(String userId, List<CartItemModel> items) async {
    if (userId.isEmpty) return;
    final jsonList = items.map((item) => item.toJson()).toList();
    await storageService.saveUserCart(userId, jsonList);
    // Persist to SQLite relational table
    final db = database ?? AppDatabase.instance;
    await db.saveUserCart(userId, items);
  }

  Future<void> clearUserCart(String userId) async {
    if (userId.isEmpty) return;
    await storageService.clearUserCart(userId);
    final db = database ?? AppDatabase.instance;
    await db.clearUserCart(userId);
  }
}
