import 'package:redux/redux.dart';
import 'package:flutter_cnode/reducers/app_reducer.dart';
import 'package:flutter_cnode/models/app_state.dart';
import 'package:flutter_cnode/actions/app_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThunkMiddleware extends MiddlewareClass<AppState> {
  call(Store<AppState> store, action, NextDispatcher next) {
    print('action $action ');
    if (action is Action) {
      next(action);
    } else {
      action(next, store);
    }
  }
}

Future<Store<AppState>> createStore() async {
  Store<AppState> store = Store(
    appReducer,
    initialState: AppState(
      count: 0, 
      token: await getPerf('token')??null,
      loginname: await getPerf('loginname')??null,
      avatar_url: await getPerf('avatar_url')??null,
    ),
    middleware: [ThunkMiddleware()],
  );
  // persistor.start(store);
  return store;
}

getPerf(key) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('getPerf: ${prefs.get(key)}');
  return prefs.get(key);
}
