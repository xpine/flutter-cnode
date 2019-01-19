import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppActions { UpdateToken }

class Action {
  Action({this.type, this.payload, this.success, this.error, this.done})
      : super();
  var type;
  var payload;
  Function success;
  Function error;
  Function done;
}

typedef ThunkFunction = Future Function(NextDispatcher dispatch, Object store);
ThunkFunction updateTokenAsync(Action action) =>
    (NextDispatcher dispatch, store) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('token ${prefs.get('token')}');
      try {
        await prefs.setString('token', action.payload);
        dispatch(action);
        if (action.success is Function) action.success();
      } catch (e) {
        if (action.error is Function) action.error();
      } finally {
        if (action.done is Function) action.done();
      }
    };
