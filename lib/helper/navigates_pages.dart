import 'package:flutter/material.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/post_page.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:provider/provider.dart';

import '../pages/profile_page.dart';

/// 유저(오시) 페이지로 이동
void goUserPage(BuildContext context, String tweetId) {
  final oshiProvider = Provider.of<OshiProvider>(context, listen: false);
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: ProfilePage.routeName),
      builder: (context) => OshiProfilePage(),
    ),
  );
}

/// 포스트 페이지로 이동
void goPostPage(BuildContext context, Post post) {
  final oshiProvider = Provider.of<OshiProvider>(context, listen: false);
  Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: PostPage.routeName),
      builder: (context) => PostPage(
        post: post,
        oshiProvider: oshiProvider,
      ),
    ),
  );
}