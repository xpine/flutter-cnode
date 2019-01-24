import 'package:flutter/material.dart';
import 'dart:async';

class Message extends StatefulWidget implements PreferredSizeWidget {
  Message({Key key, @required this.child}) : super(key: key);
  final AppBar child;
  @override
  Size get preferredSize => Size.fromHeight(child.preferredSize.height);
  @override
  State<StatefulWidget> createState() {
    return MessageState();
  }
}

class MessageState extends State<Message> {
  double _top;
  Widget _messsage;
  @override
  Widget build(BuildContext context) {
    var height =
        MediaQuery.of(context).padding.top + widget.child.preferredSize.height;
    return Stack(
      children: <Widget>[
        widget.child,
        AnimatedPositioned(
            duration: Duration(seconds: 1),
            top: _top ?? -height,
            left: 0,
            right: 0,
            height: height,
            child: Container(
                padding:EdgeInsets.only(top:MediaQuery.of(context).padding.top),
                color: Colors.lightGreen,
                child: Center(
                  child: _messsage,
                ))),
      ],
    );
  }

  show({Widget child}) {
    var height =
        MediaQuery.of(context).padding.top + widget.child.preferredSize.height;
    setState(() {
      _top = 0;
      _messsage = child;
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _top = -height;
        _messsage = Text('');
      });
    });
  }
}
