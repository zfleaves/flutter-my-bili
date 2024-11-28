import 'package:bilibili/http/tv.dart';
import 'package:bilibili/models/tv/tv_rank_type.dart';
import 'package:bilibili/models/tv/hit_show.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvRankTopController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HitShowItemData> hitShowList = <HitShowItemData>[].obs;
  RxList rankTabs = [].obs;
  int tabIndex = 4;
  RxInt seasonType = 5.obs;

  @override
  void onInit() {
    super.onInit();
    rankTabs.value = TvRankType.values
        .map((type) => {'label': type.label, 'id': type.id, 'seasonType': type.seasonType})
        .toList();
  }

  // 查询电视剧热播列表
  Future queryTvListHit() async {
    var result = await TVhttp.hitShowList(seasonType: seasonType.value);
    if (result['status']) {
      hitShowList.value = result['data'].list;
    }
    return result;
  }

  // 下拉刷新
  Future onRefresh() async {
    hitShowList.clear();
    queryTvListHit();
  }

   // 返回顶部并刷新
  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}