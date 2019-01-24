import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

import 'package:flutter_cnode/views/topic_list.dart' as TopicList;
import 'package:flutter_cnode/components/index.dart' as Component;
import 'package:flutter_cnode/views/create_topic.dart';
import 'package:flutter_cnode/views/user.dart';
import 'package:flutter_cnode/views/collection.dart';
import 'package:flutter_cnode/store/store.dart';
import 'package:flutter_cnode/actions/app_actions.dart';

// final String token = '12';
void main() async {
  runApp(MyApp(
    store: await createStore(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, this.store});
  final Store store;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
          title: 'CNode社区',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.green,
          ),
          home: MyHomePage(title: 'CNode社区'),
          // routes: {
          //   '/login': (BuildContext context) => Login(),
          // },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  GlobalKey<Component.MessageState> _messagekey =
      new GlobalKey<Component.MessageState>();
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  int _selectedIndex = 0;
  PageController _pageController;

  final _widgetOptions = [
    TopicList.Page(key: ObjectKey('all'), tab: ''),
    TopicList.Page(
      key: ObjectKey('good'),
      tab: 'good',
    ),
    TopicList.Page(
      key: ObjectKey('share'),
      tab: 'share',
    ),
    TopicList.Page(key: ObjectKey('ask'), tab: 'ask'),
    TopicList.Page(key: ObjectKey('dev'), tab: 'dev'),
  ];
  showMessage(String text) {
    _messagekey.currentState.show(child:Text(text,style: TextStyle(
      color: Colors.white,
      fontSize: 16
    ),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: StoreConnector(
        converter: (store) => store.state,
        builder: (BuildContext context, state) {
          return Container(
            width: 280,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    state.loginname ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                  accountEmail: Text(''),
                  currentAccountPicture: CircleAvatar(
                    child: Image.network(state.avatar_url ??
                        'https://avatars2.githubusercontent.com/u/26139327?v=4&s=120'),
                  ),
                  otherAccountsPictures: <Widget>[
                    this.buildLoginBtn(state),
                  ],
                ),
                Container(
                  child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.account_box)),
                      title: Text('个人信息'),
                      onTap: () {
                        if (state.loginname != null && state.loginname != '') {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => User(state.loginname)));
                        }
                      }),
                ),
                ClipRect(
                  child: ListTile(
                    leading:
                        CircleAvatar(child: Icon(Icons.collections_bookmark)),
                    title: Text('我的收藏'),
                    onTap: () {
                      if (state.loginname != null && state.loginname != '') {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => Collection(state.loginname)));
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      appBar: Component.Message(
        key: _messagekey,
        child: AppBar(
          title: Text(widget.title),
        ),
      ),
      body: PageView(
        children: this._widgetOptions,
        onPageChanged: this._onPageChanged,
        controller: this._pageController,
      ),
      // Container(
      //   child: _widgetOptions.elementAt(_selectedIndex),
      // ),
      floatingActionButton: StoreConnector(
        converter: (store) => store.state,
        builder: (BuildContext context, state) {
          var hasToken = state.token != null && state.token != '';
          if (hasToken) {
            return FloatingActionButton(
              child: Icon(Icons.create),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CreateTopic()));
              },
            );
          } else {
            return Text('');
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.all_out), title: Text('全部')),
          BottomNavigationBarItem(icon: Icon(Icons.brush), title: Text('精华')),
          BottomNavigationBarItem(icon: Icon(Icons.share), title: Text('分享')),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer), title: Text('问答')),
          BottomNavigationBarItem(
              icon: Icon(Icons.developer_mode), title: Text('测试')),
        ],
        currentIndex: this._selectedIndex,
        fixedColor: Theme.of(context).accentColor,
        onTap: this._onItemTapped,
      ),
    );
  }

  buildLoginBtn(state) {
    return StoreConnector(
      converter: (store) {
        if (state.token != null) {
          return () {
            return store.dispatch(removeTokenAsync(Action(
              type: AppActions.RemoveToken,
              success: () {
                Navigator.of(context).pop();
                
                this.showMessage('登出成功');
              },
              error: () {
                this.showMessage('登出失败');
              },
            )));
          };
        } else {
          return (String qrcode) {
            print('ttoken $qrcode');
            return store.dispatch(updateTokenAsync(Action(
                type: AppActions.UpdateToken,
                success: () {
                  Navigator.of(context).pop();
                  this.showMessage('登录成功');
                },
                error: () {
                  this.showMessage('登录失败，请重试');
                },
                payload: qrcode)));
          };
        }
      },
      builder: (BuildContext context, callback) {
        if (state.token != null) {
          return GestureDetector(
            onTap: callback,
            child: Container(
              child: Text(
                '登出',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          return IconButton(
            color: Colors.white,
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              try {
                String qrcode = await QRCodeReader()
                    .setAutoFocusIntervalInMs(200) // default 5000
                    .setForceAutoFocus(true) // default false
                    .setTorchEnabled(true) // default false
                    .setHandlePermissions(true) // default true
                    .setExecuteAfterPermissionGranted(true) // default true
                    .scan();
                if (qrcode != null) {
                  callback(qrcode);
                }
              } catch (e) {
                print('e ${e}');
              }
            },
          );
        }
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    // _pageController.animateToPage(index,
    //     duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Timer _timer;
  // 放置bottombar抖动
  _onPageChanged(int index) {
    if (_timer != null) {
      _timer.cancel();
    }
    print('pageChanged $index');
    _timer = Timer(Duration(milliseconds: 400), () {
      setState(() {
        _selectedIndex = index;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
