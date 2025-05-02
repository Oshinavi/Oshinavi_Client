/*

POST PAGE

This page displays:

- individual post

*/

import 'package:flutter/material.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:intl/intl.dart';

class PostPage extends StatefulWidget {
  final Post post;
  final OshiProvider oshiProvider;

  const PostPage({
    super.key,
    required this.post,
    required this.oshiProvider,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String? _oshiUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOshiUserId();
  }

  Future<void> _loadOshiUserId() async {
    final oshi = await widget.oshiProvider.getOshi();
    setState(() {
      _oshiUserId = oshi['oshi_tweet_id'];
      _isLoading = false;
    });
  }
  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(widget.post.date);
    // SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // App Bar
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft, // 왼쪽 정렬
          child: Text(
            "포스트",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      // Body
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          PostTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.username),
            onPostTap: null,
            oshiProvider: widget.oshiProvider,
            onPostPage: true,
            oshiUserId: _oshiUserId ?? '',
          ),

          // Comments on this post
        ],
      ),
    );
  }
}
