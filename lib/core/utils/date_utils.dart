import 'package:intl/intl.dart';

/// 날짜/시간 관련 형식 변환 유틸리티 클래스
class DateUtils {
  /// 'yyyy-MM-dd HH:mm:ss' 형태의 문자열을 DateTime으로 파싱
  static DateTime parseIso(String s) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(s);
  }

  /// DateTime을 'yyyy.MM.dd HH:mm' 형태의 문자열로 포맷
  static String formatForUI(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd HH:mm').format(dateTime);
  }
}