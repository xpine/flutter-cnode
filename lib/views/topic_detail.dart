import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_cnode/components/index.dart' as Component;
import 'package:flutter_cnode/api/request.dart' as Request;
import 'package:flutter_cnode/views/user.dart';

var api = new Request.Api();

class Page extends StatefulWidget {
  Page({Key key, this.topicId}) : super(key: key);
  final topicId;
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  FocusNode _modalFocusNode = FocusNode();
  bool _loading = true;
  var _topic = {};
  bool _init = true;
  var _replies = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._refresh();
  }

  Future<void> _refresh() async {
    print('get topic id:${widget.topicId}');

    setState(() {
      _loading = true;
    });
    Response response =
        await api.dio.get('/topic/${widget.topicId}?mdrender=false');

    setState(() {
      _loading = false;
      _topic = response.data['data'];
      _init = false;
      _replies = _topic['replies'];
    });
  }

  showSnackBar(String text) {
    var snackbar =
        SnackBar(content: Text(text), duration: Duration(seconds: 2));

    _scaffoldkey.currentState.showSnackBar(snackbar);
  }

  // 收藏取消收藏
  changeCollect() async {
    if (_topic['is_collect'] != null && _topic['is_collect']) {
      // collected
      try {
        await api.dio.post('/topic_collect/de_collect',
            data: {'topic_id': _topic['id']});
        this.showSnackBar('取消收藏成功');
        setState(() {
          _topic['is_collect'] = false;
        });
      } catch (e) {
        this.showSnackBar('取消收藏失败');
      }
    } else {
      try {
        await api.dio
            .post('/topic_collect/collect', data: {'topic_id': _topic['id']});
        this.showSnackBar('收藏成功');
        setState(() {
          _topic['is_collect'] = true;
        });
      } catch (e) {
        this.showSnackBar('收藏失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text('话题详情'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite,
                color: (_topic['is_collect'] != null && _topic['is_collect'])
                    ? Colors.red
                    : Colors.white),
            onPressed:
                (_topic['is_collect'] != null) ? this.changeCollect : null,
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onTap: this.tapTextField,
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: InputDecoration(hintText: '请输入回复内容'),
              ),
            ),
            RaisedButton(
              onPressed: this.reply,
              child: Text('回复'),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: this._refresh,
        child: this._init
            ? Component.Spin()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: this._scrollController,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white),
                    child:
                        Text(_topic['title'], style: TextStyle(fontSize: 15)),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1, 1),
                            spreadRadius: 0.1)
                      ],
                    ),
                    child: Text(
                        '·${this.getDiffTime(_topic['create_at'])} ·作者 ${_topic['author']['loginname']} ·${_topic['visit_count']}次浏览 ·来自 ${this.getTab(_topic['tab'])}',
                        style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: MarkdownBody(
                        data: _topic['content'].replaceAll(
                            '//static.cnodejs.org',
                            'https://static.cnodejs.org')),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xfff6f6f6),
                    ),
                    child: Text('${_topic['reply_count']}回复'),
                  ),
                  StoreConnector(
                    converter: (store) => store.state,
                    builder: (BuildContext context, state) {
                      return Column(
                        children: _replies
                            .map(
                              (reply) => GestureDetector(
                                  onTap: () {
                                    if (reply['author']['loginname'] !=
                                        state.loginname) {
                                      this.tapReply(reply);
                                    }
                                  },
                                  child: Component.TopicReply(
                                    index: _replies.indexOf(reply),
                                    topic:_topic,
                                    reply: reply,
                                  )),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  tapTextField() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 500,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _textEditingController,
                    focusNode: _modalFocusNode,
                    decoration: InputDecoration(hintText: '请输入回复内容'),
                  ),
                ),
                RaisedButton(
                  onPressed: this.reply,
                  child: Text('回复'),
                ),
              ],
            ),
          );
        });
  }

  tapReply(reply) {
    print(MediaQuery.of(context).padding.bottom);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom, top: 20),
              // height: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => User(reply['author']['loginname'])));
                    },
                    child: Card(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('查看${reply['author']['loginname']}个人信息'),
                            ],
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await api.dio.post('/reply/${reply['id']}/ups');
                        Navigator.of(context).pop();
                        _refreshIndicatorKey.currentState.show();
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Card(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(reply['is_uped'] ? '取消点赞' : '点赞'),
                            ],
                          )),
                    ),
                  )
                ],
              ));
        });
  }

  reply() async {
    var text = _textEditingController.text;
    if (text != null && text != '') {
      try {
        var ret = await api.dio
            .post('/topic/${widget.topicId}/replies', data: {'content': text});
        print('reply $ret');
        _textEditingController.text = '';
        _focusNode.unfocus();
        _modalFocusNode.unfocus();
        _refreshIndicatorKey.currentState.show();
      } catch (e) {
        print('reply $e');
      }
    }
  }

  getDiffTime(String t) {
    var now = DateTime.now();
    var tString = DateTime.parse(t);
    var timestamp = tString.microsecondsSinceEpoch;
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    if (diff.inDays != 0) {
      return '发布于 ${diff.inDays}天前';
    }
    if (diff.inHours != 0) {
      return '发布于 ${diff.inHours}小时前';
    }
    if (diff.inMinutes != 0) {
      return '发布于 ${diff.inMinutes}分钟前';
    }
    if (diff.inSeconds != 0) {
      return '发布于 ${diff.inSeconds}秒前';
    }
  }

  getTab(String t) {
    const map = {'dev': '测试', 'ask': '问答', 'share': '分享', 'good': '精华'};
    return map[t];
  }
}
