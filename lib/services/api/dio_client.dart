import 'package:dio/dio.dart';
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
    baseUrl: 'http://localhost:8000/',  // ← 여러분 백엔드 주소
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
    contentType: 'application/json',
  )) {
    // 로깅 인터셉터
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // 글로벌 401 처리 및 토큰 초기화
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          final status = e.response?.statusCode;
          if (status == 401) {
            // 로컬 토큰 삭제
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
            // 로그인 화면으로 이동
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
            );
          }
          // 기존 에러 래핑
          final msg = e.response?.statusMessage ?? e.message;
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: ApiException("통신 오류: $msg"),
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> request(String path, { Options? options, dynamic data }) async {
    final resp = await _dio.request(path, data: data, options: options);
    if (resp.statusCode != 200) {
      throw ApiException("서버 오류: ${resp.statusCode}");
    }
    return resp;
  }
}