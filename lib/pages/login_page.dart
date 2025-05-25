import 'package:flutter/material.dart';
import 'package:provider/provider.dart';                       // ← 추가
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simplebutton.dart';
import 'package:mediaproject/components/text_field_login.dart';
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/themes/theme_provider.dart';        // ← 추가

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
        const SnackBar(content: Text('로그인되었습니다')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: RouteSettings(name: HomePage.routeName),
          builder: (_) => const HomePage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      hideLoadingCircle(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    // 화면 너비의 60%를 로고 크기로 동적 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.6;

    final logoAsset = isDarkMode
        ? 'assets/images/oshinavi_logo_home_dark.png'
        : 'assets/images/oshinavi_logo_home.png';

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ConstrainedBox(
            // 세로 공간이 부족해도 가운데 정렬 유지
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 유동 크기의 로고
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      logoAsset,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextFieldLogin(
                    controller: emailController,
                    hintText: '이메일',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  TextFieldLogin(
                    controller: pwController,
                    hintText: '비밀번호',
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  SimpleButton(
                    text: _isLoading ? '로그인 중...' : '로그인',
                    onTap: _isLoading ? null : _login,
                  ),

                  const Spacer(),  // 남은 공간을 밀어내서 하단 마진 확보

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('계정이 없으신가요?',
                          style: TextStyle(color: colors.primary)),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          ' 회원가입',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}