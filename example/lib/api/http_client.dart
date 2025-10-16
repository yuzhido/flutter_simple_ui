import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:example/utils/config.dart';

/// HTTP 客户端封装
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  /// GET 请求
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http.get(uri, headers: Config.headers).timeout(Duration(milliseconds: Config.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http.post(uri, headers: Config.headers, body: body != null ? jsonEncode(body) : null).timeout(Duration(milliseconds: Config.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http.put(uri, headers: Config.headers, body: body != null ? jsonEncode(body) : null).timeout(Duration(milliseconds: Config.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Map<String, dynamic>> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await http.delete(uri, headers: Config.headers, body: body != null ? jsonEncode(body) : null).timeout(Duration(milliseconds: Config.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 构建 URI
  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('${Config.baseUrl}$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
    }
    return uri;
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = utf8.decode(response.bodyBytes);

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return jsonDecode(body);
      } catch (e) {
        throw ApiException('响应解析失败: $e');
      }
    } else {
      try {
        final errorData = jsonDecode(body);
        throw ApiException(errorData['message'] ?? '请求失败', statusCode: statusCode);
      } catch (e) {
        throw ApiException('请求失败 (状态码: $statusCode)', statusCode: statusCode);
      }
    }
  }

  /// 处理错误
  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return ApiException('网络连接失败，请检查网络设置');
    } else if (error is HttpException) {
      return ApiException('HTTP 请求失败: ${error.message}');
    } else {
      return ApiException('未知错误: $error');
    }
  }
}

/// API 异常类
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return statusCode != null ? 'ApiException: $message (状态码: $statusCode)' : 'ApiException: $message';
  }
}
