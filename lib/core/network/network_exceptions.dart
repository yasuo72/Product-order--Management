import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  factory AppException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException('Connection timed out. Please check your internet connection.', dioException.response?.statusCode);
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final data = dioException.response?.data;
        String message = 'Received invalid status code: $statusCode';
        if (data is Map<String, dynamic> && data['message'] != null) {
          message = data['message'].toString();
        } else if (statusCode == 400) {
          message = 'Bad request. Please verify your input.';
        } else if (statusCode == 401) {
          message = 'Invalid credentials or session expired.';
        } else if (statusCode == 403) {
          message = 'Access forbidden.';
        } else if (statusCode == 404) {
          message = 'Requested resource was not found.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server encountered an error. Please try again later.';
        }
        return AppException(message, statusCode);
      case DioExceptionType.cancel:
        return AppException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return AppException('No internet connection. Please verify your network and retry.');
      case DioExceptionType.badCertificate:
        return AppException('Security certificate verification failed.');
      case DioExceptionType.unknown:
      default:
        if (dioException.message != null && dioException.message!.contains('SocketException')) {
          return AppException('Unable to reach server. Please check your internet connection.');
        }
        return AppException('An unexpected error occurred. Please try again.');
    }
  }

  @override
  String toString() => message;
}
