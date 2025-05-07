import 'package:flutter/material.dart';

class ColorGenerator {
  static const _availableColors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrangeAccent,
    Colors.indigoAccent,
    Colors.lightGreen,
    Colors.lime,
    Colors.pinkAccent,
    Colors.yellowAccent,
  ];

  final Map<String, Color> _colorMap = {};

  /// 초기화 함수가 필요하다면 여기에 정의
  Future<void> init() async {
    return;
  }

  /// Java 스타일의 안정적인 문자열 해시 함수
  int _stableHash(String s) {
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = (31 * hash + s.codeUnitAt(i)) & 0x7fffffff; // 부호 없는 32bit
    }
    return hash;
  }

  /// 문자열 key를 기반으로 고유한 색상 반환
  Color getColor(String key) {
    if (_colorMap.containsKey(key)) return _colorMap[key]!;

    int index = _stableHash(key) % _availableColors.length;
    final color = _availableColors[index];
    _colorMap[key] = color;

    return color;
  }
}