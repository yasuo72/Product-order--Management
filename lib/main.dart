import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/products/data/product_repository.dart';
import 'features/wishlist/data/wishlist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);

  // Initialize Network & Services
  final apiClient = ApiClient(storageService: storageService);
  final connectivityService = ConnectivityService();

  // Initialize Repositories
  final authRepository = AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
  final productRepository = ProductRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
  final cartRepository = CartRepository(storageService: storageService);
  final wishlistRepository = WishlistRepository(storageService: storageService);

  runApp(
    MyApp(
      storageService: storageService,
      connectivityService: connectivityService,
      authRepository: authRepository,
      productRepository: productRepository,
      cartRepository: cartRepository,
      wishlistRepository: wishlistRepository,
    ),
  );
}
