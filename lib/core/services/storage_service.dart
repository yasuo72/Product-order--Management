import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyAuthToken = 'auth_token';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyDarkMode = 'is_dark_mode';

  // --- Auth Token ---
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyAuthToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyAuthToken);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(_keyAuthToken);
  }

  // --- Current User Profile ---
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    return await _prefs.setString(_keyCurrentUser, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUser() async {
    return await _prefs.remove(_keyCurrentUser);
  }

  // --- User-Isolated Cart Management ---
  // Guarantees cart isolation per user as required by PDF 2
  String _cartKey(String userId) => 'cart_user_$userId';

  Future<bool> saveUserCart(String userId, List<Map<String, dynamic>> items) async {
    return await _prefs.setString(_cartKey(userId), jsonEncode(items));
  }

  List<Map<String, dynamic>> getUserCart(String userId) {
    final raw = _prefs.getString(_cartKey(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> clearUserCart(String userId) async {
    return await _prefs.remove(_cartKey(userId));
  }

  // --- User-Isolated Wishlist Management ---
  // Guarantees wishlist isolation per user as required by PDF 2
  String _wishlistKey(String userId) => 'wishlist_user_$userId';

  Future<bool> saveUserWishlist(String userId, List<Map<String, dynamic>> items) async {
    return await _prefs.setString(_wishlistKey(userId), jsonEncode(items));
  }

  List<Map<String, dynamic>> getUserWishlist(String userId) {
    final raw = _prefs.getString(_wishlistKey(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> clearUserWishlist(String userId) async {
    return await _prefs.remove(_wishlistKey(userId));
  }

  // --- Theme Mode ---
  Future<bool> saveDarkMode(bool isDark) async {
    return await _prefs.setBool(_keyDarkMode, isDark);
  }

  bool isDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  // --- Offline Product Caching ---
  static const String _keyCachedProducts = 'cached_products';

  Future<bool> saveCachedProducts(List<Map<String, dynamic>> products) async {
    return await _prefs.setString(_keyCachedProducts, jsonEncode(products));
  }

  List<Map<String, dynamic>> getCachedProducts() {
    final raw = _prefs.getString(_keyCachedProducts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  // Full Session Reset
  Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }
}
