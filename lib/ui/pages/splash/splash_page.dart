import 'package:class_f_story/_core/utils/exception_handler.dart';
import 'package:class_f_story/_core/utils/my_http.dart';
import 'package:class_f_story/data/gvm/session_gvm.dart';
import 'package:class_f_story/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ConsumerWidget ---> Stateless
// ConsumerStatefulWidget --> StatefulWidget
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {

  @override
  void initState() {
    // 단 한번 실행되는 코드 --> 객체가 인스턴스화 될 때
    super.initState();
    //1. 화면을 렌더링 시키기 전에 로그인 유무 확인 - 메서드
    _checkLoginStates();
  } // end of initState

  // 로그인 상태 확인 후 자동 로그인 시도 또는 로그인 페이지 이동 처리
  // 1. 토큰 추출
  // 2. 토큰 유무 확인 (없다면 로그인 페이지로 리다이렉트)
  // 2 - 1. 로그인 페이지 이동 처리 (이미지 2초간 보여주고 이동시키기)
  Future<void> _checkLoginStates() async {
    try{
      // I/O
      String? accessToken = await secureStorage.read(key: 'accessToken');
      if(accessToken==null){
       // 화면 이동 처리
        _navigateToLogin();
        return;
      }

      SessionGVM sessionGVM = ref.read(sessionProvider.notifier);
      await sessionGVM.autoLogin();

    } catch (e, stackTrace) {
      ExceptionHandler.handleException('자동 로그인 중 오류 발생', stackTrace);
    }
  }

  // 로그인 페이지 이동 메서드
  void _navigateToLogin(){
    // 2초간 대기 후 로그인 페이지 이동 처리
    Future.delayed(Duration(seconds: 2),(){

      /// mounted --> StatefulWidget이 가지고 있는 변수
      /// 네이게이터 이동시 mounted를 확인하는 이유는
      /// 1. 사용자가 2초 대기 중에 다른 페이지 이동시 이 위젯이 dispose 될 수 있다
      /// 2. dispose된 위젯에서 setState() 또는 Navigator 호출시 예외가 발생해 앱이 종료될 수 있다.
      /// 따라서
      if(mounted)

      Navigator.popAndPushNamed(context, '/login');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.gif',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


// class SplashPage extends ConsumerStatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 자동 로그인 호출
//     // 단 한 번도 로그인 하지 않았던 경우 --> 2초간 gif 이미지 노출
//     // 로그인 경험이 있는 경우 (토큰 존재) --> 즉시 페이지 이동 처리
//     ref.read(sessionProvider.notifier).autoLogin();
//     return Scaffold(
//       body: Center(
//         child: Image.asset(
//           'assets/splash.gif',
//           width: double.infinity,
//           height: double.infinity,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }
// }