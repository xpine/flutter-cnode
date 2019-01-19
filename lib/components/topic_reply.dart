import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TopicReply extends StatefulWidget {
  TopicReply({Key key, this.reply, this.index}) : super(key: key);

  @override
  _TopicReplyState createState() => _TopicReplyState();
  final reply;
  final int index;
}

class _TopicReplyState extends State<TopicReply> {
  @override
  Widget build(BuildContext context) {
    var reply = widget.reply;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.blueGrey)),
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
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text('  ${widget.index + 1}楼'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => {},
                                child: Icon(
                                  Icons.thumb_up,
                                  size: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => {},
                                child: Icon(
                                  Icons.reply,
                                  size: 14,
                                ),
                              ),
                            ],
                          )
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
