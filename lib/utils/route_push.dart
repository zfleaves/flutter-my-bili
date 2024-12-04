import 'package:bilibili/http/search.dart';
import 'package:bilibili/models/bangumi/info.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class RoutePush {
  static Future<void> bangumiPush(int? seasonId, int? epId,
      {String? heroTag, SearchType? videoType = SearchType.media_bangumi }) async {
    SmartDialog.showLoading<dynamic>(msg: '获取中...');
    try {
      var result = await SearchHttp.bangumiInfo(seasonId: seasonId, epId: epId);
      print(result);
      await SmartDialog.dismiss();
      if (result['status']) {
        if (result['data'].episodes.isEmpty) {
          if (result['data'].section.isEmpty) {
            SmartDialog.showToast('资源获取失败');
            return;
          }
          final BangumiInfoModel bangumiDetail = result['data'];
          final sectionItem = bangumiDetail.section!.first;
          if (sectionItem['episodes'].isNotEmpty) {
            final dynamic episode = sectionItem['episodes']!.first;
            print(episode);
            final int epId = episode['ep_id'];
            final int cid = episode['cid'];
            final String bvid = episode['bvid'];
            final String cover = episode['cover'];
            final Map arguments = <String, dynamic>{
              'pic': cover,
              'videoType': videoType
              // 'bangumiItem': bangumiDetail,
            };
            print(arguments);
            arguments['heroTag'] = heroTag ?? Utils.makeHeroTag(cid);
            Get.toNamed(
              '/video?bvid=$bvid&cid=$cid&epId=$epId',
              arguments: arguments,
            );
            return;
          }
        }
        final BangumiInfoModel bangumiDetail = result['data'];
        final EpisodeItem episode = bangumiDetail.episodes!.first;
        final int epId = episode.id!;
        final int cid = episode.cid!;
        final String bvid = episode.bvid!;
        final String cover = episode.cover!;
        final Map arguments = <String, dynamic>{
          'pic': cover,
          'videoType': videoType
          // 'bangumiItem': bangumiDetail,
        };
        print(arguments);
        arguments['heroTag'] = heroTag ?? Utils.makeHeroTag(cid);
        Get.toNamed(
          '/video?bvid=$bvid&cid=$cid&epId=$epId&seasonId=$seasonId',
          arguments: arguments,
        );
      } else {
        SmartDialog.showToast(result['msg']);
      }
    } catch (e) {
      SmartDialog.showToast('番剧获取失败：$e');
    }
  }

  // 登录跳转
  static Future<void> loginPush() async {
    await Get.toNamed(
      '/webview',
      parameters: {
        'url': 'https://passport.bilibili.com/h5-app/passport/login',
        'type': 'login',
        'pageTitle': '登录bilibili',
      },
    );
  }

  // 登录跳转
  static Future<void> loginRedirectPush() async {
    await Get.offAndToNamed(
      '/webview',
      parameters: {
        'url': 'https://passport.bilibili.com/h5-app/passport/login',
        'type': 'login',
        'pageTitle': '登录bilibili',
      },
    );
  }
}