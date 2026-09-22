import '../../../core/services/storage_service.dart';
import '../../products/data/models/product_model.dart';

class WishlistRepository {
  final StorageService storageService;

  WishlistRepository({required this.storageService});

  List<ProductModel> getUserWishlist(String userId) {
    if (userId.isEmpty) return [];
    final jsonList = storageService.getUserWishlist(userId);
    return jsonList.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<void> saveUserWishlist(String userId, List<ProductModel> items) async {
    if (userId.isEmpty) return;
    final jsonList = items.map((item) => item.toJson()).toList();
    await storageService.saveUserWishlist(userId, jsonList);
  }

  Future<void> clearUserWishlist(String userId) async {
    if (userId.isEmpty) return;
    await storageService.clearUserWishlist(userId);
  }
}
