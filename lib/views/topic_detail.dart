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
  GlobalKey<Component.MessageState> _messagekey =
      new GlobalKey<Component.MessageState>();
  GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  FocusNode _modalFocusNode;
  DateTime _now;
  var _topic = {};
  bool _init = true;
  var _replies = [];
  @override
  void initState() {
    super.initState();
    this._refresh();
  }

  Future<void> _refresh() async {
    print('get topic id:${widget.topicId}');
    Response response =
        await api.dio.get('/topic/${widget.topicId}?mdrender=false');

    setState(() {
      _topic = response.data['data'];
      _init = false;
      _replies = _topic['replies'];
      _now = DateTime.now();
    });
  }

  showMessage(String text) {
    _messagekey.currentState.show(
        child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ));
  }

  // 收藏取消收藏
  changeCollect() async {
    if (_topic['is_collect'] != null && _topic['is_collect']) {
      // collected
      try {
        await api.dio.post('/topic_collect/de_collect',
            data: {'topic_id': _topic['id']});
        this.showMessage('取消收藏成功');
        setState(() {
          _topic['is_collect'] = false;
        });
      } catch (e) {
        this.showMessage('取消收藏失败');
      }
    } else {
      try {
        await api.dio
            .post('/topic_collect/collect', data: {'topic_id': _topic['id']});
        this.showMessage('收藏成功');
        setState(() {
          _topic['is_collect'] = true;
        });
      } catch (e) {
        this.showMessage('收藏失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: Component.Message(
          key: _messagekey,
          child: AppBar(
            title: Text('话题详情'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.favorite,
                    color:
                        (_topic['is_collect'] != null && _topic['is_collect'])
                            ? Colors.red
                            : Colors.white),
                onPressed:
                    (_topic['is_collect'] != null) ? this.changeCollect : null,
              )
            ],
          )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 1.0,
                spreadRadius: 0.3)
          ],
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onTap: this.tapTextField,
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: InputDecoration(hintText: '请输入回复内容',contentPadding: EdgeInsets.all(8)),
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
                                    topic: _topic,
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
    _focusNode.unfocus();
    this._modalFocusNode = FocusNode();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 385,
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    onSubmitted: (val) {
                      Navigator.of(context).pop();
                    },
                    autofocus: true,
                    controller: _textEditingController,
                    focusNode: _modalFocusNode,
                    decoration: InputDecoration(hintText: '请输入回复内容',contentPadding: EdgeInsets.all(10)),
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
                        var ret =
                            await api.dio.post('/reply/${reply['id']}/ups');
                        var action = ret.data['action'];

                        var text = action == 'down' ? '取消点赞' : '点赞';
                        Navigator.of(context).pop();
                        this.showMessage('$text成功');
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
    Navigator.of(context).pop();
    var text = _textEditingController.text;
    if (text != null && text != '') {
      try {
        var ret = await api.dio
            .post('/topic/${widget.topicId}/replies', data: {'content': text});
        print('reply $ret');

        _textEditingController.text = '';
        _modalFocusNode.unfocus();
        _refreshIndicatorKey.currentState.show();
        this.showMessage('回复成功');
      } catch (e) {
        print('reply $e');
      }
    }
  }

  getDiffTime(String t) {
    var now = _now;
    print(now);
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
