// import 'package:meta/meta.dart';

// @immutable
class AppState {
  String token;
  String loginname;
  String avatar_url;
  String id;
  int count;
  AppState({this.token, this.count, this.avatar_url, this.loginname, this.id})
      : super();

  static AppState rehydrationJSON(dynamic json) => AppState();

  // Map<String, dynamic> toJson() => {'auth': auth.toJSON()};

  AppState copyWith({
    bool rehydrated,
    String token,
    String loginname,
    String avatar_url,
    String id,
    int count,
  }) {
    return new AppState(
      token: token ?? this.token,
      count: count ?? this.count,
      loginname: loginname ?? this.loginname,
      avatar_url: avatar_url ?? this.avatar_url,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return '''AppState{
            token: $token,
            count: $count,
            loginname:$loginname,
            avatar_url:$avatar_url,
            id:$id
        }''';
  }
}
