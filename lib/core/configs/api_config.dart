import 'dart:io';

/// API 서버의 호스트 주소와 기본 경로를 관리하는 설정 클래스
class ApiConfig {
  static final String host =
  Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';

  /// API 엔드포인트의 기본 경로
  static const String apiBase = '/api';
}