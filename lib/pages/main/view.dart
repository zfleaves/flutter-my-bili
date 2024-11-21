import 'dart:async';

import 'package:bilibili/models/common/dynamic_badge_mode.dart';
import 'package:bilibili/pages/dynamics/index.dart';
import 'package:bilibili/pages/home/index.dart';
import 'package:bilibili/pages/main/index.dart';
import 'package:bilibili/pages/media/index.dart';
import 'package:bilibili/pages/rank/index.dart';
import 'package:bilibili/utils/event_bus.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/global_data.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final MainController _mainController = Get.put(MainController());
  final HomeController _homeController = Get.put(HomeController());
  final RankController _rankController = Get.put(RankController());
  final DynamicsController _dynamicController = Get.put(DynamicsController());
  final MediaController _mediaController = Get.put(MediaController());

  int? _lastSelectTime; // 上次点击时间
  Box setting = GStrorage.setting;

  @override
  void initState() {
    super.initState();
    _lastSelectTime = DateTime.now().microsecondsSinceEpoch;
    _mainController.pageController =
        PageController(initialPage: _mainController.selectedIndex);
    // print(_mainController.navigationBars);
    // print(GlobalData().enableMYBar);
  }

  void setIndex(int value) async {
    setState(() {
      _mainController.selectedIndex = value;
    });
    feedBack();
    _mainController.pageController.jumpToPage(value);
    var currentPage = _mainController.pages[value];
    if (currentPage is HomePage) {
      if (_homeController.flag) {
        // 单击返回顶部 双击并刷新
        if (DateTime.now().microsecondsSinceEpoch - _lastSelectTime! < 500) {
          _homeController.onRefresh();
        } else {
          _homeController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _homeController.flag = true;
    } else {
      _homeController.flag = false;
    }

    if (currentPage is RankPage) {
      if (_rankController.flag) {
        // 单击返回顶部 双击并刷新
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _rankController.onRefresh();
        } else {
          _rankController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _rankController.flag = true;
    } else {
      _rankController.flag = false;
    }

    if (currentPage is DynamicsPage) {
      if (_dynamicController.flag) {
        // 单击返回顶部 双击并刷新
        if (DateTime.now().millisecondsSinceEpoch - _lastSelectTime! < 500) {
          _dynamicController.onRefresh();
        } else {
          _dynamicController.animateToTop();
        }
        _lastSelectTime = DateTime.now().millisecondsSinceEpoch;
      }
      _dynamicController.flag = true;
      _mainController.clearUnread();
    } else {
      _dynamicController.flag = false;
    }

    if (currentPage is MediaPage) {
      _mediaController.queryFavFolder();
    }
  }

  @override
  void dispose() async {
    await GStrorage.close();
    EventBus().off(EventName.loginEvent);
    super.dispose();
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
        onDestinationSelected: (value) => setIndex(value),
        selectedIndex: _mainController.selectedIndex,
        // indicatorColor: Colors.red,
        destinations: <Widget>[
          ..._mainController.navigationBars.map((e) {
            return NavigationDestination(
              icon: Badge(
                label: _mainController.dynamicBadgeType.value ==
                        DynamicBadgeMode.number
                    ? Text(e['count'].toString())
                    : null,
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                isLabelVisible: _mainController.dynamicBadgeType.value !=
                        DynamicBadgeMode.hidden &&
                    e['count'] > 0,
                child: e['icon'],
              ),
              selectedIcon: e['selectIcon'],
              label: e['label'],
            );
          })
        ]);
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _mainController.selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (value) => setIndex(value),
      iconSize: 16,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        ..._mainController.navigationBars.map((e) {
          return BottomNavigationBarItem(
            icon: Badge(
              label: _mainController.dynamicBadgeType.value ==
                      DynamicBadgeMode.number
                  ? Text(e['count'].toString())
                  : null,
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
              isLabelVisible: _mainController.dynamicBadgeType.value !=
                      DynamicBadgeMode.hidden &&
                  e['count'] > 0,
              child: e['icon'],
            ),
            activeIcon: e['selectIcon'],
            label: e['label'],
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Box localCache = GStrorage.localCache;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double sheetHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.of(context).padding.top -
        MediaQuery.sizeOf(context).width * 9 / 16;
    localCache.put('sheetHeight', sheetHeight);
    localCache.put('statusBarHeight', statusBarHeight);
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, dynamic) {
          _mainController.onBackPressed(context);
        },
        child: Scaffold(
            extendBody: true,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _mainController.pageController,
              onPageChanged: (int index) {
                _mainController.selectedIndex = index;
              },
              children: _mainController.pages,
            ),
            // bottomNavigationBar: AnimatedSlide(
            //   curve: Curves.easeInOutCubicEmphasized,
            //   duration: const Duration(milliseconds: 500),
            //   offset: const Offset(0, 0),
            //   child: GlobalData().enableMYBar
            //       ? Obx(() => _buildNavigationBar())
            //       : Obx(() => _buildBottomNavigationBar()),
            // )
            bottomNavigationBar: _mainController.navigationBars.length > 1
                ? StreamBuilder(
                    stream: _mainController.hideTabBar
                        ? _mainController.bottomBarStream.stream.distinct()
                        : StreamController<bool>.broadcast().stream,
                    builder: (context, AsyncSnapshot snapshot) {
                      bool flag = snapshot.data ?? true;
                      return AnimatedSlide(
                        curve: Curves.easeInOutCubicEmphasized,
                        duration: const Duration(milliseconds: 500),
                        offset: Offset(0, flag ? 0 : 1),
                        // offset: const Offset(0, 1),
                        // 您使用 Obx 来包裹 _buildNavigationBar() 和 _buildBottomNavigationBar()，
                        //这表明这些函数依赖于响应式变量。请确保这些变量在更改时确实触发了 UI 更新。
                        child: GlobalData().enableMYBar
                            ? Obx(() => _buildNavigationBar())
                            : Obx(() => _buildBottomNavigationBar()),
                      );
                    },
                  )
                : null,
            ));
  }
}
