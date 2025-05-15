import 'package:flutter/material.dart';
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simplebutton.dart';
import 'package:mediaproject/components/text_field_login.dart';
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onTap;
  const LoginPage({super.key, required this.onTap});
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    showLoadingCircle(context);

    try {
      final result = await _auth.login(
        emailController.text.trim(),
        pwController.text,
      );

      if (!mounted) return;
      hideLoadingCircle(context);
      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 성공')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            settings: RouteSettings(name: HomePage.routeName),
            builder: (_) => const HomePage()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      hideLoadingCircle(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Icon(Icons.lock, size: 72, color: colors.primary),
              const SizedBox(height: 50),
              Text('로그인', style: TextStyle(fontSize: 16, color: colors.primary)),
              const SizedBox(height: 25),
              TextFieldLogin(controller: emailController, hintText: '이메일', obscureText: false),
              const SizedBox(height: 10),
              TextFieldLogin(controller: pwController, hintText: '비밀번호', obscureText: true),
              const SizedBox(height: 25),
              SimpleButton(
                text: _isLoading ? '로그인 중...' : '로그인',
                onTap: _isLoading ? null : _login,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('계정이 없으신가요?', style: TextStyle(color: colors.primary)),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(' 회원가입',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}