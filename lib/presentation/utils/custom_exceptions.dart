/// 네트워크/HTTP 오류를 Flutter 쪽에서 명확히 구분하기 위한 커스텀 예외들

/// 400 Bad Request
class BadRequestException implements Exception {
  final String message;
  BadRequestException([this.message = "잘못된 요청입니다."]);
  @override
  String toString() => "BadRequestException: $message";
}

/// 401 Unauthorized
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "권한이 없습니다."]);
  @override
  String toString() => "UnauthorizedException: $message";
}

/// 404 Not Found
class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = "찾을 수 없습니다."]);
  @override
  String toString() => "NotFoundException: $message";
}

/// 409 Conflict
class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = "중복된 요청입니다."]);
  @override
  String toString() => "ConflictException: $message";
}

/// 500 이상 네트워크/서버 오류
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "서버와의 통신 중 오류가 발생했습니다."]);
  @override
  String toString() => "NetworkException: $message";
}