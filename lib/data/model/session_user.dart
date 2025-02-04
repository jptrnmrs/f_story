class SessionUser {
  int? id;
  String? username;
  String? accessToken;
  bool? isLogin;

  SessionUser({
    required this.id,
    required this.username,
    required this.accessToken,
    required this.isLogin,
  });
}
