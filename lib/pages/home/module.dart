// ignore_for_file: must_call_super, non_constant_identifier_names
import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// appbar view
import 'package:flutter_eyepetizer/pages/home/appbar/home/module.dart';
import 'package:flutter_eyepetizer/pages/home/appbar/explore/module.dart';
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
  final _pageController = PageController(initialPage: 0);

  final List<Widget> _TabBarBodyItems = [
    const AppBarTabHome(),
    const AppBarTabExplore(),
    const AppBarTabPopular(),
    const AppBarTabUser(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        bottomNavigationBar: BottomBar(
          selectedIndex: _curPage,
          onTap: (int index) {
            _pageController.jumpToPage(index);
            setState(() => _curPage = index);
          },
          items: <BottomBarItem>[
            BottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text('首页'),
              activeColor: Colors.blue,
            ),
            BottomBarItem(
              icon: const Icon(Icons.explore),
              title: const Text('发现'),
              activeColor: Colors.red,
              darkActiveColor: Colors.red.shade400, // Optional
            ),
            BottomBarItem(
              icon: const Icon(Icons.local_fire_department),
              title: const Text('热门'),
              activeColor: Colors.greenAccent.shade700,
              darkActiveColor: Colors.greenAccent.shade400, // Optional
            ),
            BottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text('我的'),
              activeColor: Colors.orange,
            ),
          ],
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
