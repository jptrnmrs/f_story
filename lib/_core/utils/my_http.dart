import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// API 서버의 기본 URL 설정

final baseUrl = 'http://192.168.0.132:8080';

// 전역변수
final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    // 요청 데이터 형식을 json 형식으로 지정
    contentType: 'application/json; charset=utf-8',
    // 필수! dio는 200외의 상태코드를 전부 오류로 바라본다
    // true로 설정하면 다른 상태 코드 값도 다 허용
    validateStatus: (status) => true,
  )
);

// 중요 데이터 보관소 (금고 생성)
// 민감한 데이터를 보관하는 안전한 금고 역할
const secureStorage = FlutterSecureStorage();