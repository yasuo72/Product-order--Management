import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/services/storage_service.dart';
import 'models/product_model.dart';

class ProductsResult {
  final List<ProductModel> products;
  final int total;

  const ProductsResult({required this.products, required this.total});
}

class ProductRepository {
  final ApiClient apiClient;
  final StorageService? storageService;

  ProductRepository({
    required this.apiClient,
    this.storageService,
  });

  List<ProductModel> getOfflineCachedProducts() {
    if (storageService == null) return [];
    final cached = storageService!.getCachedProducts();
    return cached.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<ProductsResult> getProducts({
    int limit = 10,
    int skip = 0,
    String? category,
    String? searchQuery,
  }) async {
    final isDefaultCatalog = skip == 0 &&
        (searchQuery == null || searchQuery.trim().isEmpty) &&
        (category == null || category.isEmpty || category.toLowerCase() == 'all');

    try {
      String endpoint = ApiEndpoints.products;
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'skip': skip,
      };

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        endpoint = ApiEndpoints.searchProducts;
        queryParams['q'] = searchQuery.trim();
      } else if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        endpoint = ApiEndpoints.productsByCategory(category);
      }

      final response = await apiClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final rawList = data['products'] as List<dynamic>? ?? [];
      final total = (data['total'] as num?)?.toInt() ?? rawList.length;

      final products = rawList
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Cache default catalog for offline availability
      if (isDefaultCatalog && storageService != null) {
        await storageService!.saveCachedProducts(
          products.map((p) => p.toJson()).toList(),
        );
      }

      return ProductsResult(products: products, total: total);
    } on DioException catch (e) {
      // If network fails on default catalog, attempt to serve offline cache
      if (isDefaultCatalog && storageService != null) {
        final cached = getOfflineCachedProducts();
        if (cached.isNotEmpty) {
          return ProductsResult(products: cached, total: cached.length);
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      if (isDefaultCatalog && storageService != null) {
        final cached = getOfflineCachedProducts();
        if (cached.isNotEmpty) {
          return ProductsResult(products: cached, total: cached.length);
        }
      }
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch products: ${e.toString()}');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.categories);
      final raw = response.data;
      List<String> categories = ['All'];

      if (raw is List) {
        for (var item in raw) {
          if (item is String) {
            categories.add(item);
          } else if (item is Map<String, dynamic>) {
            final slug = item['slug'] ?? item['name'];
            if (slug != null) {
              categories.add(slug.toString());
            }
          }
        }
      }
      return categories;
    } catch (_) {
      return ['All', 'beauty', 'fragrances', 'furniture', 'groceries'];
    }
  }

  Future<ProductModel> getProductDetail(int id) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.productDetail(id));
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to fetch product details: ${e.toString()}');
    }
  }
}
