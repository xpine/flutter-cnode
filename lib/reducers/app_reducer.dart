import 'package:flutter_cnode/models/app_state.dart';
import 'package:flutter_cnode/actions/app_actions.dart';

AppState appReducer(AppState state, a) {
  print('action ${a.type} payload ${a.payload} ${a is Action}');
  Action action = a;
  if (action.type == AppActions.UpdateToken) {
    state.token = action.payload['token'];
    state.loginname = action.payload['loginname'];
    state.avatar_url = action.payload['avatar_url'];
  }
  if (action.type == AppActions.RemoveToken) {
    state.token = null;
    state.loginname = null;
    state.avatar_url = null;
  }
  return state;
}
