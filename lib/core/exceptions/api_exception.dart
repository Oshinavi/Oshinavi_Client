/// 모든 API 예외의 최상위 클래스
/// - 서버에서 내려온 메시지를 담고, HTTP 상태 코드별로 세부 예외 구현
abstract class ApiException implements Exception {
  /// 사용자에게 보여줄 오류 메시지
  final String message;

  ApiException(this.message);

  @override
  String toString() => "ApiException: $message";
}

/// 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException([String message = "잘못된 요청입니다."]) : super(message);
}

/// 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = "권한이 없습니다."]) : super(message);
}

/// 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException([String message = "찾을 수 없습니다."]) : super(message);
}

/// 409 Conflict
class ConflictException extends ApiException {
  ConflictException([String message = "중복된 요청입니다."]) : super(message);
}

/// 500 이상 서버 에러 및 기타 알 수 없는 오류
class ServerException extends ApiException {
  ServerException([String message = "서버와의 통신 중 오류가 발생했습니다."]) : super(message);
}