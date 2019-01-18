import 'package:flutter/material.dart';
import 'package:flutter_cnode/views/topic_list.dart' as TopicList;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter CNode'),
      routes: {},
    );
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
  @override
  void initState() {
    // TODO: implement initState
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
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        children: _widgetOptions,
        controller: this._pageController,
      ),
      // Container(
      //   child: _widgetOptions.elementAt(_selectedIndex),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.all_out), title: Text('全部')),
          BottomNavigationBarItem(icon: Icon(Icons.brush), title: Text('精华')),
          BottomNavigationBarItem(icon: Icon(Icons.share), title: Text('分享')),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer), title: Text('问答')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blue[500],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
