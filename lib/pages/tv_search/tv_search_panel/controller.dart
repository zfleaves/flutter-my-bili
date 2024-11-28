import 'package:bilibili/http/tv.dart';
import 'package:bilibili/models/tv/tv.dart';
import 'package:bilibili/models/tv/tv_search_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvSearchPanelController extends GetxController {
  final ScrollController scrollController = ScrollController();
  TvSearchPanelController({required this.st});
  int st;
  RxString key  = 'tv'.obs; // 类型
  RxString area  = '-1'.obs; // 区域
  RxString styleId  = '-1'.obs; // 风格
  dynamic releaseDate  = '-1'; // 日期
  RxString seasonStatus  = '-1'.obs; // 付费
  RxString producerId  = '-1'.obs; // 出品
  RxInt order  = 0.obs;
  RxInt sort  = 0.obs;
  RxInt hasNext = 1.obs;
  final pagesize = 10;
  RxInt page = 1.obs;
  RxList<TVSearchItemModel> list = <TVSearchItemModel>[].obs;

  // 初始化参数配置
  initParams(TvSearchModel tvSearchModel) { 
    key.value = tvSearchModel.key;
    if (tvSearchModel.areaList != null) {
      area.value = tvSearchModel.areaList!.first.area;
    }
    styleId.value = tvSearchModel.styleList.first.styleId;
    if (tvSearchModel.yearList != null) {
      releaseDate = tvSearchModel.yearList!.first.releaseDate;
    }
    seasonStatus.value = tvSearchModel.payTypeList.first.seasonStatus;
    if (tvSearchModel.key == 'documentary') {
      producerId.value = tvSearchModel.productList!.first.producerId;
    }
    order.value = tvSearchModel.orderList.first.order;
    sort.value = tvSearchModel.orderList.first.sort;
  }

  // 查询电影、电视剧、综艺、纪录片列表
  Future queryTvSearchList({type = 'init'}) async {
    if (type == 'onLoad' && hasNext.value == 0) {
      // noMore.value = '没有更多了';
      return;
    }
    if (type == 'onRefresh') {
      page.value = 1;
    }
    var result = await TVhttp.tvSeasonList(
      key: key.value,
      st: st,
      area: area.value,
      styleId: styleId.value,
      releaseDate: releaseDate,
      seasonStatus: seasonStatus.value,
      order: order.value,
      sort: sort.value,
      page: page.value,
      pagesize: pagesize,
      producerId: producerId.value
    );
    if (result['status']) {
      if (type == 'init' || type == 'onRefresh') {
        list.value = result['data'].list ?? [];
      } else {
        list.addAll(result['data'].list ?? []);
      }
      hasNext.value = result['data'].hasNext;
      page.value++;
    }
    return result;
  }

  // 上拉加载
  Future onLoad() async {
    queryTvSearchList(type: 'onLoad');
  }

  // 下拉刷新
  Future onRefresh() async {
    queryTvSearchList(type: 'onRefresh');
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