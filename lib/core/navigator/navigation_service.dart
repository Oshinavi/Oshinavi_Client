import 'package:flutter/widgets.dart';

/// 글로벌 Navigator 키를 통해 네비게이션을 전역에서 관리할 수 있도록 지원
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 네비게이션을 전역적으로 관리하기 위한 서비스 클래스
class NavigationService {
  /// 현재 앱의 NavigatorState에 접근할 수 있는 키 반환
  GlobalKey<NavigatorState> get key => navigatorKey;

  /// 지정된 routeName으로 화면 전환
  /// - arguments가 필요할 경우 함께 전달
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  /// 현재 화면을 pop하여 이전 화면으로 돌아감
  void goBack() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.pop();
    }
  }
}