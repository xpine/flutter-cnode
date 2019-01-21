import 'package:flutter/material.dart';
import 'package:flutter_cnode/api/request.dart' as Request;
import 'package:flutter_cnode/components/index.dart' as Component;

var api = new Request.Api();

class Collection extends StatefulWidget {
  Collection(this.loginname) : super();
  @override
  State<StatefulWidget> createState() {
    return _CollectionState();
  }

  final String loginname;
}

class _CollectionState extends State<Collection> {
  bool _init = true;
  List _collections = [];
  Future<void> _onRefresh() async {
    try {
      var ret = await api.dio.get('/topic_collect/${widget.loginname}');
      setState(() {
        _init = false;
        _collections = ret.data['data'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    this._onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
      ),
      body: this._init
          ? Component.Spin()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                  children: _collections
                      .map((topic) => Component.TopicCard(
                            topic: topic,
                          ))
                      .toList()),
            ),
    );
  }
}
