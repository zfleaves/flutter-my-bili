import 'dart:async';

import 'package:bilibili/http/common.dart';
import 'package:bilibili/models/common/dynamic_badge_mode.dart';
import 'package:bilibili/models/common/nav_bar_config.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MainController extends GetxController {
  List<Widget> pages = <Widget>[];
  RxList navigationBars = [].obs;
  late List defaultNavTabs;
  late List<int> navBarSort;
  final StreamController<bool> bottomBarStream = StreamController<bool>.broadcast();
  Box setting = GStrorage.setting;
  DateTime? _lastPressedAt;
  late bool hideTabBar;
  late PageController pageController;
  int selectedIndex = 0;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  late Rx<DynamicBadgeMode> dynamicBadgeType = DynamicBadgeMode.number.obs;


  @override
  void onInit() {
    super.onInit();
    if (setting.get(SettingBoxKey.autoUpdate, defaultValue: false)) {
      Utils.checkUpdata();
    };
    // hideTabBar = setting.get(SettingBoxKey.hideTabBar, defaultValue: false);
    hideTabBar = setting.get(SettingBoxKey.hideTabBar, defaultValue: true);
    var userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    dynamicBadgeType.value = DynamicBadgeMode.values[setting.get(
        SettingBoxKey.dynamicBadgeMode,
        defaultValue: DynamicBadgeMode.number.code)];
    setNavBarConfig();
    if (dynamicBadgeType.value != DynamicBadgeMode.hidden) {
      getUnreadDynamic();
    }
  }

  void onBackPressed(BuildContext context) {
    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // 两次点击时间间隔超过2秒，重新记录时间戳
      _lastPressedAt = DateTime.now();
      if (selectedIndex != 0) {
        pageController.jumpTo(0);
      }
      SmartDialog.showToast('再按一次退出Bili');
      return;
    }
    SystemNavigator.pop(); // 退出应用
  }

  // 更新未读动态
  void getUnreadDynamic() async {
    if (!userLogin.value) {
      return;
    }
    int dynamicItemIndex = navigationBars.indexWhere((item) => item['label'] == '动态');
    var res = await CommonHttp.unReadDynamic();
    var data = res['data'];
    if (dynamicItemIndex != -1) {
      navigationBars[dynamicItemIndex]['count'] = data == null ? 0 : data.length; // 修改 count 属性为新的值
    }
    navigationBars.refresh();
  }

  void clearUnread() async {
    int dynamicItemIndex =
        navigationBars.indexWhere((item) => item['label'] == "动态");
    if (dynamicItemIndex != -1) {
      navigationBars[dynamicItemIndex]['count'] = 0; // 修改 count 属性为新的值
    }
    navigationBars.refresh();
  }

  void setNavBarConfig() async {
    defaultNavTabs = [...defaultNavigationBars];
    navBarSort = setting.get(SettingBoxKey.navBarSort, defaultValue: [0, 1, 2, 3]);
    defaultNavTabs.retainWhere((item) => navBarSort.contains(item['id']));
    defaultNavTabs.sort((a, b) =>
        navBarSort.indexOf(a['id']).compareTo(navBarSort.indexOf(b['id'])));
    navigationBars.value = defaultNavTabs;
    int defaultHomePage =
        setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0) as int;
    int defaultIndex =
        navigationBars.indexWhere((item) => item['id'] == defaultHomePage);
    // 如果找不到匹配项，默认索引设置为0或其他合适的值
    selectedIndex = defaultIndex != -1 ? defaultIndex : 0;
    pages = navigationBars.map<Widget>((e) => e['page']).toList();
  }

  @override
  void onClose() {
    bottomBarStream.close();
    super.onClose();
  }
}