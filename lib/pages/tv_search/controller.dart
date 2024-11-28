import 'package:bilibili/models/tv/tv_search_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvSearchController extends GetxController with GetTickerProviderStateMixin {
  String type = '';
  RxInt initialIndex = 0.obs;
  late TabController tabController;
  RxList<TvSearchModel> typeList = <TvSearchModel>[].obs;
  

  @override
  void onInit() {
    super.onInit();
    type = Get.parameters['type'] ?? 'tv';
    for (String key in TvSearch.keys) {
      typeList.add(TvSearch[key]!);
    }
    initialIndex.value = typeList.indexWhere((item) => item.key == type);
    tabController = TabController(
      initialIndex: initialIndex.value,
      length: typeList.length,
      vsync: this,
    );
  }

}