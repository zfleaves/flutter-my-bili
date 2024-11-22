import 'package:bilibili/http/user.dart';
import 'package:bilibili/models/common/sub_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SubPanelController extends GetxController {
  SubPanelController({this.subType, this.mid});
  SubType? subType;
  int? mid;

  ScrollController scrollController = ScrollController();

  int pageSize = 20;
  RxInt page = 1.obs;
  RxList resultList = [].obs;

  int tabIndex = 0;
  RxList subFilterTabs = [].obs;
  RxInt selectedType = 0.obs;

  @override
  void onInit() {
    super.onInit();
    subFilterTabs.value = SubFilterType.values
        .map((type) =>
            {'label': type.label, 'id': type.id, 'followStatus': type.followStatus})
        .toList();
  }

  Future onSearch({type = 'init'}) async {
    print(type);
    var result = await UserHttp.userCustomSubFolder(
      subType: subType!,
      pn: page.value,
      ps: pageSize,
      mid: mid!,
      followStatus: selectedType.value
    );
    if (result['status']) {
      if (type == 'onRefresh') {
        resultList.value = result['data'].list ?? [];
      } else {
        resultList.addAll(result['data'].list ?? []);
      }
      page.value++;
    }
    return result;
  }

  Future onRefresh() async {
    page.value = 1;
    await onSearch(type: 'onRefresh');
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

  // 操作
  handleOperate(dynamic videoItem, int followStatus, String tips) async {
    if (followStatus == -1) {
      delSub(videoItem, followStatus, tips);
      return;
    };
    updateSubStatus(videoItem, followStatus, tips);
  }

  Future<void> updateSubStatus(dynamic videoItem, int followStatus,  String tips) async {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text('确定$tips？'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              var res = await UserHttp.userUpdateSubFolder(
                seasonId: videoItem.seasonId,
                status: followStatus
              );
              if (res['status']) {
                if (selectedType.value == 0) {
                  for (var i in resultList) {
                    if (i.seasonId == videoItem.seasonId) {
                      i.followStatus = followStatus;
                      break;
                    }
                  }
                  print(resultList);
                } else {
                  resultList.remove(videoItem);
                }
                SmartDialog.showToast('确定$tips成功');
              } else {
                SmartDialog.showToast(res['msg']);
              }
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> delSub(dynamic videoItem, int followStatus,  String tips) async {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text('确定$tips？'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              var res = await UserHttp.delSub(
                seasonId: videoItem.seasonId,
                seasonType: videoItem.seasonType
              );
              if (res['status']) {
                resultList.remove(videoItem);
                SmartDialog.showToast('确定$tips成功');
              } else {
                SmartDialog.showToast(res['msg']);
              }
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

}
