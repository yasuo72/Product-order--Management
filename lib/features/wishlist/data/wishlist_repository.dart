import '../../../core/database/app_database.dart';
import '../../../core/services/storage_service.dart';
import '../../products/data/models/product_model.dart';

class WishlistRepository {
  final StorageService storageService;
  final AppDatabase? database;

  WishlistRepository({
    required this.storageService,
    this.database,
  });

  List<ProductModel> getUserWishlist(String userId) {
    if (userId.isEmpty) return [];
    final jsonList = storageService.getUserWishlist(userId);
    return jsonList.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<void> saveUserWishlist(String userId, List<ProductModel> items) async {
    if (userId.isEmpty) return;
    final jsonList = items.map((item) => item.toJson()).toList();
    await storageService.saveUserWishlist(userId, jsonList);
    // Persist to SQLite relational table
    final db = database ?? AppDatabase.instance;
    await db.saveUserWishlist(userId, items);
  }

  Future<void> clearUserWishlist(String userId) async {
    if (userId.isEmpty) return;
    await storageService.clearUserWishlist(userId);
    final db = database ?? AppDatabase.instance;
    await db.clearUserWishlist(userId);
  }
}
