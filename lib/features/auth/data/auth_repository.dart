import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/services/storage_service.dart';
import 'models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthRepository({
    required this.apiClient,
    required this.storageService,
  });

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'username': username.trim(),
          'password': password.trim(),
        },
      );

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      await storageService.saveToken(user.token);
      await storageService.saveUser(user.toJson());
      return user;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An unexpected login error occurred: ${e.toString()}');
    }
  }

  UserModel? getCachedUser() {
    final map = storageService.getUser();
    final token = storageService.getToken();
    if (map != null && token != null && token.isNotEmpty) {
      return UserModel.fromJson(map);
    }
    return null;
  }

  Future<void> logout() async {
    await storageService.clearSession();
  }
}
