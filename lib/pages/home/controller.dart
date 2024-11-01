import 'dart:async';

import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/common/tab_type.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hive/hive.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  bool flag = false;
  late RxList tabs = [].obs;
  RxInt initialIndex = 1.obs;
  late TabController tabController;
  late List tabsCtrList;
  late List<Widget> tabsPageList;
  Box userInfoCache = GStrorage.userInfo;
  Box settingStorage = GStrorage.setting;
  RxBool userLogin = false.obs;
  RxString userFace = ''.obs;
  var userInfo;
  Box setting = GStrorage.setting;
  late final StreamController<bool> searchBarStream =
      StreamController<bool>.broadcast();
  late bool hideSearchBar;
  late List defaultTabs;
  late List<String> tabbarSort;
  RxString defaultSearch = ''.obs;
  late bool enableGradientBg;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    userFace.value = userInfo != null ? userInfo.face : '';
    hideSearchBar =
        setting.get(SettingBoxKey.hideSearchBar, defaultValue: true);
    if (setting.get(SettingBoxKey.enableSearchWord, defaultValue: true)) {
      searchDefault();
    }
    enableGradientBg =
        setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
    // 进行tabs配置
    setTabConfig();
  }

  void onRefresh() {
    int index = tabController.index;
    var ctr = tabsCtrList[index];
    ctr().onRefresh();
  }

  void animateToTop() {
    int index = tabController.index;
    var ctr = tabsCtrList[index];
    ctr().animateToTop();
  }
  // 更新登录状态
  void updateLoginStatus(val) async {
    userInfo = await userInfoCache.get('userInfoCache');
    userLogin.value = val ?? false;
    if (val) return;
    userFace.value = userInfo != null ? userInfo.face : '';
  }

  void setTabConfig() async {
    defaultTabs = [...tabsConfig];
    tabbarSort = settingStorage.get(SettingBoxKey.tabbarSort,
        defaultValue: ['live', 'rcmd', 'hot', 'bangumi']);
    // 如果item['type'].id在tabbarSort中，则item会被保留；否则，item会被移除
    defaultTabs.retainWhere(
        (item) => tabbarSort.contains((item['type'] as TabType).id));
    defaultTabs.sort((a, b) => tabbarSort
        .indexOf((a['type'] as TabType).id)
        .compareTo(tabbarSort.indexOf((b['type'] as TabType).id)));
    tabs.value = defaultTabs;
    if (tabbarSort.contains(TabType.rcmd.id)) {
      initialIndex.value = tabbarSort.indexOf(TabType.rcmd.id);
    } else {
      initialIndex.value = 0;
    }
    tabsCtrList = tabs.map((e) => e['ctr']).toList();
    print(tabsCtrList);
    tabsPageList = tabs.map<Widget>((e) => e['page']).toList();
    tabController = TabController(
        initialIndex: initialIndex.value, length: tabs.length, vsync: this);
    // 监听 tabController 切换
    if (enableGradientBg) {
      tabController.animation!.addListener(() {
        if (tabController.indexIsChanging) {
          if (initialIndex.value != tabController.index) {
            initialIndex.value = tabController.index;
          }
        } else {
          final int temp = tabController.animation!.value.round();
          if (initialIndex.value != temp) {
            initialIndex.value = temp;
            tabController.index = initialIndex.value;
          }
        }
      });
    }
  }

  // 默认搜索结果
  void searchDefault() async {
    var res = await Request().get(Api.searchDefault);
    if (res.data['code'] == 0) {
      defaultSearch.value = res.data['data']['name'];
    }
  }

  @override
  void onClose() {
    searchBarStream.close();
    super.onClose();
  }
}
