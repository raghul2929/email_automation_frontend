
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/storage_helper.dart';

class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  // ✅ Expose dio instance
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        headers: {
          'Content-Type': ApiConstants.contentTypeJson,
        },
      ),
    );

    // Add Interceptor for JWT Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Get token and add detailed logging
          final token = await StorageHelper.getToken();
          
          _logger.d('🔍 Request: ${options.method} ${options.path}');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d('🔑 JWT token added (length: ${token.length})');
            _logger.d('🔑 Token preview: ${token.substring(0, 20)}...');
          } else {
            _logger.w('⚠️ No JWT token found in storage!');
            _logger.w('⚠️ Request will be sent without authentication');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('✅ Response: ${response.statusCode}');
          // Don't log full response data to avoid clutter
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('❌ Error: ${error.response?.statusCode} - ${error.message}');
          
          // ✅ Special handling for 401
          if (error.response?.statusCode == 401) {
            _logger.e('❌ UNAUTHORIZED! Token is missing or invalid');
            
            // Check if token exists
            final token = await StorageHelper.getToken();
            if (token == null) {
              _logger.e('❌ No token in storage - user needs to login');
            } else {
              _logger.e('❌ Token exists but is invalid - may be expired');
              _logger.e('❌ Token: ${token.substring(0, 20)}...');
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      rethrow;
    }
  }

  // Upload File (Multipart)
  Future<Response> uploadFile(String endpoint, String filePath) async {
    try {
      _logger.d('📤 Uploading file: $filePath');
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: ApiConstants.contentTypeMultipart,
        ),
      );
    } catch (e) {
      _logger.e('📤 Upload failed: $e');
      rethrow;
    }
  }
}
