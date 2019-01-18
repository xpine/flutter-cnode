import 'package:flutter/material.dart';

class TopicReply extends StatefulWidget {
  TopicReply({Key key, this.reply}) : super(key: key);

  @override
  _TopicReplyState createState() => _TopicReplyState();
  final reply;
}

class _TopicReplyState extends State<TopicReply> {
  @override
  Widget build(BuildContext context) {
    var reply = widget.reply;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.network(reply['author']['avatar_url'],height: 30,),
              Text(reply['author']['loginname'])
            ],
          )
        ],
      ),
    );
  }
}
