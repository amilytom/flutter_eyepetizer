// ignore_for_file: must_call_super, non_constant_identifier_names
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_eyepetizer/pages/home/appbar/explore/module.dart';
// appbar view
import 'package:flutter_eyepetizer/pages/home/appbar/home/module.dart';
import 'package:flutter_eyepetizer/pages/home/appbar/popular/module.dart';
import 'package:flutter_eyepetizer/pages/home/appbar/user/module.dart';
// utils
import 'package:flutter_eyepetizer/utils/toast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  DateTime? lastPopTime;
  int _curPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _TabBarBodyItems = [
    const AppBarTabHome(),
    const AppBarTabExplore(),
    const AppBarTabPopular(),
    const AppBarTabUser(),
  ];

  final List<TabItem<dynamic>> _TabBarItems = [
    const TabItem(icon: Icons.home, title: '首页'),
    const TabItem(icon: Icons.explore, title: '发现'),
    const TabItem(icon: Icons.local_fire_department, title: '热门'),
    const TabItem(icon: Icons.person, title: '我的'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        bottomNavigationBar: ConvexAppBar(
          height: 60,
          color: Colors.white,
          items: _TabBarItems,
          initialActiveIndex: _curPage, //optional, default as 0
          onTap: (int i) {
            setState(() {
              _curPage = i;
            });
            _pageController.jumpToPage(i);
          },
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _TabBarBodyItems,
        ),
      ),
      onWillPop: () async {
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime!) >
                const Duration(seconds: 2)) {
          // 存储当前按下back键的时间
          lastPopTime = DateTime.now();
          // toast
          publicToast("再按一次退出app");
          return false;
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
