import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
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
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}