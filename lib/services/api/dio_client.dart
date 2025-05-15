import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/services/auth/auth_gate.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient._internal()
      : _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
    contentType: 'application/json',
  )) {
    // 1) 쿠키 저장소 (쿠키 기반 리프레시 토큰 전송을 위해)
    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));

    // 2) 요청마다 JWT 자동 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // 3) 로깅 인터셉터
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // 4) 401 에러 전역 처리 (액세스 토큰 만료 시 리프레시 시도)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          final status = e.response?.statusCode;
          // access token expired
          if (status == 401) {
            // 1) 저장된 리프레시 토큰 쿠키가 있으면 서버 호출로 재발급 시도
            try {
              final refreshResp = await _dio.post(
                '/auth/refresh',
                options: Options(extra: {'skipAuth': true}),
              );
              if (refreshResp.statusCode == 200) {
                // 토큰은 쿠키로 설정되므로, 이후 요청에는 자동으로 쿠키가 실립니다.
                // 실패했던 요청 재시도
                final opts = e.requestOptions;
                final cloneReq = await _dio.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                );
                return handler.resolve(cloneReq);
              }
            } catch (_) {
              // 리프레시 실패
            }
            // 2) 리프레시도 실패했으면 로컬 토큰 삭제 및 로그인 화면으로 이동
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (_) => const AuthGate()),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> request(
      String path, {
        Options? options,
        dynamic data,
      }) async {
    final resp = await _dio.request(path, data: data, options: options);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException("서버 오류: ${resp.statusCode}");
    }
    return resp;
  }
}