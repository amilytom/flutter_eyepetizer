import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//
import 'package:flutter_eyepetizer/components/image_extends.dart';
import 'package:flutter_eyepetizer/components/video_banner.dart';
import 'package:flutter_eyepetizer/components/video_factory.dart';
//
import 'package:flutter_eyepetizer/request/api_response.dart';
import 'package:flutter_eyepetizer/request/http_utils.dart';
//
import 'package:flutter_eyepetizer/router/index.dart';
//
import 'package:flutter_eyepetizer/schema/popular_coll.dart';
//
import 'package:flutter_eyepetizer/utils/api.dart';
import 'package:flutter_eyepetizer/utils/toast.dart';
//
import 'package:flutter_eyepetizer/widget/my_button.dart';
import 'package:flutter_eyepetizer/widget/my_loading.dart';
import 'package:flutter_eyepetizer/widget/my_state.dart';

PopularColl fromJson(dynamic response) => PopularColl.fromJson(response);

class AppBarTabPopular extends StatefulWidget {
  const AppBarTabPopular({Key? key}) : super(key: key);

  @override
  _AppBarTabPopularState createState() => _AppBarTabPopularState();
}

class _AppBarTabPopularState extends State<AppBarTabPopular>
    with AutomaticKeepAliveClientMixin {
  static const List<String> tabUrlList = [
    Api.getWeekRankList,
    Api.getMonthRankList,
    Api.getHistoryRankList,
  ];
  static const List<String> tabNameList = [
    "周排行",
    "月排行",
    "总排行",
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: tabUrlList.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 8.0,
          leading: Container(),
          title: Container(
            alignment: Alignment.center,
            child: const Text("热门"),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                PageRoutes.addRouter(routeName: PageName.search);
              },
            ),
          ],
          bottom: TabBar(
            tabs: tabNameList.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabUrlList.map((e) => TabBarItemCart(e)).toList(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TabBarItemCart extends StatefulWidget {
  final String url;
  const TabBarItemCart(this.url, {Key? key}) : super(key: key);

  @override
  _TabBarItemCartState createState() => _TabBarItemCartState();
}

class _TabBarItemCartState extends State<TabBarItemCart>
    with AutomaticKeepAliveClientMixin {
  String get url => widget.url;

  bool? isInit;
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  List<PopularCollItemList?> _itemList = [];
  String? initPageUrl = "";
  String? nextPageUrl = "";
  bool isShowFloatBtn = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  Future<ApiResponse<PopularColl>> getFollowData() async {
    try {
      dynamic response = await HttpUtils.get(nextPageUrl!);
      // print(response);
      PopularColl data = await compute(fromJson, response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      // print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _refresh() async {
    initPageUrl = nextPageUrl = url;
    _refreshController.refreshCompleted(resetFooterState: true);
    nextPageUrl = initPageUrl;
    await _loading(true);
  }

  Future<void> _loading([bool isReset = false]) async {
    ApiResponse<PopularColl> itemResponse = await getFollowData();
    _setRefreshState(itemResponse);
    if (!mounted) {
      return;
    }
    if (itemResponse.status == Status.completed) {
      setState(() {
        if (isReset) {
          _itemList = [];
        }
        isInit = isInit ?? true;
        stateCode = 1;
        nextPageUrl = itemResponse.data!.nextPageUrl;
        _itemList.addAll(itemResponse.data!.itemList!);
      });
    } else if (itemResponse.status == Status.error) {
      setState(() {
        stateCode = isInit == true ? 1 : 2;
      });
      String errMsg = itemResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置home bottomBar3 => 热门， url: $nextPageUrl");
    }
  }

  void _setRefreshState(ApiResponse<PopularColl> res) {
    if (!mounted) return;
    if (res.status == Status.completed && res.data!.nextPageUrl == null) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  void _initScrollEvent() {
    _scrollController.addListener(() {
      if (_scrollController.offset < 1000 && isShowFloatBtn) {
        setState(() {
          isShowFloatBtn = false;
        });
      } else if (_scrollController.offset >= 1000 && isShowFloatBtn == false) {
        setState(() {
          isShowFloatBtn = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _initScrollEvent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget body;
    if (stateCode == 0) {
      body = const MyLoading(message: "加载中");
    } else if (stateCode == 1) {
      body = SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        footer: CustomFooter(
          builder: (context, mode) {
            Widget? body;
            if (mode == LoadStatus.idle) {
              body = const Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 20),
                  Text('内容加载中'),
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("松手,加载更多！");
            } else if (mode == LoadStatus.noMore) {
              body = const Text("没有更多数据了！");
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: ListView.builder(
          itemBuilder: (BuildContext ctx, int idx) {
            bool isNotExistAuthor =
                _itemList[idx]!.data!.author == null ? true : false;
            String videoTitle = _itemList[idx]!.data!.title ?? "暂无";
            String videoCategory = _itemList[idx]!.data!.category ?? "暂无";
            String videoPoster = _itemList[idx]!.data!.cover!.feed ?? "";
            return Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 0, top: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 210,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: VideoFactory(
                            id: _itemList[idx]!.data!.id!.toString(),
                            playUrl: _itemList[idx]!.data!.playUrl ?? "",
                            title: _itemList[idx]!.data!.title ?? "暂无",
                            typeName: _itemList[idx]!.data!.category ?? "暂无",
                            desText: _itemList[idx]!.data!.description ?? "暂无",
                            subTime: _itemList[idx]!.data!.releaseTime != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                        _itemList[idx]!.data!.releaseTime!)
                                    .toString()
                                    .substring(0, 19)
                                : "暂无",
                            avatarUrl: _itemList[idx]!.data!.author != null
                                ? (_itemList[idx]!.data!.author!.icon ?? "")
                                : "",
                            authorDes: _itemList[idx]!.data!.author != null
                                ? (_itemList[idx]!.data!.author!.description ??
                                    "暂无")
                                : "暂无",
                            authorName: _itemList[idx]!.data!.author != null
                                ? (_itemList[idx]!.data!.author!.name ?? "暂无")
                                : "暂无",
                            videoPoster: videoPoster,
                            child: ImageExends(
                              imgUrl: videoPoster,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                            ),
                            child: Text(
                              videoCategory,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VideoBanner(
                    avatarUrl: _itemList[idx]!.data!.author!.icon ?? "",
                    rowTitle: videoTitle,
                    isAssets: isNotExistAuthor,
                    rowDes: _itemList[idx]!.data!.author!.name ?? "暂无",
                    slotChild: MyIconButton(
                      icon: const Icon(
                        Icons.share,
                        size: 30,
                        color: Colors.black54,
                      ),
                      cb: () {},
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.black12,
                  ),
                ],
              ),
            );
          },
          // itemExtent: 100.0,
          itemCount: _itemList.length,
          controller: _scrollController,
        ),
        onRefresh: _refresh,
        onLoading: _loading,
        controller: _refreshController,
      );
    } else if (stateCode == 2) {
      body = MyState(
        cb: () async {
          setState(() {
            stateCode = 0;
          });
          // 重新加载
          await _refresh();
        },
        icon: const Icon(
          Icons.new_releases,
          size: 100,
          color: Colors.red,
        ),
        text: "数据加载失败",
        btnText: '点击重试',
      );
    } else {
      body = Container();
    }
    return Scaffold(
      floatingActionButton: isShowFloatBtn
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  .0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: body,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
