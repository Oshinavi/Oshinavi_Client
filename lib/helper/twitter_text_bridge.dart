import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

class TwitterTextBridgeController {
  late InAppWebViewController _controller;
  bool _isLoaded = false;

  Future<Widget> buildBridgeWidget() async {
    final html = await rootBundle.loadString("assets/js/twitter_text_bridge.html");
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: html),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStop: (_, __) {
        _isLoaded = true;
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          transparentBackground: true,
          javaScriptEnabled: true,
        ),
      ),
    );
  }

  Future<int> calculateLength(String text) async {
    if (!_isLoaded || _controller == null) {
      print("⚠️ WebView not ready yet. Returning 0.");
      return 0;
    }

    try {
      final result = await _controller.evaluateJavascript(
        source: "getTweetLength(${jsonEncode(text)});",
      );
      return int.tryParse(result.toString()) ?? 0;
    } catch (e) {
      print("⚠️ Error during JS evaluation: $e");
      return 0;
    }
  }
}