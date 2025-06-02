import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/login_or_register_toggle.dart';
import '../../views/home/home_page.dart';

/// AuthGatePage:
/// - 앱 실행 시 사용자 로그인 상태를 확인하고 로그인되어 있으면 HomePage로 즉시 이동
///   아니라면 로그인/회원가입 토글 화면 표시
/// 주요 단계:
/// 1) initState에서 _checkLogin() 호출하여 로그인 여부 조회
/// 2) 로그인 검사 완료 전에는 로딩 인디케이터 표시
/// 3) 로그인되어 있다면 HomePage를 반환
/// 4) 그렇지 않으면 LoginOrRegisterToggle 화면 반환
class AuthGatePage extends StatefulWidget {
  const AuthGatePage({Key? key}) : super(key: key);

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  bool _checked = false;   // 로그인 여부 검사가 완료되었는지 여부
  bool _loggedIn = false;  // 실제 로그인 상태 저장

  @override
  void initState() {
    super.initState();
    _checkLogin();  // 1) 로그인 상태 확인 비동기 호출
  }

  /// _checkLogin:
  /// - AuthViewModel.checkLoginStatus()를 호출하여 로그인 상태를 확인한 뒤 setState로 UI 갱신
  Future<void> _checkLogin() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.checkLoginStatus(); // 로그인 토큰 또는 세션 확인
    setState(() {
      _checked = true;
      _loggedIn = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2) 아직 로그인 검사 중이면 로딩 인디케이터 표시
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) 이미 로그인된 상태면 HomePage로 바로 이동
    if (_loggedIn) {
      return const HomePage();
    }

    // 4) 로그인 필요 시: 로그인/회원가입 토글 화면 반환
    return const Scaffold(
      body: LoginOrRegisterToggle(),
    );
  }
}