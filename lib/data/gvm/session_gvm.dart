import 'package:class_f_story/_core/utils/exception_handler.dart';
import 'package:class_f_story/_core/utils/my_http.dart';
import 'package:class_f_story/data/model/session_user.dart';
import 'package:class_f_story/data/repository/user_repository.dart';
import 'package:class_f_story/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 뷰 모델 --> 화면에 있는 데이터를 가지고 와서 사용한다.
// 로그인 요청을 할 때 어떤 변수를 필요할까?

// 뷰모델에 속성 --> 세션 유저가 된다.
// 뷰모델에 행위 --> 로그인 행위, 로그아웃 행위, 자동 로그인 행위
class SessionGVM extends Notifier<SessionUser> {
  // 뷰 모델에서 컨텍스트를 사용하는 방안
  final mContext = navigatorkey.currentContext!;
  UserRepository userRepository = UserRepository();

  // 상태를 초기화 해주어야 한다. (선언형 UI 이기 때문에)
  @override
  SessionUser build() {
    // 추상화 변수 state(외부 에서 접근하는 변수명 )
    // state ==> SessionUser() 객체가 된다.
    return SessionUser(
      id: null,
      username: null,
      accessToken: null,
      isLogin: false,
    );
  }

  // 로그인 행위
  // 화면에서 뷰 모델에게 로그인 요청 위임
  Future<void> login(String username, String password) async {
    // 서버측으로 던질 데이터를 구축해야 한다.
    try {
      // 요청 HTTP 메세지 body
      final body = {
        'username': username,
        'password': password,
      };

      final (responseBody, accessToken) =
          await userRepository.findByUsernameAndPassword(body);
      // responseBody['success'] -- true --> false
      // 서버측에서 통신은 성공 했으나 내부 오류 판단
      if (!responseBody['success']) {
        ExceptionHandler.handleException(
            responseBody['errorMessage'], StackTrace.current);
        return; // 실행의 제어건 반납
      }

      // 1. JWT 토큰을 안전한 금고에 보관 처리 //
      // I/O 시간이 많이 걸리기 때문에 비동기 처리
      await secureStorage.write(key: 'accessToken', value: accessToken);

      // 2. 뷰 모델에 상태 갱신
      // 깊은 복사 처리
      Map<String, dynamic> resData = responseBody['response'];
      state = SessionUser(
          id: resData['id'],
          username: resData['username'],
          accessToken: accessToken,
          isLogin: true);

      // 3. Dio 헤더에 JWT 토큰 설정(객체 상태값 추가)
      dio.options.headers['Authorization'] = accessToken;
      // 화면 이동 처리 pushNamed -> pushNamed -> pushNamed
      // Navigator stack 메모리에 계속 쌓인다..
      // Navigator.pushNamed(mContext, '/post/list');
      // 이전에 쌓여 있던 stack(화면) 다 파괴 하면서 이동 처리
      Navigator.popAndPushNamed(mContext, '/post/list');
      // 모든 예외처리가 설정 된다.
    } catch (e, stackTrace) {
      // IP 주소가 잘못, 서버가 종료 되어 있을 때, 서버 연결 시간 초과
      ExceptionHandler.handleException('서버 연결 실패', stackTrace);
    }
  }

  // 회원 등록 행위
  // 1. UserRepository에 회원 등록 API 요청 확인
  Future<void> join(String username, String email, String password) async {
    try {
      // 요청 HTTP 메세지 body
      final body = {
        'username': username,
        'email': email,
        'password': password,
      };
      Map<String, dynamic> resBody = await userRepository.save(body);
      // 통신은 성공이지만 내부 판별 오류시 방어적 코드 작성
      if (!resBody['success']) {
        ExceptionHandler.handleException(
            resBody['errorMessage'], StackTrace.current);
        return; // 실행의 제어건 반납
      }
      // 성공하면 회원가입 완료 -> 화면 이동 코드
      // ExceptionHandler.handleException('회원가입 성공', StackTrace.current);

      // 바로 화면 이동 처리

      Navigator.popAndPushNamed(mContext, '/login');
    } catch (e, stackTrace) {
      ExceptionHandler.handleException('서버 연결 실패', stackTrace);
    }
  }

  // 로그아웃 행위

  // 자동로그인 행위
  // 로직 정리
  // 0. 예외 처리
  // 1. 디바이스 기기에 토큰 확인
  // 2. 디바이스 토큰 유무 확인
  // 3. 토큰 유효성 검사
  // 4. SessionUser 상태 갱신
  // 5. dio 헤더에 토큰 다시 설정
  // 6. 게시글 목록 페이지 이동 처리
  Future<void> autoLogin() async {
    try {
      // 비동기 처리 -- 코드가 내려가지 않고 완료될 때까지 잠시 대기
      // 1. 토큰을 디바이스에서 가져오기
      // 2. JWT 토큰 유무 확인 (없을 경우, 있을 경우)
      String? accessToken = await secureStorage.read(key: 'accessToken');

      if (accessToken == null) {
        Navigator.popAndPushNamed(mContext, '/login');
        return; // 실행 제어권 반납
      }

      // 토큰이 있다면 user_repository 호출
      // success --> false, true 로직 설계
      Map<String, dynamic> resBody =
          await userRepository.loginWithToken(accessToken);

      // success --> false
      // 서버 내부적으로 오류로 판결 처리
      if (!resBody['success']) {
        Navigator.popAndPushNamed(mContext, '/login');
        return; // 실행 제어권 반납
      }

      // success --> true
      // 상태 값을 변경할때 불변 객체로 변경
      // 다운 캐스팅
      Map<String, dynamic> data = resBody['response'];
      state = SessionUser(
        id: data['id'],
        username: data['username'],
        accessToken: accessToken,
        isLogin: true,
      );
      // 상태 변경 완료
      // 혹시 ... dio header에 다시 설정해줌
      dio.options.headers['Authorization'] = accessToken;

      Navigator.popAndPushNamed(mContext, '/post/list');


    } catch (e, stackTrace) {
      ExceptionHandler.handleException('자동 로그인 중 오류 발생', stackTrace);
      // 화면 파괴하면서 이동 처리
      Navigator.popAndPushNamed(mContext, '/login');
    }
  }
}

// 창고 관리자 선언 (창고 - 뷰모델), 창고 어떤 관리해라 지정 !!
final sessionProvider = NotifierProvider<SessionGVM, SessionUser>(
  () => SessionGVM(),
);
