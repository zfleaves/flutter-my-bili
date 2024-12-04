import 'package:bilibili/http/movie.dart';
import 'package:bilibili/http/user.dart';
import 'package:bilibili/http/video.dart';
import 'package:bilibili/models/common/sub_type.dart';
import 'package:bilibili/models/movie/movie_line.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MovieLineController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<MovieLineItem> movieLineList = <MovieLineItem>[].obs;

  dynamic userInfo;
  Box userInfoCache = GStrorage.userInfo;
  List followList = [];

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
  }

  // 查询电影上映列表
  Future queryMovieLine() async {
    var result = await Moviehttp.movieLineList();
    if (result['status']) {
      await queryFollowList();
      for (var i = 0; i < result['data'].items.length; i++) {
        var item = result['data'].items[i];
        if (followList == []) break;
        int index = followList.indexWhere((val) => val.seasonId == item.seasonId);
        item.follow = index >= 0 ? 1 : 0;
      }
      movieLineList.value = result['data'].items;
    }
    return result;
  }

  // 查询追剧列表
  Future queryFollowList() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      followList = [];
      return;
    }
    followList = [];
    int page = 1;
    await querySubFolderList(page);
  }

  // 查询我的追剧列表
  Future querySubFolderList(int page) async {
    var result = await UserHttp.userCustomSubFolder(
      subType: SubType.video,
      pn: page,
      ps: 20,
      mid: userInfo.mid,
      followStatus: 0
    );
    if (result['status']) {
      followList.addAll(result['data'].list);
      if (followList.length < result['data'].total) {
        page = page + 1;
        await querySubFolderList(page);
      }
    }
  }


  // 追剧/取消追剧
  Future updateSub(dynamic movieItem) async {
    dynamic res;
    String msg = movieItem.follow == 1 ? '已取消追剧' : '追剧成功';
    if (movieItem.follow == 1) {
      res = await UserHttp.delSub(
        seasonId: movieItem.seasonId,
        seasonType: movieItem.seasonType
      );
    } else {
      res = await VideoHttp.bangumiAdd(seasonId: movieItem.seasonId);
    }
    // print(res);
    if (res['status']) {
      for (var i in movieLineList) {
      if (i.seasonId == movieItem.seasonId) {
        i.follow = i.follow == 1 ? 0 : 1;
        break;
      }
      movieLineList.refresh();
      SmartDialog.showToast(msg);
    }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}