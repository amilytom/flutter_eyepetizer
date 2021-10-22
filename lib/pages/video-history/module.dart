// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print
import 'package:flutter/material.dart';
// components
import 'package:flutter_eyepetizer/components/video_factory.dart';
// glabel controller
import 'package:flutter_eyepetizer/service/video_history.dart';
// widget
import 'package:flutter_eyepetizer/utils/toast.dart';
import 'package:flutter_eyepetizer/widget/img_state.dart';
import 'package:flutter_eyepetizer/widget/my_button.dart';
import 'package:flutter_eyepetizer/widget/my_state.dart';
import 'package:get/get.dart';

class VideoHistory extends StatelessWidget {
  VideoHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistoryService historyService = Get.put(HistoryService());
    // 读取全局控制器中的历史记录
    List<Widget> _buildStoreVideoList() {
      return historyService.hisList.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: VideoFactory(
            id: e["id"]!,
            playUrl: e["playUrl"]!,
            authorDes: e["authorDes"]!,
            authorName: e["authorName"]!,
            avatarUrl: e["avatarUrl"]!,
            subTime: e["subTime"]!,
            desText: e["desText"]!,
            title: e["title"]!,
            typeName: e["typeName"]!,
            videoPoster: e["videoPoster"]!,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12),
                  top: BorderSide(color: Colors.black12),
                  right: BorderSide(color: Colors.black12),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: FadeInImage(
                      fadeOutDuration: const Duration(milliseconds: 50),
                      fadeInDuration: const Duration(milliseconds: 50),
                      placeholder: const AssetImage('images/movie-lazy.gif'),
                      image: NetworkImage(e["videoPoster"]),
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
                            e["title"],
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e["desText"],
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
      }).toList();
    }

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text("历史记录"),
          actions: [
            MyIconButton(
              icon: const Icon(Icons.restore_from_trash),
              cb: () {
                historyService.removeKey("history").then((res) {
                  publicToast("删除成功");
                  historyService.hisList = [].obs;
                }).catchError((err) {
                  print(err);
                  publicToast("删除失败");
                });
              },
            ),
          ],
        ),
        body: historyService.hisList.isNotEmpty
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: Column(
                    children: _buildStoreVideoList(),
                  ),
                ),
              )
            : MyState(
                cb: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.new_releases,
                  size: 100,
                  color: Colors.red,
                ),
                text: "暂无内容 ╮(╯▽╰)╭",
                btnText: '点击退出',
              ),
      ),
    );
  }
}
