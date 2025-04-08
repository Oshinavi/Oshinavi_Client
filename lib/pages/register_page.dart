import 'package:flutter/material.dart';
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simplebutton.dart';
import 'package:mediaproject/components/text_field_login.dart';
import 'package:mediaproject/pages/login_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/services/databases/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();
  final _db = DatabaseService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  final TextEditingController tweetIdController = TextEditingController();
  bool _isLoading = false;

  // 회원가입 요청
  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    // 비밀번호 확인
    if (pwController.text != confirmPwController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 비밀번호가 일치하지 않습니다.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    showLoadingCircle(context);

    try {

      final result = await _auth.signup(
        nameController.text,
        emailController.text,
        pwController.text,
        confirmPwController.text,
        tweetIdController.text,
      );

      if (result.containsKey('message')) {  // 성공 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${result['message']}')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: widget.onTap), // onTap 전달
          ),
        );
        if (mounted) hideLoadingCircle(context);

        //등록 후 유저 프롷필을 DB에 저장
        // await _db.saveUserInfo(tweetId: tweetId)
      }

      else {
        if (mounted) hideLoadingCircle(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? '회원가입 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView( // Add this to make the screen scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.person_add_alt_1,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "회원가입",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 사용자 이름 입력
                  TextFieldLogin(
                    controller: nameController,
                    hintText: "이름을 입력하세요",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),

                  // 이메일 입력
                  TextFieldLogin(
                    controller: emailController,
                    hintText: "이메일을 입력하세요",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),

                  // 비밀번호 입력
                  TextFieldLogin(
                    controller: pwController,
                    hintText: "비밀번호를 입력하세요",
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),

                  // 비밀번호 확인 입력
                  TextFieldLogin(
                    controller: confirmPwController,
                    hintText: "비밀번호 확인",
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // 유저 트위터 id 입력
                  TextFieldLogin(
                    controller: tweetIdController,
                    hintText: "트위터 id(@ 제외)를 입력하세요",
                    obscureText: false,
                  ),

                  const SizedBox(height: 25),

                  // 회원가입 버튼
                  SimpleButton(
                    text: _isLoading ? "가입 중..." : "회원가입",
                    onTap: _isLoading ? null : _signUp,
                  ),
                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "이미 계정이 있으신가요?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          " 로그인",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}