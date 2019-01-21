import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';

class TopicReply extends StatefulWidget {
  TopicReply({Key key, this.reply, this.index, this.topic}) : super(key: key);

  @override
  _TopicReplyState createState() => _TopicReplyState();
  final reply;
  final topic;
  final int index;
}

class _TopicReplyState extends State<TopicReply> {
  DateTime _now;
  @override
  Widget build(BuildContext context) {
    var reply = widget.reply;
    var topic = widget.topic;
    _now = DateTime.now();
    return StoreConnector(
      converter: (store) => store.state,
      builder: (BuildContext context, state) {
        var hasToken = state.token != null && state.token != '';
        var isOwner =
            topic['author']['loginname'] == reply['author']['loginname'];
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(.1, .1),
                  blurRadius: .1,
                  spreadRadius: 0.1)
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(
                    reply['author']['avatar_url'],
                    height: 30,
                    width: 30,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    reply['author']['loginname'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text('  ${widget.index + 1}楼'),
                                  isOwner
                                      ? Container(
                                          padding: EdgeInsets.all(3),
                                          margin: EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          child: Text(
                                            '作者',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8),
                                          ),
                                        )
                                      : Text('')
                                ],
                              ),
                              hasToken
                                  ? Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.thumb_up,
                                          size: 14,
                                        ),
                                        Text('${reply['ups'].length}')
                                      ],
                                    )
                                  : Text(''),
                            ],
                          ),
                          Text(
                            ' ${this.getTimeDiff(reply['create_at'])}',
                            style: TextStyle(fontSize: 12),
                          ),
                          MarkdownBody(
                              data: reply['content'].replaceAll(
                                  '//static.cnodejs.org',
                                  'https://static.cnodejs.org'))
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  getTimeDiff(String t) {
    var now = _now;
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
    return '刚刚';
  }
}
