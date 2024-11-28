import 'dart:ffi';

import 'package:bilibili/http/tv.dart';
import 'package:bilibili/http/user.dart';
import 'package:bilibili/http/video.dart';
import 'package:bilibili/models/tv/tv_navhide.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class TvNavhideController extends GetxController {
  Rx<UpInfo> upInfo = UpInfo().obs;
  RxInt isFollowed = 0.obs;
  RxString appBarTitle = ''.obs;
  String id = '';
  RxString followedMsg = '未关注'.obs;
  RxString summary = ''.obs;
  RxString title = ''.obs;
  RxString total = ''.obs;
  RxList<TvNavhideItem> navhideList = <TvNavhideItem>[].obs;
  dynamic userInfo;
  Box userInfoCache = GStrorage.userInfo;
  late Map followMap;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    appBarTitle.value = Get.parameters['title'] ?? 'B站出品';
    id = Get.parameters['id']!;
  }

  // 查询电视剧热播列表
  Future queryTvNavhideList() async {
    try {
      var result = await TVhttp.tvNavhideList(id: int.parse(id));
      if (result['status']) {
        followMap = await queryFollowList(
            seasonIds: result['data']
                .seasons
                .map((item) => item.seasonId)
                .toList()
                .join(','));
        for (var i = 0; i < result['data'].seasons.length; i++) {
          var item = result['data'].seasons[i];
          item.isFollow = followMap[item.seasonId.toString()]['is_follow'];
        }
        navhideList.value = result['data'].seasons;
        upInfo.value = result['data'].upInfo;
        isFollowed.value = upInfo.value.isFollow ?? 0;
        followedMsg.value = isFollowed.value == 1 ? '已关注' : '未关注';
        // print(isFollowed.value);
        // print(followedMsg.value);
        summary.value = result['data'].summary;
        title.value = result['data'].title;
        total.value = result['data'].total;
      }
      return result;
    } catch (err) {
      print(err);
      return null;
    }
  }

  // 查询追剧列表
  Future queryFollowList({required String seasonIds}) async {
    var result = await TVhttp.queryFollowList(seasonIds: seasonIds);
    return result['data'];
  }

  Future updateSub(dynamic tvItem) async {
    var res;
    String msg = tvItem.isFollow == 1 ? '已取消追剧' : '追剧成功';
    if (tvItem.isFollow == 1) {
      res = await UserHttp.delSub(
        seasonId: tvItem.seasonId,
        seasonType: tvItem.seasonType
      );
    } else {
      res = await VideoHttp.bangumiAdd(seasonId: tvItem.seasonId);
    }
    // print(res);
    if (res['status']) {
      for (var i in navhideList) {
      if (i.seasonId == tvItem.seasonId) {
        i.isFollow = i.isFollow == 1 ? 0 : 1;
        break;
      }
      navhideList.refresh();
      SmartDialog.showToast(msg);
    }
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 关注/取关up
  Future actionRelationMod() async {
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }

    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          // ignore: invalid_use_of_protected_member
          content: Text(upInfo.value.isFollow == 1 ? '取消关注UP主?' : '关注UP主?'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                await VideoHttp.relationMod(
                  mid: upInfo.value.mid ?? 0,
                  act: isFollowed.value == 1 ? 2 : 1,
                  reSrc: 11,
                );
                SmartDialog.dismiss();
                // queryTvNavhideList();
                isFollowed.value = isFollowed.value == 1 ? 0 : 1;
                followedMsg.value = isFollowed.value == 1 ? '已关注' : '未关注';
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}
