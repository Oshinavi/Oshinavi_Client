import 'package:flutter/material.dart';

/// 문자열 키를 바탕으로 일관된 Color를 리턴하는 유틸리티 클래스
/// - 동일한 키가 들어오면 항상 같은 색상 인덱스가 반환됨
class ColorGenerator {
  /// 사용 가능한 색상 목록
  static const List<Color> _availableColors = [
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

  /// 키→Color 매핑 저장용 캐시
  final Map<String, Color> _colorMap = {};

  /// 안정적인 문자열 해시 코드 계산 (음수가 없도록 양수 제한)
  int _stableHash(String s) {
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = (31 * hash + s.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }

  /// 주어진 키로 매핑된 색상을 반환
  /// - 캐시에 없다면 해시를 통해 새 색상을 선택하고 캐시에 저장
  Color getColor(String key) {
    if (_colorMap.containsKey(key)) return _colorMap[key]!;

    final index = _stableHash(key) % _availableColors.length;
    final color = _availableColors[index];
    _colorMap[key] = color;
    return color;
  }
}