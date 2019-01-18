import 'package:flutter/material.dart';
import 'package:flutter_cnode/api/request.dart' as Request;
import 'package:dio/dio.dart';
import 'package:flutter_cnode/components/index.dart' as Component;

class Page extends StatefulWidget {
  Page({Key key}) : super(key: key);
  @override
  _PageState createState() => _PageState();
}

var api = new Request.Api();

class _PageState extends State<Page> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    this._refresh();
  }

  String page = '1';
  String limit = '1';
  String tab = '';
  Future<void> _refresh() async {
    Response response = await api.dio.get('/topics?limit=20', data: {
      "page":1,
      "limit":20
    });
    if (this.mounted) {
      setState(() {
        this.topics = response.data['data'];
        print(this.topics.length);
      });
    }
  }

  var topics = [];
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: this._refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: this
            .topics
            .map((topic) => Component.TopicCard(
                  topic: topic,
                ))
            .toList(),
      ),
    );
  }
}
