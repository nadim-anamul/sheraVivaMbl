import 'package:dio/dio.dart';

import 'api_config.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio(_baseOptions);

  final Dio _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
