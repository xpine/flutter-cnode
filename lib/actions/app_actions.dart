import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cnode/api/request.dart' as Request;

var api = new Request.Api();
enum AppActions { UpdateToken, RemoveToken }

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
      try {
        await prefs.setString('token', action.payload);
        var token = action.payload;
        var ret = await api.dio
            .post('/accesstoken', data: {'accesstoken': action.payload});
        await prefs.setString('loginname', ret.data['loginname']);
        await prefs.setString('avatar_url', ret.data['avatar_url']);
        print('token ${action.payload} ${ret.data}');
        action.payload = {
          'token': token,
          'loginname': ret.data['loginname'],
          'avatar_url': ret.data['avatar_url']
        };
        dispatch(action);
        if (action.success is Function) action.success();
      } catch (e) {
        if (action.error is Function) action.error();
      } finally {
        if (action.done is Function) action.done();
      }
    };
ThunkFunction removeTokenAsync(Action action) =>
    (NextDispatcher dispatch, store) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await prefs.setString('token', null);
        await prefs.setString('loginname', null);
        await prefs.setString('avatar_url', null);
        dispatch(action);
        if (action.success is Function) action.success();
      } catch (e) {
        if (action.error is Function) action.error();
      } finally {
        if (action.done is Function) action.done();
      }
    };
