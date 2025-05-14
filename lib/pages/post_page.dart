import 'package:flutter/material.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/services/oshi_provider.dart';

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
    _loadOshi();
  }

  Future<void> _loadOshi() async {
    final info = await widget.oshiProvider.getOshi();
    setState(() {
      _oshiUserId = info['oshi_tweet_id'] as String?;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("포스트"),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          PostTile(
            post: post,
            onUserTap: () => goUserPage(context, post.uid),
            onPostTap: null,
            oshiProvider: widget.oshiProvider,
            onPostPage: true,
            oshiUserId: _oshiUserId,
          ),
        ],
      ),
    );
  }
}