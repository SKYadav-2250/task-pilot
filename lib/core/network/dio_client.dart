import 'package:dio/dio.dart';
import 'package:task_mang/core/constants/api_constants.dart';
import 'package:task_mang/core/services/storage_service.dart';

class DioClient {
  final Dio dio;
  final StorageService storageService;

  DioClient({required this.dio, required this.storageService}) {
    dio
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.headers = {'Content-Type': 'application/json'};

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if exists
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors, e.g., token expiration
          if (e.response?.statusCode == 401) {
            // Unauthenticated
            storageService.clearUserData();
            // In a real app we might want to dispatch a logout event here
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await dio.post(url, data: data);
  }

  Future<Response> put(String url, {dynamic data}) async {
    return await dio.put(url, data: data);
  }

  Future<Response> delete(String url, {dynamic data}) async {
    return await dio.delete(url, data: data);
  }
}
