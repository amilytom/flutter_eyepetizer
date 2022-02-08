import 'package:flutter_eyepetizer/pages/home/module.dart' show Home;
import 'package:flutter_eyepetizer/pages/reel_detaill/module.dart'
    show ReelDetaill;
import 'package:flutter_eyepetizer/pages/search/module.dart'
    show VideoSearchPage;
import 'package:flutter_eyepetizer/pages/type_detaill/module.dart'
    show TypeDetaill;
import 'package:flutter_eyepetizer/pages/user-declare/module.dart'
    show UserDeclare;
import 'package:flutter_eyepetizer/pages/video-history/controller.dart';
import 'package:flutter_eyepetizer/pages/video-history/module.dart'
    show VideoHistory;
import 'package:flutter_eyepetizer/pages/video_detaill/module.dart'
    show VideoDetaill;
import 'package:flutter_eyepetizer/request/http_request.dart';
import 'package:flutter_eyepetizer/router/transition.dart';
import 'package:get/get.dart';

class PageName {
  static String home = '/home';
  static String search = '/search';
  static String reelDetaill = '/reel_detaill';
  static String videoDetaill = '/video_detaill';
  static String typeDetaill = '/type_detaill';
  static String userDeclare = '/user_declare';
  static String videoHistory = '/video_history';
}

class PageRoutes {
  static final String initRoute = PageName.home;
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: PageName.home,
      page: () => const Home(),
    ),
    GetPage(
      name: PageName.search,
      page: () => const VideoSearchPage(),
      customTransition: MyRouterEnterDirBottomToTop(),
      transitionDuration: const Duration(milliseconds: 370),
    ),
    GetPage(
      name: PageName.reelDetaill,
      page: () => const ReelDetaill(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 370),
    ),
    GetPage(
      name: PageName.videoDetaill,
      page: () => const VideoDetaill(),
      customTransition: MyRouterEnterDirBottomToTop(),
      transitionDuration: const Duration(milliseconds: 370),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PageName.typeDetaill,
      page: () => const TypeDetaill(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 370),
    ),
    GetPage(
      name: PageName.userDeclare,
      page: () => const UserDeclare(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 370),
    ),
    GetPage(
      name: PageName.videoHistory,
      page: () => const VideoHistory(),
      binding: BindingsBuilder.put(() => VideoHistoryStore()),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 370),
    ),
  ];
  static addRouter({
    required String routeName,
    Map<String, String>? parameters,
  }) async {
    // 先清除所有的dio cancel
    Http().cancelRequests();
    // 再router入栈
    Get.toNamed(
      routeName,
      parameters: parameters,
    );
  }
}
