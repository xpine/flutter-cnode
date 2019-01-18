import 'package:flutter/material.dart';

class TopicCard extends StatefulWidget {
  TopicCard({Key key, this.topic}) : super(key: key);

  @override
  _TopicCardState createState() => _TopicCardState();
  final topic;
}

class _TopicCardState extends State<TopicCard> {
  @override
  Widget build(BuildContext context) {
    var topic = widget.topic;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(children: <Widget>[
        Image.network(
          topic['author']['avatar_url'],
          width: 30.0,
          height: 30.0,
        ),
        Container(
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${topic['reply_count']}',
                    style: TextStyle(color: Colors.purple)),
                Text('/'),
                Text('${topic['visit_count']}')
              ],
            )),
        this.renderTag(topic),
        Expanded(
            child: Container(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            topic['title'],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )),
        Text('1天前')
      ]),
    );
  }

  renderTag(topic) {
    var text = '默认';
    Color bgColor = Color(0xffe5e5e5);
    Color color = Color(0xff666666);
    if (topic['top']) {
      text = '置顶';
      bgColor = Colors.lightGreen;
      color = Colors.white;
    } else if (topic['good']) {
      text = '精华';
      bgColor = Colors.lightGreen;
      color = Colors.white;
    } else {
      var tab = topic['tab'];
      if (tab == 'share') {
        text = '分享';
      } else if (tab == 'ask') {
        text = '问答';
      }
    }

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}
