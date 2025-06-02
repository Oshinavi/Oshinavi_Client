import 'package:flutter/material.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/core/navigator/navigation_service.dart';
import 'package:mediaproject/presentation/views/auth/auth_gate_page.dart';

/// 전역 예외 처리 및 JWT/쿠키 관리가 포함된 Dio 클라이언트 싱글톤
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient._internal() {
    _dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:8000',
          connectTimeout: const Duration(milliseconds: 50000),
          receiveTimeout: const Duration(milliseconds: 300000),
          sendTimeout: const Duration(milliseconds: 50000),
          contentType: 'application/json',
        )
    );

    // 1) 쿠키 저장소 설정: 리프레시 토큰을 쿠키로 관리
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
    _dio.interceptors.add(
      LogInterceptor(request: true, requestBody: true, responseBody: true, error: true),
    );

    // 4) 401 에러 전역 처리: Access Token 만료 시 Refresh 시도
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;
          if (status == 401) {
            // 액세스 토큰 만료 시 리프레시 토큰으로 갱신 시도
            try {
              final refreshResp = await _dio.post(
                '/auth/refresh',
                options: Options(extra: {'skipAuth': true}),
              );
              if (refreshResp.statusCode == 200) {
                // 재발급 성공 → 실패한 요청 다시 시도
                final opts = error.requestOptions;
                final retry = await _dio.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(method: opts.method, headers: opts.headers),
                );
                return handler.resolve(retry);
              }
            } catch (_) {
              // 리프레시 실패 시 흐름 계속
            }

            // 최종 실패: 로컬 저장소 토큰 삭제 & 로그인 화면 강제 이동
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
            final navKey = NavigationService().key;
            if (navKey.currentState != null) {
              navKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthGatePage()),
              );
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Dio 인스턴스 반환
  Dio get dio => _dio;

  /// 일반적인 HTTP 요청 래퍼
  /// - path: API 경로
  /// - data: request body
  /// - options: Dio 옵션
  /// - 반환: Response, HTTP 200/201이 아닌 경우 ApiException 던짐
  Future<Response> request(
      String path, {
        Options? options,
        dynamic data,
      }) async {
    final response = await _dio.request(path, data: data, options: options);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException("서버 오류: ${response.statusCode}");
    }
    return response;
  }
}