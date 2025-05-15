import 'package:flutter/material.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/post_page.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:provider/provider.dart';

import '../pages/profile_page.dart';

// go to user(oshi) page
void goUserPage(BuildContext context, String tweetId) {
  //navigate to the page
  Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: ProfilePage.routeName),
        builder: (context) => OshiProfilePage(),
      ),
  );
}

// go to post page
void goPostPage(BuildContext context, Post post) {
  final oshiProvider = Provider.of<OshiProvider>(context, listen: false);
  // navigate to post page
  Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: PostPage.routeName),
          builder: (context) => PostPage(
              post: post,
              oshiProvider: oshiProvider,
          ),
      ),
  );
}

