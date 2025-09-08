import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import '../services/token_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class AppDio {
  late Dio _dio;

  AppDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType, // استخدام contentType من BaseOptions
    ));
    _addHeaderToDio();
    
    _addLogger();
    _addTokenInterceptor();
  }                   

  _addHeaderToDio() {
    _dio.options.headers = {
      // لا نضيف Content-Type هنا لتجنب التكرار
    };
  }

  addTokenToHeader(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  _addLogger() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          if (options.path.contains('/posts')) {
            return false;
          }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );
  }

  _addTokenInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // قائمة الـ endpoints التي لا تحتاج token
          final authEndpoints = [
            '/users/login/',
            '/users/register/',
            '/users/forgot-password/',
            '/users/verify-forget-password/',
            '/users/reset-password/',
            '/users/request-otp/',
            '/users/resend-otp/',
            '/users/verify/',
            '/users/refresh/',
          ];
          
          final isAuthEndpoint = authEndpoints.any((endpoint) => 
            options.path.contains(endpoint));
          
          if (!isAuthEndpoint) {
            // التحقق من صلاحية الـ token قبل كل request
            final isTokenValid = await AuthService.refreshTokenIfNeeded();
            
            
            final token = await TokenService.getToken();
            if (kDebugMode) print('🔍 Token Interceptor - Token: $token');
            if (kDebugMode) print('🔍 Token Interceptor - Is token valid: $isTokenValid');
            
            if (token != null && token.isNotEmpty && isTokenValid) {
              options.headers['Authorization'] = 'Bearer $token';
              if (kDebugMode) print('🔍 Token Interceptor - Added token to headers');
            } else {
              if (kDebugMode) print('⚠️ Token Interceptor - No valid token found');
            }
          } else {
            if (kDebugMode) print('🔍 Token Interceptor - Auth endpoint, skipping token');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // التعامل مع timeout errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            if (kDebugMode) print('⏰ Connection timeout error: ${error.message}');
            if (kDebugMode) print('🔄 Request details: ${error.requestOptions.uri}');
            
            // إعادة محاولة للـ timeout errors (مرة واحدة فقط)
            if (error.requestOptions.extra['retry'] != true) {
              if (kDebugMode) print('🔄 Retrying request due to timeout...');
              error.requestOptions.extra['retry'] = true;
              
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (retryError) {
                if (kDebugMode) print('❌ Retry failed: $retryError');
                // الاستمرار مع الـ error الأصلي
              }
            }
          }
          
          if (error.response?.statusCode == 401) {
            if (kDebugMode) print('🚨 Token expired - attempting to refresh...');
            if (kDebugMode) print('🚨 Error details: ${error.response?.data}');
            
            // محاولة تجديد الـ token
            final refreshSuccess = await AuthService.refreshToken();
            
            if (refreshSuccess) {
              if (kDebugMode) print('✅ Token refreshed successfully, retrying request...');
              
              // إعادة إرسال الـ request مع الـ token الجديد
              final newToken = await TokenService.getToken();
              if (newToken != null && newToken.isNotEmpty) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                
                // إعادة إرسال الـ request
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                  return;
                } catch (retryError) {
                  if (kDebugMode) print('❌ Retry request failed: $retryError');
                  handler.next(error);
                  return;
                }
              }
            } else {
              if (kDebugMode) print('❌ Token refresh failed, clearing auth data');
              if (kDebugMode) print('🔄 User will be redirected to login screen');
              await TokenService.clearToken();
              
              // الانتقال التلقائي لشاشة تسجيل الدخول
              NavigationService.navigateToLoginFromAnywhere();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
