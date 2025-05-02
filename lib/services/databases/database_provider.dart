/*

DATABASE PROVIDER

- database service class: DB 정보 핸들링
- database privider class: 데이터를 프론트엔드 환경에서 띄우기 위해 가공 처리

*/

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/services/databases/database_service.dart';

import '../../models/user.dart';

class DatabaseProvider extends ChangeNotifier {
  /*

  SERVICES

  */

  // db & auth service 정보를 가져옴
  final _auth = AuthService();
  final _db = DatabaseService();

  /*

  USER PROFILE

  */

// 유저가 등록한 트위터 id를 통해 유저 프로필을 가져옴
  Future<UserProfile?> getUserProfile(String tweetId) async {
    return await _db.getUserFromDB(tweetId);
  }
//local list of posts
  List<Post> _allPosts = [];

  //get posts
  List<Post> get allPosts => _allPosts;

  //모든 포스트 가져오기
  Future<void> loadAllPosts(String tweetId) async {
    //get all posts form DB
    final allPosts = await _db.getAllPostFromDB(tweetId);

    //update local data
    _allPosts = allPosts;

    //update UI
    notifyListeners();
  }


}