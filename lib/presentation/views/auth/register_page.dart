import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/common/simple_button.dart';
import '../../widgets/common/text_field_login.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/home/home_page.dart';

/// RegisterPage:
/// - 회원가입 폼을 보여주고 입력된 정보를 기반으로 회원가입 요청을 전송
/// - AuthViewModel.signup 호출 후 결과 처리
/// - 회원가입 성공 시 홈 화면으로 이동, 실패 시 다이얼로그로 에러 표시
/// 주요 단계:
/// 1) 입력 필드(TextFieldLogin) 7개 (이름, 이메일, 비밀번호, 비밀번호 확인, 트위터 ID, ct0, authToken)
/// 2) SimpleButton을 눌러 _onSignUp() 호출
/// 3) _onSignUp(): 입력 검증 → AuthViewModel.signup 호출 → 결과에 따라 화면 전환 or 에러 다이얼로그
/// 4) 로딩 중에는 CircularProgressIndicator 표시
class RegisterPage extends StatefulWidget {
  final VoidCallback? onTap; // 로그인 화면으로 돌아가는 콜백
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);
  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 입력 컨트롤러 선언
  final TextEditingController _nameController      = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _pwController        = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _tweetIdController   = TextEditingController();
  final TextEditingController _ct0Controller       = TextEditingController();
  final TextEditingController _authTokenController = TextEditingController();

  @override
  void dispose() {
    // 입력 컨트롤러 dispose
    _nameController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    _tweetIdController.dispose();
    _ct0Controller.dispose();
    _authTokenController.dispose();
    super.dispose();
  }

  /// _onSignUp:
  /// - 필수 입력 필드가 모두 채워졌는지 확인
  /// - 비밀번호/비밀번호 확인 일치 여부 확인
  /// - AuthViewModel.signup 호출하여 서버 요청
  /// - 성공 시 SnackBar 표시 후 홈 화면으로 네비게이션
  /// - 실패 시 AlertDialog로 에러 메시지 출력
  Future<void> _onSignUp() async {
    final vm = context.read<AuthViewModel>();

    // 1) 모든 필드가 채워졌는지 검증
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _pwController.text.isEmpty ||
        _confirmPwController.text.isEmpty ||
        _tweetIdController.text.isEmpty ||
        _ct0Controller.text.isEmpty ||
        _authTokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 채워주세요.')),
      );
      return;
    }

    // 2) 비밀번호 일치 여부 검증
    if (_pwController.text != _confirmPwController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    // 3) AuthViewModel.signup 호출
    await vm.signup(
      username:   _nameController.text.trim(),
      email:      _emailController.text.trim(),
      password:   _pwController.text,
      cfpassword: _confirmPwController.text,
      tweetId:    _tweetIdController.text.trim(),
      ct0:        _ct0Controller.text.trim(),
      authToken:  _authTokenController.text.trim(),
    );

    // 4) 요청 결과에 따라 화면 전환 또는 에러 표시
    if (vm.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 및 로그인 성공')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('회원가입 실패'),
          content: Text(vm.errorMessage!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final isLoading = vm.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 아이콘 및 제목
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
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),

              // 입력 필드 1: 이름
              TextFieldLogin(
                controller: _nameController,
                hintText: "이름을 입력하세요",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              // 입력 필드 2: 이메일
              TextFieldLogin(
                controller: _emailController,
                hintText: "이메일을 입력하세요",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              // 입력 필드 3: 비밀번호
              TextFieldLogin(
                controller: _pwController,
                hintText: "비밀번호 입력 (최소 6자)",
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // 입력 필드 4: 비밀번호 확인
              TextFieldLogin(
                controller: _confirmPwController,
                hintText: "비밀번호 확인",
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // 입력 필드 5: 트위터 ID
              TextFieldLogin(
                controller: _tweetIdController,
                hintText: "트위터 id 입력 (@ 제외)",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              // 입력 필드 6: ct0 값
              TextFieldLogin(
                controller: _ct0Controller,
                hintText: "ct0 값 입력",
                obscureText: false,
              ),
              const SizedBox(height: 10),

              // 입력 필드 7: auth_token
              TextFieldLogin(
                controller: _authTokenController,
                hintText: "auth_token 입력",
                obscureText: true,
              ),
              const SizedBox(height: 25),

              // 회원가입 버튼 또는 로딩 인디케이터
              vm.isLoading
                  ? const CircularProgressIndicator()
                  : SimpleButton(
                text: "회원가입",
                onTap: _onSignUp,
                enabled: !vm.isLoading,
              ),

              const SizedBox(height: 50),

              // 이미 계정이 있을 때 로그인 화면으로 토글
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
                      "  로그인",
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
    );
  }
}