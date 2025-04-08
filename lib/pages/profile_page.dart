import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  // 트위터 유저명
  final String tweetId;

  const ProfilePage({
    super.key,
    required this.tweetId
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // providers
  late final databaseProvider =
  Provider.of<DatabaseProvider>(context, listen: false);

  // user info
  UserProfile? user;
  String? currentUserTweetId;

  // loading...
  bool _isLoading = true;

  // on startup,
  @override
  void initState() {
    super.initState();

    // load user info
    loadUser();
  }

  Future<void> loadUser() async{

    currentUserTweetId = await AuthService().getCurrentTweetid();

    // 예외 처리
    if (currentUserTweetId == null) {
      print("🚨 tweetId를 불러오지 못했습니다.");
      setState(() => _isLoading = false);
      return;
    }

    // get the user profile info
    final tweetId = currentUserTweetId!;
    user = await databaseProvider.getUserProfile(tweetId);

    // finished loading...
    setState(() {
      _isLoading = false;
    });
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("유저 정보를 불러올 수 없음")),
        body: const Center(child: Text("유저 데이터를 가져오는 데 실패했습니다.")),
      );
    }
    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //App Bar
      appBar: AppBar(
        title: Text(_isLoading ? '' : user!.username),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      // Body
      body: ListView(
        children: [
          // username handle
          Center(
            child: Text(
              _isLoading ? '' : '@${user!.tweetId}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),

          const SizedBox(height: 25),

          // profile picture
          Center(
            child: Container(
              decoration:
                BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(25),
                ),
              padding: const EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // profile stats -> number of posts / followers / following

          // follow / unfollow button

          // bio box
          BioBox(text: user!.bio)

          // list of posts from user
        ],
      )
    );
  }
}

