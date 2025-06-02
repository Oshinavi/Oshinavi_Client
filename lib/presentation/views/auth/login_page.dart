import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/simple_button.dart';
import '../../widgets/common/text_field_login.dart';

/// LoginPage:
/// - 이메일/비밀번호 입력 후 로그인 처리
/// - AuthViewModel.login 호출하여 결과를 받아 처리
/// - 로그인 성공 시 홈 화면으로 네비게이션
/// - 로그인 실패 시 SnackBar로 에러 메시지 표시
/// 주요 단계:
/// 1) 이메일/비밀번호 입력 필드 (TextFieldLogin) 2개
/// 2) SimpleButton을 눌러 _login() 호출
/// 3) _login(): AuthViewModel.login() 호출 후 상태에 따라 화면 전환 or 에러 표시
/// 4) 로딩 중에는 CircularProgressIndicator 표시 및 버튼 비활성화
class LoginPage extends StatefulWidget {
  /// toggleToRegister: 회원가입 화면으로 전환하는 콜백
  final VoidCallback toggleToRegister;

  const LoginPage({Key? key, required this.toggleToRegister}) : super(key: key);
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// _login:
  /// - AuthViewModel.login(email, password) 호출
  /// - vm.errorMessage가 null이면 로그인 성공 → '/home' 페이지로 이동
  /// - 아니면 SnackBar로 에러 메시지 출력
  Future<void> _login() async {
    final vm = context.read<AuthViewModel>();
    await vm.login(_emailController.text.trim(), _passwordController.text);
    if (vm.errorMessage == null) {
      // 로그인 성공 → 홈으로 네비게이션
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 로그인 실패 → 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final colors = Theme.of(context).colorScheme;

    // 로고 크기 계산: 화면 너비의 60%
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.6;
    final isLoading = vm.isLoading; // 로그인 처리 중 여부

    // 로고 이미지: 로딩 중이면 다크 버전, 아니면 일반 버전
    final logoAsset = isLoading
        ? 'assets/images/oshinavi_logo_home_dark.png'
        : 'assets/images/oshinavi_logo_home.png';

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // 최소 높이: 전체 화면 높이 - 상태바 높이
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1) 로고
                  SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(logoAsset, fit: BoxFit.contain),
                  ),

                  const SizedBox(height: 30),

                  // 2) '로그인' 텍스트
                  Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3) 이메일 입력 필드
                  TextFieldLogin(
                    controller: _emailController,
                    hintText: '이메일',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // 4) 비밀번호 입력 필드
                  TextFieldLogin(
                    controller: _passwordController,
                    hintText: '비밀번호',
                    obscureText: true,
                  ),

                  const SizedBox(height: 25),

                  // 5) 로그인 버튼 / 로딩 인디케이터
                  SimpleButton(
                    text: isLoading ? '로그인 중...' : '로그인',
                    enabled: !isLoading,
                    onTap: isLoading ? () {} : _login,
                  ),

                  const Spacer(),

                  // 6) 회원가입으로 토글하는 텍스트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '계정이 없으신가요?',
                        style: TextStyle(color: colors.primary),
                      ),
                      GestureDetector(
                        onTap: widget.toggleToRegister,
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

                  // 7) 로딩 중에는 하단에 로딩 인디케이터 표시
                  if (isLoading) const LoadingIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}