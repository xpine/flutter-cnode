import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_cnode/components/index.dart' as Component;
import 'package:flutter_cnode/api/request.dart' as Request;

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
  ScrollController _scrollController = new ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('topic'),
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
                  Column(
                    children: _replies
                        .map((reply) => Component.TopicReply(
                              index:_replies.indexOf(reply),
                              reply: reply,
                            ))
                        .toList(),
                  ),
                ],
              ),
      ),
    );
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
