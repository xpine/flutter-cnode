import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cnode/api/request.dart' as Request;
import 'package:flutter_cnode/components/index.dart' as Component;
class Page extends StatefulWidget {
  final tab;
  Page({Key key, this.tab}) : super(key: key);
  @override
  _PageState createState() => _PageState();
}

var api = new Request.Api();

class _PageState extends State<Page> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    super.initState();
    this._refresh();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels < 50.0) {
        this._loadMore();
      }
    });
  }

  bool init = true;
  int page = 1;
  int limit = 20;
  bool loading = false;
  bool hasMore = true;
  var topics = [];
  Future<void> _refresh() async {
    this.page = 1;
    this.hasMore = true;
    print('refresh');
    Response response = await api.dio
        .get('/topics?limit=${this.limit}&page=${this.page}&tab=${widget.tab}');
    if (this.mounted) {
      setState(() {
        this.topics = response.data['data'];
        this.init = false;
        print(this.topics.length);
      });
    }
  }

  Future<void> _loadMore() async {
    this.page = this.page + 1;
    if (this.loading && this.hasMore) {
      return;
    }
    print('loadmore');
    setState(() {
      this.loading = true;
    });
    Response response = await api.dio
        .get('/topics?limit=${this.limit}&page=${this.page}&tab=${widget.tab}');
    this.loading = false;
    if (this.mounted) {
      setState(() {
        var nextTopics = response.data['data'];
        if (nextTopics.length < this.limit) {
          this.hasMore = false;
        }
        this.topics.addAll(nextTopics);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(this.loading);
    if (this.init) {
      return Component.Spin();
    }
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: this._refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: this._scrollController,
        children: [
          Column(
            children: this
                .topics
                .map((topic) => Component.TopicCard(
                      topic: topic,
                    ))
                .toList(),
          ),
          Container(
            child: this.loading? Component.Spin():null
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
