import 'package:flutter/material.dart';
import 'package:flutter_cnode/api/request.dart' as Request;
import 'package:flutter_cnode/components/index.dart' as Component;
import 'package:flutter_cnode/views/topic_detail.dart' as TopicDetail;

var api = new Request.Api();

class User extends StatefulWidget {
  User(this.loginname, {Key key})
      : assert(loginname != null),
        super(key: key);
  @override
  State<StatefulWidget> createState() => _UserState();
  final String loginname;
}

class _UserState extends State<User> {
  bool _init = true;
  var _user;
  List _isExpand = [false, false];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._onRefresh();
  }

  Future<void> _onRefresh() async {
    try {
      var ret = await api.dio.get('/user/${widget.loginname}');
      setState(() {
        _init = false;
        _user = ret.data['data'];
      });
      print(ret);
    } catch (e) {}
  }

  formatDateTime(String t) {
    var date = DateTime.parse(t);
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loginname),
      ),
      body: this._init
          ? Component.Spin()
          : RefreshIndicator(
              onRefresh: this._onRefresh,
              child: Container(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.network(
                          _user['avatar_url'],
                          width: 50,
                          height: 50,
                        ),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                widget.loginname,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              )),
                        ),
                        Text('注册于${this.formatDateTime(_user['create_at'])}'),
                      ],
                    ),
                    Container(
                      height: 20,
                    ),
                    ExpansionPanelList(
                      expansionCallback: (index, isExpand) {
                        print('index $index isExpand $isExpand');
                        setState(() {
                          _isExpand[index] = !isExpand;
                        });
                      },
                      children: [
                        ExpansionPanel(
                            isExpanded: _isExpand[0],
                            headerBuilder: (BuildContext context, isExpand) {
                              return Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: <Widget>[Text('最近创建的主题')],
                                ),
                              );
                            },
                            body: this.buildTopic(_user['recent_topics'])),
                        ExpansionPanel(
                            isExpanded: _isExpand[1],
                            headerBuilder: (BuildContext context, isExpand) {
                              return Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: <Widget>[Text('最近创建的主题')],
                                ),
                              );
                            },
                            body: this.buildTopic(_user['recent_replies']))
                      ],
                    ),
                  ],
                ),
              )),
    );
  }

  buildTopic(List topicList) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey))),
          padding: EdgeInsets.all(10),
          child: Column(
              children: topicList.map((topic) {
            return GestureDetector(
              onTap: ()=> 
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_)=> TopicDetail.Page(topicId: topic['id'],)
                  )
                )
              ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(topic['title']),
                  ),
                  Row(
                    children: <Widget>[
                      Image.network(
                        topic['author']['avatar_url'],
                        width: 30.0,
                        height: 30.0,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Text('${topic['author']['loginname']}'),
                        ),
                      ),
                      Text(this.getTimeDiff(topic['last_reply_at'])),
                    ],
                  )
                ],
              ),
            );
          }).toList()),
        )),
      ],
    );
  }

  getTimeDiff(String t) {
    var now = DateTime.now();
    var tString = DateTime.parse(t);
    var timestamp = tString.microsecondsSinceEpoch;
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    if (diff.inDays != 0) {
      return '${diff.inDays}天前';
    }
    if (diff.inHours != 0) {
      return '${diff.inHours}小时前';
    }
    if (diff.inMinutes != 0) {
      return '${diff.inMinutes}分钟前';
    }
    if (diff.inSeconds != 0) {
      return '${diff.inSeconds}秒前';
    }
  }
}
