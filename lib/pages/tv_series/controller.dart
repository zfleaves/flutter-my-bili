import 'package:bilibili/http/tv.dart';
import 'package:bilibili/models/tv/hit_show.dart';
import 'package:bilibili/models/tv/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvSeriesController extends GetxController {
  bool flag = false;
  final ScrollController scrollController = ScrollController();
  RxList<TvItemData> tvList = <TvItemData>[].obs;
  RxList<HitShowItemData> hitShowList = <HitShowItemData>[].obs;
  RxString noMore = ''.obs;
  int coursor = 0;
  bool hasNext = true;

  // 查询电视剧热播列表
  Future queryTvListHit({seasonType = 5}) async {
    var result = await TVhttp.hitShowList(seasonType: seasonType);
    if (result['status']) {
      hitShowList.value = result['data'].list;
    }
    return result;
  }

  // 查询推荐列表
  Future queryTvListFeed({type = 'init'}) async {
    if (type == 'onLoad' && !hasNext) {
      noMore.value = '没有更多了';
      return;
    }
    if (type == 'onRefresh') {
      hasNext = true;
      coursor = 0;
    }
    var result = await TVhttp.tvList(coursor: coursor);
    if (result['status']) {
      if (type == 'init') {
        tvList.value = result['data'].items;
      } else if (type == 'onRefresh') {
        tvList.clear();
        tvList.addAll(result['data'].items);
      } else {
        tvList.addAll(result['data'].items);
      }
      coursor += 14;
      hasNext = result['data'].hasNext;
    }
    print('tvList-${tvList.length}-hasNext-$hasNext');
    return result;
  }

  // 上拉加载
  Future onLoad() async {
    queryTvListFeed(type: 'onLoad');
  }

  // 下拉刷新
  Future onRefresh() async {
    queryTvListFeed(type: 'onRefresh');
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
