import 'package:flutter/material.dart';
import 'package:flutter_cnode/views/topic_detail.dart' as TopicDetail;

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
    return GestureDetector(
        onTap: ()=> 
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_)=> TopicDetail.Page(topicId: topic['id'],)
            )
          )
        ,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1, 1),
                  blurRadius: 1.0,
                  spreadRadius: 0.3)
            ],
            // border: Border(bottom: BorderSide(color: Colors.grey))
          ),
          
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  children: [
                    this.renderTag(topic),
                    Expanded(
                      child: Text(
                        topic['title'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                      ),
                    )
                  ],
                )
              ),
              Row(children: <Widget>[
                Image.network(
                  topic['author']['avatar_url'],
                  width: 30.0,
                  height: 30.0,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 5.0,right: 5.0),
                    child: Text('${topic['author']['loginname']}'),
                  ),
                ),
                Container(
                    width: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('${topic['reply_count']}',
                            style: TextStyle(color: Colors.purple)),
                        Text('/'),
                        Text('${topic['visit_count']}')
                      ],
                    )),
                Text(this.getTimeDiff(topic['last_reply_at'])),
              ]),
            ]
          )
        ));
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
      } else if(tab =='dev'){
        text = '测试';
      }
    }
    return Container(
      color: bgColor,
      margin: EdgeInsets.only(right: 5.0),
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      child: Text(text, style: TextStyle(color: color,fontSize: 11)),
    );
  }
}
