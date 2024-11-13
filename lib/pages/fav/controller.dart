import 'package:bilibili/http/user.dart';
import 'package:bilibili/models/user/fav_folder.dart';
import 'package:bilibili/models/user/info.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class FavController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  RxList<FavFolderItemData> favFolderList = <FavFolderItemData>[].obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;
  int currentPage = 1;
  int pageSize = 60;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    userInfo = userInfoCache.get('userInfoCache');
    super.onInit();
  }

  Future<dynamic> queryFavFolder({type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    if (!hasMore.value) {
      return;
    }
    var res = await UserHttp.userfavFolder(
      pn: currentPage,
      ps: pageSize,
      mid: userInfo!.mid!,
    );
    if (res['status']) {
      if (type == 'init') {
        favFolderData.value = res['data'];
        favFolderList.value = res['data'].list;
      } else {
        if (res['data'].list.isNotEmpty) {
          favFolderList.addAll(res['data'].list);
          favFolderData.update((val) {});
        }
      }
      hasMore.value = res['data'].hasMore;
      currentPage++;
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  Future onLoad() async {
    queryFavFolder(type: 'onload');
  }

  removeFavFolder({required int mediaIds}) async {
    for (var i in favFolderList) {
      if (i.id == mediaIds) {
        favFolderList.remove(i);
        break;
      }
    }
  }
}