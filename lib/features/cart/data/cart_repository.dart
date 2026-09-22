import '../../../core/services/storage_service.dart';
import 'models/cart_item_model.dart';

class CartRepository {
  final StorageService storageService;

  CartRepository({required this.storageService});

  List<CartItemModel> getUserCart(String userId) {
    if (userId.isEmpty) return [];
    final jsonList = storageService.getUserCart(userId);
    return jsonList.map((item) => CartItemModel.fromJson(item)).toList();
  }

  Future<void> saveUserCart(String userId, List<CartItemModel> items) async {
    if (userId.isEmpty) return;
    final jsonList = items.map((item) => item.toJson()).toList();
    await storageService.saveUserCart(userId, jsonList);
  }

  Future<void> clearUserCart(String userId) async {
    if (userId.isEmpty) return;
    await storageService.clearUserCart(userId);
  }
}
