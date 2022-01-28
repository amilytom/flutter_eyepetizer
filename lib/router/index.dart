// ignore_for_file: non_constant_identifier_names
import 'package:flutter_eyepetizer/pages/home/module.dart' show Home;
import 'package:flutter_eyepetizer/pages/reel_detaill/module.dart'
    show ReelDetaill;
import 'package:flutter_eyepetizer/pages/search/module.dart'
    show VideoSearchPage;
import 'package:flutter_eyepetizer/pages/type_detaill/module.dart'
    show TypeDetaill;
import 'package:flutter_eyepetizer/pages/user-declare/module.dart'
    show UserDeclare;
import 'package:flutter_eyepetizer/pages/video-history/module.dart'
    show VideoHistory;
import 'package:flutter_eyepetizer/pages/video_detaill/module.dart'
    show VideoDetaill;
import 'package:flutter_eyepetizer/request/http_request.dart';
import 'package:flutter_eyepetizer/router/transition.dart';
import 'package:get/get.dart';

class PageName {
  static String HOME = '/home';
  static String SEARCH = '/search';
  static String REEL_DETAILL = '/reel_detaill';
  static String VIDEO_DETAILL = '/video_detaill';
  static String TYPE_DETAILL = '/type_detaill';
  static String USER_DECLARE = '/user_declare';
  static String VIDEO_HISTORY = '/video_history';
}

class PageRoutes {
  static final String INIT_ROUTER = PageName.HOME;
  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: PageName.HOME,
      page: () => const Home(),
    ),
    GetPage(
      name: PageName.SEARCH,
      page: () => const VideoSearchPage(),
      customTransition: MyRouterEnterDirBottomToTop(),
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: PageName.REEL_DETAILL,
      page: () => const ReelDetaill(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: PageName.VIDEO_DETAILL,
      page: () => const VideoDetaill(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PageName.TYPE_DETAILL,
      page: () => const TypeDetaill(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: PageName.USER_DECLARE,
      page: () => const UserDeclare(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: PageName.VIDEO_HISTORY,
      page: () => VideoHistory(),
      customTransition: MyRouterEnterDirRightToLft(),
      transitionDuration: const Duration(milliseconds: 380),
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
