import 'package:class_f_story/_core/utils/logger.dart';
import 'package:class_f_story/_core/utils/my_http.dart';
import 'package:dio/dio.dart';

class UserRepository {
  const UserRepository();

  // 사용자의 이름과 비밀번호 확인 요청
  // 레코드 문법으로 변환
  Future<(Map<String, dynamic>, String)> findByUsernameAndPassword(
      Map<String, dynamic> reqData) async {
    Response response = await dio.post('/login', data: reqData);

    Map<String, dynamic> responseBody = response.data;
    String accessToken = response.headers['Authorization']?[0] ?? '';

    logger.i(accessToken);
    //레코드 문법, 1. 위치 기반 레코드 문법, 명명 기반 레코드 문법
    return (responseBody, accessToken);
  }

  // 사용자 등록 요청
  Future<Map<String, dynamic>> save(Map<String, dynamic> reqData) async {
    Response response = await dio.post('/join', data: reqData);
    // 바디 추출
    Map<String, dynamic> responseBody =
        response.data; // header, body 중에 body 만 추출
    logger.i(responseBody);
    return responseBody;
  }

  // 자동 로그인
  // 매번 앱을 실행할 때마다 로그인을 하는 건 사용자 경험에 좋지 않음
  // --> 서버 --> 인증 사용자 판별 --> 인증 -> JWT 토큰
  // 로그인 --> 로컬 --> JWT 토큰 (-기기에서 토큰 꺼내서 다시 서버로 던져봐야 한다.)
  Future<Map<String, dynamic>> loginWithToken(String accessToken) async {
    // dio 헤더 설정하는 방법
    Response response = await dio.post(
      '/auto/login',
      options: Options(
        headers: {"Authorization": accessToken},
      ),
    );
    Map<String,dynamic> responseBody = response.data;
    return responseBody;
  }
}
