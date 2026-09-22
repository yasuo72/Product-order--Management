import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/products/data/product_repository.dart';
import 'features/wishlist/data/wishlist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences & SQLite Database
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);
  final database = AppDatabase.instance;

  // Initialize Network & Services
  final apiClient = ApiClient(storageService: storageService);
  final connectivityService = ConnectivityService();

  // Initialize Repositories (Wired with both StorageService & SQLite)
  final authRepository = AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
  );
  final productRepository = ProductRepository(
    apiClient: apiClient,
    storageService: storageService,
    database: database,
  );
  final cartRepository = CartRepository(
    storageService: storageService,
    database: database,
  );
  final wishlistRepository = WishlistRepository(
    storageService: storageService,
    database: database,
  );

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
