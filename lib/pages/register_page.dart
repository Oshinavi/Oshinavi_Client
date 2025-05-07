// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simplebutton.dart';
import 'package:mediaproject/components/text_field_login.dart';
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();

  final TextEditingController nameController      = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController pwController        = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  final TextEditingController tweetIdController   = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    tweetIdController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    // 1) 비밀번호 최소 길이 검증
    if (pwController.text.length < 6 || confirmPwController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 비밀번호는 최소 6자 이상이어야 합니다.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    // 2) 비밀번호 일치 검증
    if (pwController.text != confirmPwController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 비밀번호가 일치하지 않습니다.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    showLoadingCircle(context);
    try {
      final result = await _auth.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        pwController.text,
        confirmPwController.text,
        tweetIdController.text.trim(),
      );
      hideLoadingCircle(context);
      setState(() => _isLoading = false);

      // 404 Not Found: 존재하지 않는 트위터 유저
      if (result['statusCode'] == 404) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('회원가입 실패'),
            content: const Text('존재하지 않는 트위터 유저입니다.'),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return;
      }

      // 409 Conflict: 중복 에러
      if (result['statusCode'] == 409) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('회원가입 실패'),
            content: Text(result['error']),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return;
      }

      // 성공 토큰 리턴된 경우
      if (result.containsKey('token')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 회원가입 및 로그인 성공')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // 기타 에러는 Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? '회원가입 실패')),
        );
      }
    } catch (e) {
      hideLoadingCircle(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
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

                TextFieldLogin(controller: nameController,      hintText: "이름을 입력하세요",                obscureText: false),
                const SizedBox(height: 10),
                TextFieldLogin(controller: emailController,     hintText: "이메일을 입력하세요",              obscureText: false),
                const SizedBox(height: 10),
                TextFieldLogin(controller: pwController,        hintText: "비밀번호를 입력하세요 (최소 6자)",  obscureText: true),
                const SizedBox(height: 10),
                TextFieldLogin(controller: confirmPwController, hintText: "비밀번호 확인",                    obscureText: true),
                const SizedBox(height: 10),
                TextFieldLogin(controller: tweetIdController,   hintText: "트위터 id(@ 제외)를 입력하세요", obscureText: false),
                const SizedBox(height: 25),

                SimpleButton(
                  text: _isLoading ? "가입 중..." : "회원가입",
                  onTap: _isLoading ? null : _signUp,
                ),
                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("이미 계정이 있으신가요?", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(" 로그인", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}