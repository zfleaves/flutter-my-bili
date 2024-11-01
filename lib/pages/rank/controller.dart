import 'dart:async';

import 'package:bilibili/models/common/rank_type.dart';
import 'package:bilibili/pages/rank/zone/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class RankController extends GetxController with GetTickerProviderStateMixin {
  bool flag = false;
  late RxList tabs = [].obs;
  RxInt initialIndex = 0.obs;
  late TabController tabController;
  late List tabsCtrList;
  late List<Widget> tabsPageList;
  Box setting = GStrorage.setting;
  late final StreamController<bool> searchBarStream =
      StreamController<bool>.broadcast();
  late bool enableGradientBg;

  @override
  void onInit() {
    super.onInit();
    enableGradientBg =
        setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
    // 进行tabs配置
    setTabConfig();
  }

  void onRefresh() {
    int index = tabController.index;
    final ZoneController ctr = tabsCtrList[index];
    ctr.onRefresh();
  }

  void animateToTop() {
    int index = tabController.index;
    final ZoneController ctr = tabsCtrList[index];
    ctr.animateToTop();
  }

  void setTabConfig() async {
    tabs.value = tabsConfig;
    initialIndex.value = 0;
    tabsCtrList = tabs
        .map((e) => Get.put(ZoneController(), tag: e['rid'].toString()))
        .toList();
    tabsPageList = tabs.map<Widget>((e) => e['page']).toList();

    tabController = TabController(
      initialIndex: initialIndex.value,
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void onClose() {
    searchBarStream.close();
    super.onClose();
  }
}