import 'package:bilibili/http/user.dart';
import 'package:bilibili/models/model_hot_video_item.dart';
import 'package:bilibili/models/user/info.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LaterController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HotVideoItemModel> laterList = <HotVideoItemModel>[].obs;
  int count = 0;
  RxBool isLoading = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
  }

  Future queryLaterList() async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    isLoading.value = true;
    var res = await UserHttp.seeYouLater();
    if (res['status']) {
      count = res['data']['count'];
      if (count > 0) {
        laterList.value = res['data']['list'];
      }
    }
    isLoading.value = false;
    return res;
  }

  Future toViewDel({int? aid}) async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (context) {
        return AlertDialog(
            title: const Text('提示'),
            content: Text(
                aid != null ? '即将移除该视频，确定是否移除' : '即将删除所有已观看视频，此操作不可恢复。确定是否删除？'),
            actions: [
              TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text(
                  '取消',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var res = await UserHttp.toViewDel(aid: aid);
                  if (res['status']) {
                    if (aid != null) {
                      laterList.removeWhere((e) => e.aid == aid);
                    } else {
                      laterList.clear();
                      queryLaterList();
                    }
                  }
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res['msg']);
                },
                child: Text(aid != null ? '确认移除' : '确认删除'),
              )
            ]);
      },
    );
  }

  // 一键清空
  Future toViewClear() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空确认'),
          content: const Text('确定要清空你的稍后再看列表吗？'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                var res = await UserHttp.toViewClear();
                if (res['status']) {
                  laterList.clear();
                }
                SmartDialog.dismiss();
                SmartDialog.showToast(res['msg']);
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}
