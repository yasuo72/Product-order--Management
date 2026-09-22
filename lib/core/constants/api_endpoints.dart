class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';
  
  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String currentUser = '$baseUrl/auth/me';

  // Products
  static const String products = '$baseUrl/products';
  static String productDetail(int id) => '$baseUrl/products/$id';
  static const String searchProducts = '$baseUrl/products/search';
  static const String categories = '$baseUrl/products/categories';
  static String productsByCategory(String category) => '$baseUrl/products/category/$category';
}
