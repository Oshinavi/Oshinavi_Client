int twitterWeightedLength(String text) {
  int total = 0;
  for (var rune in text.runes) {
    if (_isCJK(rune)) {
      total += 2;
    } else {
      total += 1;
    }
  }
  return total;
}

bool _isCJK(int rune) {
  return (rune >= 0x4E00 && rune <= 0x9FFF) || // CJK Unified Ideographs
      (rune >= 0x3400 && rune <= 0x4DBF) || // CJK Extension A
      (rune >= 0x3040 && rune <= 0x309F) || // Hiragana
      (rune >= 0x30A0 && rune <= 0x30FF) || // Katakana
      (rune >= 0xAC00 && rune <= 0xD7AF);   // Hangul Syllables
}