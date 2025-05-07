import 'dart:io';

class ApiConfig {
  static final String host =
  Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
  static const String api  = '/api';
}