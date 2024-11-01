import 'package:bilibili/http/search.dart';
import 'package:bilibili/models/bangumi/info.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class RoutePush {
  static Future<void> bangumiPush(int? seasonId, int? epId,
      {String? heroTag}) async {
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      var result = await SearchHttp.bangumiInfo(seasonId: seasonId, epId: epId);
      await SmartDialog.dismiss();
      if (result['status']) {
        if (result['data'].episodes.isEmpty) {
          SmartDialog.showToast('资源获取失败');
          return;
        }
        final BangumiInfoModel bangumiDetail = result['data'];
        final EpisodeItem episode = bangumiDetail.episodes!.first;
        final int epId = episode.id!;
        final int cid = episode.cid!;
        final String bvid = episode.bvid!;
        final String cover = episode.cover!;
        final Map arguments = <String, dynamic>{
          'pic': cover,
          'videoType': SearchType.media_bangumi,
          // 'bangumiItem': bangumiDetail,
        };
        arguments['heroTag'] = heroTag ?? Utils.makeHeroTag(cid);
        Get.toNamed(
          '/video?bvid=$bvid&cid=$cid&epId=$epId',
          arguments: arguments,
        );
      } else {
        SmartDialog.showToast(result['msg']);
      }
    } catch (e) {
      SmartDialog.showToast('番剧获取失败：$e');
    }
  }
}