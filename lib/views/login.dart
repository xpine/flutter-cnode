import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_cnode/actions/app_actions.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _textEditingController;
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  showSnackBar(String text) {
    
    var snackbar =
        SnackBar(content: Text(text), duration: Duration(seconds: 2));
    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            key: _scaffoldkey,
            appBar: AppBar(
              title: Text('login'),
              actions: <Widget>[
                StoreConnector(
                  converter: (store) {
                    return (String qrcode) {
                      print('ttoken $qrcode');
                      return store.dispatch(updateTokenAsync(Action(
                          type: AppActions.UpdateToken,
                          success: () {
                            this.showSnackBar('登录成功');
                            _textEditingController.text = qrcode;
                          },
                          error: () {
                            this.showSnackBar('登录失败，请重试');
                          },
                          payload: qrcode)));
                    };
                  },
                  builder: (context, callback) {
                    return IconButton(
                      icon: Icon(Icons.photo_camera),
                      onPressed: () async {
                        try {
                          String qrcode = await QRCodeReader()
                              .setAutoFocusIntervalInMs(200) // default 5000
                              .setForceAutoFocus(true) // default false
                              .setTorchEnabled(true) // default false
                              .setHandlePermissions(true) // default true
                              .setExecuteAfterPermissionGranted(
                                  true) // default true
                              .scan();
                          if (qrcode != null) {
                            callback(qrcode);
                          }
                        } catch (e) {
                          print('e ${e}');
                        }
                      },
                    );
                  },
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(10),
              child: Container(
                child: StoreConnector(
                  converter: (store) => store.state,
                  builder: (context, state) {
                    _textEditingController = _textEditingController ??
                        TextEditingController(text: state.token);
                    print('state $state');
                    if (state.token == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('未登录，请扫码登录~')],
                          )
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Image.network(
                              state.avatar_url,
                              width: 40,
                              height: 40,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(state.loginname,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textEditingController,
                                enabled: false,
                                maxLines: 1,
                                decoration: InputDecoration(
                                    labelText: 'token', hintText: '请输入token'),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            bottomNavigationBar: StoreConnector(
              converter: (store) {
                return () {
                  print('ttoken ${_textEditingController.text}');
                  return store.dispatch(removeTokenAsync(Action(
                    type: AppActions.RemoveToken,
                    success: () {
                      _textEditingController.text = '';
                      this.showSnackBar('登出成功');
                    },
                    error: () {
                      this.showSnackBar('登出失败');
                    },
                  )));
                };
              },
              builder: (context, callback) {
                if (_textEditingController.text == '') {
                  return Text('');
                }
                return Container(
                  padding: EdgeInsets.all(20),
                  child: RaisedButton(
                    onPressed: callback,
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    child: Text('登出'),
                  ),
                );
              },
            )));
  }
}
