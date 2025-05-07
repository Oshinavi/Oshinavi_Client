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
  // ────────────────────────────────────────────────────────────
  // Service & Controller
  // ────────────────────────────────────────────────────────────
  final _auth = AuthService();
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  bool _isLoading = false;

  // ────────────────────────────────────────────────────────────
  // 로그인 처리
  // ────────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email    = idController.text.trim();
    final password = pwController.text;

    // 1) 비밀번호 최소 길이 검증
    if (password.length < 6) {
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('유효하지 않은 비밀번호'),
          content: Text('비밀번호는 최소 6자 이상이어야 합니다.'),
        ),
      );
      return; // 더 이상 진행하지 않음
    }

    // 2) 로딩 표시
    showLoadingCircle(context);
    setState(() => _isLoading = true);

    // 3) 서버 요청
    final result = await _auth.login(email, password);

    setState(() => _isLoading = false);
    if (mounted) hideLoadingCircle(context);

    // 4) 결과 처리
    if (result.containsKey('error')) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('로그인 실패'),
          content: Text(result['error']),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(Icons.lock_open_rounded, size: 72, color: theme.primary),
                const SizedBox(height: 50),
                Text('트위터 자동 번역 앱',
                    style: TextStyle(color: theme.primary, fontSize: 16)),
                const SizedBox(height: 25),

                // ── 이메일 입력 ──
                TextFieldLogin(
                  controller: idController,
                  hintText: '이메일을 입력하세요',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // ── 비밀번호 입력 ──
                TextFieldLogin(
                  controller: pwController,
                  hintText: '비밀번호를 입력하세요',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text('비밀번호를 잊으셨나요?',
                      style: TextStyle(
                          color: theme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 25),

                // ── 로그인 버튼 ──
                SimpleButton(
                  text: _isLoading ? 'Loading...' : 'Login',
                  onTap: _isLoading ? null : _login,
                ),
                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('회원이 아니신가요?',
                        style: TextStyle(color: theme.primary)),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(' 지금 가입하세요',
                          style: TextStyle(
                              color: theme.primary,
                              fontWeight: FontWeight.bold)),
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