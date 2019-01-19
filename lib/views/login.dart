import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cnode/actions/app_actions.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _textEditingController;
  var _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text('login'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              StoreConnector(
                converter: (store) => store.state,
                builder: (context, state) {
                  print('state ${state}');
                  _textEditingController =
                      TextEditingController(text: state.token);
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              labelText: 'token', hintText: '请输入token'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: StoreConnector(
          converter: (store) {
            return () {
              print('ttoken ${_textEditingController.text}');
              return store.dispatch(updateTokenAsync(Action(
                  type: AppActions.UpdateToken,
                  success: () {
                    var snackbar = SnackBar(
                        content: Text('设置成功'), duration: Duration(seconds: 2));
                    _scaffoldkey.currentState.showSnackBar(snackbar);
                  },
                  error: () {
                    var snackbar = SnackBar(
                        content: Text('设置失败，请重试'),
                        duration: Duration(seconds: 2));
                    _scaffoldkey.currentState.showSnackBar(snackbar);
                  },
                  payload: _textEditingController.text)));
            };
          },
          builder: (context, callback) {
            return Container(
              padding: EdgeInsets.all(20),
              child: RaisedButton(
                onPressed: callback,
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text('设置token'),
              ),
            );
          },
        ));
  }
}
