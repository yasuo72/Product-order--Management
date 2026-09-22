import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../services/storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    required StorageService storageService,
    void Function()? onUnauthorized,
  }) : dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.addAll([
      AuthInterceptor(
        storageService: storageService,
        onUnauthorized: onUnauthorized,
      ),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }
}
