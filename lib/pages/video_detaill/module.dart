// ignore_for_file: unnecessary_brace_in_string_interps, must_call_super, non_constant_identifier_names, avoid_print
import 'dart:async';
import 'dart:ui';
//
import 'package:dio/dio.dart';
import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//
import 'package:flutter_eyepetizer/components/video_banner.dart';
import 'package:flutter_eyepetizer/components/video_factory.dart';
//
//
import 'package:flutter_eyepetizer/request/api_response.dart';
import 'package:flutter_eyepetizer/request/http_utils.dart';
//
import 'package:flutter_eyepetizer/schema/video_related.dart';
//
import 'package:flutter_eyepetizer/service/video_history.dart';
//
import 'package:flutter_eyepetizer/utils/api.dart';
import 'package:flutter_eyepetizer/utils/toast.dart';
//
import 'package:flutter_eyepetizer/widget/img_state.dart';
import 'package:flutter_eyepetizer/widget/my_loading.dart';
import 'package:flutter_eyepetizer/widget/my_state.dart';
import 'package:get/get.dart';

class VideoDetaill extends StatefulWidget {
  const VideoDetaill({Key? key}) : super(key: key);

  @override
  _VideoDetaillState createState() => _VideoDetaillState();
}

class _VideoDetaillState extends State<VideoDetaill>
    with AutomaticKeepAliveClientMixin {
  final BetterVideoPlayerController controller = BetterVideoPlayerController();
  late StreamSubscription playerEventSubscription;
  //
  bool isShowPlayer = false;
  //
  String curPlayUrl = Get.parameters["playUrl"]!;
  String videoId = Get.parameters["id"]!;
  String title = Get.parameters["title"]!;
  String typeName = Get.parameters["typeName"]!;
  String desText = Get.parameters["desText"]!;
  String subTime = Get.parameters["subTime"]!;
  String avatarUrl = Get.parameters["avatarUrl"]!;
  String authorDes = Get.parameters["authorDes"]!;
  String authorName = Get.parameters["authorName"]!;
  String videoPoster = Get.parameters["videoPoster"]!;
  bool isNotAuthor = Get.parameters["avatarUrl"]!.isEmpty ? true : false;

  // 全局控制器
  HistoryService historyService = Get.put(HistoryService());

  @override
  void initState() {
    super.initState();
    // 设置播放源
    playerEventSubscription = controller.playerEventStream.listen((event) {
      print("wang $event");
    });
    // 加入历史记录
    historyService.add(
      id: videoId,
      playUrl: curPlayUrl,
      title: title,
      typeName: typeName,
      desText: desText,
      subTime: subTime,
      avatarUrl: avatarUrl,
      authorDes: authorDes,
      authorName: authorName,
      videoPoster: videoPoster,
    );
    // if (Platform.isAndroid) {
    //   //设置Android头部的导航栏透明
    //   SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    //     statusBarColor: Colors.black, //全局设置透明
    //     statusBarIconBrightness: Brightness.light,
    //     //light:黑色图标 dark：白色图标
    //     //在此处设置statusBarIconBrightness为全局设置
    //   );
    //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    // }
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    playerEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQueryData.fromWindow(window).padding.top,
            color: Colors.black,
          ),
          Hero(
            tag: videoId,
            child: AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: BetterVideoPlayer(
                controller: controller,
                configuration: BetterVideoPlayerConfiguration(
                  placeholder: Image.network(
                    videoPoster,
                    fit: BoxFit.contain,
                  ),
                ),
                dataSource: BetterVideoPlayerDataSource(
                  BetterVideoPlayerDataSourceType.network,
                  curPlayUrl,
                ),
              ),
            ),
          ),
          VideoInfo(
            id: videoId,
            title: title,
            typeName: typeName,
            desText: desText,
            subTime: subTime,
            avatarUrl: avatarUrl,
            authorDes: authorDes,
            authorName: authorName,
            isNotAuthor: isNotAuthor,
            player: controller,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VideoInfo extends StatefulWidget {
  final String id;
  final String title;
  final String typeName;
  final String desText;
  final String subTime;
  final String avatarUrl;
  final String authorName;
  final String authorDes;
  final bool isNotAuthor;
  final BetterVideoPlayerController player;
  const VideoInfo({
    Key? key,
    required this.id,
    required this.title,
    required this.typeName,
    required this.desText,
    required this.subTime,
    required this.avatarUrl,
    required this.authorName,
    required this.authorDes,
    required this.isNotAuthor,
    required this.player,
  }) : super(key: key);

  @override
  _VideoInfoState createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo>
    with AutomaticKeepAliveClientMixin {
  String get id => widget.id;
  bool get isNotAuthor => widget.isNotAuthor;
  BetterVideoPlayerController get player => widget.player;
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  String nextPageUrl = Api.getRelatedData;
  final List<VideoRelatedItemList?> _itemList = [];

  Future<ApiResponse<VideoRelated>> getVideoRelatedData() async {
    try {
      dynamic response = await HttpUtils.get('${nextPageUrl}?id=${id}');
      print(response);
      VideoRelated data = VideoRelated.fromJson(response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _pullData() async {
    ApiResponse<VideoRelated> relatedResponse = await getVideoRelatedData();
    if (!mounted) {
      return;
    }
    if (relatedResponse.status == Status.COMPLETED) {
      setState(() {
        stateCode = 1;
        _itemList.addAll(relatedResponse.data!.itemList!);
      });
    } else if (relatedResponse.status == Status.ERROR) {
      setState(() {
        stateCode = 2;
      });
      String errMsg = relatedResponse.exception!.getMessage();
      publicToast(errMsg);
      print("发生错误，位置video_detaill， url: ${nextPageUrl}?id=${id}");
    }
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyView;
    if (stateCode == 0) {
      bodyView = Container(
        alignment: Alignment.center,
        child: const MyLoading(message: "加载中"),
      );
    } else if (stateCode == 1) {
      bodyView = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  // 标题
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // 类型
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '类型： ${widget.typeName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // 介绍
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      widget.desText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            !isNotAuthor
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: VideoBanner(
                      avatarUrl: widget.avatarUrl,
                      rowTitle: widget.authorName,
                      rowDes: widget.authorDes,
                      slotChild: Container(),
                    ),
                  )
                : Container(),
            Divider(height: isNotAuthor ? 0 : 1),
            Column(
              children: _itemList.map((e) {
                return VideoFactory(
                  id: e!.data!.id!.toString(),
                  playUrl: e.data!.playUrl!,
                  title: e.data!.title!,
                  typeName: e.data!.category!,
                  desText: e.data!.description!,
                  subTime:
                      DateTime.fromMillisecondsSinceEpoch(e.data!.releaseTime!)
                          .toString()
                          .substring(0, 19),
                  avatarUrl:
                      e.data!.author != null ? e.data!.author!.icon! : "",
                  authorDes: e.data!.author != null
                      ? e.data!.author!.description!
                      : "",
                  authorName:
                      e.data!.author != null ? e.data!.author!.name! : "",
                  videoPoster: e.data!.cover!.feed!,
                  isPopCurRoute: true,
                  routerPopEnter: () async {
                    await player.pause();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: FadeInImage(
                              fadeOutDuration: const Duration(milliseconds: 50),
                              fadeInDuration: const Duration(milliseconds: 50),
                              placeholder:
                                  const AssetImage('images/movie-lazy.gif'),
                              image: NetworkImage(e.data!.cover!.feed!),
                              imageErrorBuilder: (context, obj, trace) {
                                return ImgState(
                                  msg: "加载失败",
                                  icon: Icons.broken_image,
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.data!.title!,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    e.data!.description!,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      );
    } else if (stateCode == 2) {
      bodyView = Container(
        alignment: Alignment.center,
        child: MyState(
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            await _pullData();
          },
          icon: const Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "数据加载失败",
          btnText: "点击重试",
        ),
      );
    } else {
      bodyView = Container();
    }
    return Expanded(
      child: bodyView,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
