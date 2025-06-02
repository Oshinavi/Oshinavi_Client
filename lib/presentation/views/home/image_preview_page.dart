import 'package:flutter/material.dart';

/// ImagePreviewPage:
/// - 전체 화면에서 이미지를 확대/축소하여 볼 수 있는 페이지
/// - Hero 위젯으로 네비게이션 애니메이션 지원
/// 인자:
/// - imageUrl: 표시할 이미지의 URL
/// - tag: Hero 애니메이션용 태그
class ImagePreviewPage extends StatelessWidget {
  static const String routeName = '/imagePreview';

  final String imageUrl;
  final String tag;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrl,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // 탭하면 뒤로가기
        child: Center(
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              child: Image.network(imageUrl), // 네트워크 이미지 표시
            ),
          ),
        ),
      ),
    );
  }
}