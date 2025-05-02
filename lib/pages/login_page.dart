import 'package:flutter/material.dart';
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simplebutton.dart';
import 'package:mediaproject/components/text_field_login.dart';
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //auth service에 access
  final _auth = AuthService();
  //텍스트 컨트롤러
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  bool _isLoading = false;

  // 로그인 방법
  void _login() async {
    //로딩서클 출력
    showLoadingCircle(context);

    setState(() {
      _isLoading = true;  // 로그인 중 로딩 상태 표시
    });

    final username = idController.text;
    final password = pwController.text;

    final result = await _auth.login(username, password);

    setState(() {
      _isLoading = false;  // 로그인 완료 후 로딩 상태 해제
    });

    if (result.containsKey('error')) {
      //로딩서클 숨기기
      if (mounted) hideLoadingCircle(context);
      // 로그인 실패 시 오류 메시지 출력
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그인 실패'),
            content: Text(result['error']),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else {
      //로딩서클 숨기기
      if (mounted) hideLoadingCircle(context);
      // 로그인 성공 후 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),  // HomeScreen으로 이동
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.lock_open_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  "트위터 자동 번역 앱",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                // 트위터 계정명 텍스트필드
                TextFieldLogin(
                  controller: idController,
                  hintText: "이메일을 입력하세요",
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // 비밀번호 텍스트필
                TextFieldLogin(
                  controller: pwController,
                  hintText: "비밀번호를 입력하세요",
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "비밀번호를 잊으셨나요?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // 로그인 버튼
                SimpleButton(
                  text: "Login",
                  onTap: _login,
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "회원이 아니신가요?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: widget.onTap, // 회원가입 페이지로 이동
                      child: Text(
                        " 지금 가입하세요",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}