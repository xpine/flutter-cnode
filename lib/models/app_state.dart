// import 'package:meta/meta.dart';

// @immutable
class AppState {
  String token;
  int count;
  AppState({this.token, this.count}) : super();

  static AppState rehydrationJSON(dynamic json) => AppState();

  // Map<String, dynamic> toJson() => {'auth': auth.toJSON()};

  AppState copyWith({
    bool rehydrated,
    String token,
    int count,
  }) {
    return new AppState(
      token: token ?? this.token,
      count: count ?? this.count,
    );
  }

  @override
  String toString() {
    return '''AppState{
            token: $token,
            count: $count
        }''';
  }
}
