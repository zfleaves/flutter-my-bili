import 'package:bilibili/common/constants.dart';
import 'package:bilibili/http/api.dart';
import 'package:bilibili/http/init.dart';
import 'package:bilibili/models/home/rcmd/result.dart';
import 'package:bilibili/models/model_hot_video_item.dart';
import 'package:bilibili/models/model_rec_video_item.dart';
import 'package:bilibili/utils/recommend_filter.dart';
import 'package:hive/hive.dart';
import '../utils/storage.dart';


/// res.data['code'] == 0 请求正常返回结果
/// res.data['data'] 为结果
/// 返回{'status': bool, 'data': List}
/// view层根据 status 判断渲染逻辑
class VideoHttp {
  static Box localCache = GStrorage.localCache;
  static Box setting = GStrorage.setting;
  static bool enableRcmdDynamic =
      setting.get(SettingBoxKey.enableRcmdDynamic, defaultValue: true);
  static Box userInfoCache = GStrorage.userInfo;


  // 首页推荐视频
  static Future rcmdVideoList({required int ps, required int freshIdx}) async {
    try {
      var res = await Request().get(
        Api.recommendListWeb,
        data: {
          'version': 1,
          'feed_version': 'V3',
          'homepage_ver': 1,
          'ps': ps,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4
        },
      );
      if (res.data['code'] == 0) {
        List<RecVideoItemModel> list = [];
        List<int> blackMidsList =
            setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
        for (var i in res.data['data']['item']) {
          //过滤掉live与ad，以及拉黑用户
          if (i['goto'] == 'av' &&
              (i['owner'] != null &&
                  !blackMidsList.contains(i['owner']['mid']))) {
            RecVideoItemModel videoItem = RecVideoItemModel.fromJson(i);
            if (!RecommendFilter.filter(videoItem)) {
              list.add(videoItem);
            }
          }
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': [], 'msg': res.data['message']};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  // 添加额外的loginState变量模拟未登录状态
  static Future rcmdVideoListApp({bool loginStatus = true, required int freshIdx}) async {
    try {
      var res = await Request().get(
        Api.recommendListApp,
        data: {
          'idx': freshIdx,
          'flush': '5',
          'column': '4',
          'device': 'pad',
          'device_type': 0,
          'device_name': 'vivo',
          'pull': freshIdx == 0 ? 'true' : 'false',
          'appkey': Constants.appKey,
          'access_key': loginStatus
              ? (localCache.get(LocalCacheKey.accessKey,
                      defaultValue: {})['value'] ??
                  '')
              : ''
        },
      );
      if (res.data['code'] == 0) {
        List<RecVideoItemAppModel> list = [];
        List<int> blackMidsList =
            setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
        for (var i in res.data['data']['items']) {
          // 屏蔽推广和拉黑用户
          if (i['card_goto'] != 'ad_av' &&
              (!enableRcmdDynamic ? i['card_goto'] != 'picture' : true) &&
              (i['args'] != null &&
                  !blackMidsList.contains(i['args']['up_mid']))) {
            RecVideoItemAppModel videoItem = RecVideoItemAppModel.fromJson(i);
            if (!RecommendFilter.filter(videoItem)) {
              list.add(videoItem);
            }
          }
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': [], 'msg': res.data['message']};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }

  static Future hotVideoList({required int pn, required int ps}) async {
    try {
      var res = await Request().get(
        Api.hotList,
        data: {'pn': pn, 'ps': ps},
      );
      if (res.data['code'] == 0) {
        List<HotVideoItemModel> list = [];
        List<int> blackMidsList =
            setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
        for (var i in res.data['data']['list']) {
          if (!blackMidsList.contains(i['owner']['mid'])) {
            list.add(HotVideoItemModel.fromJson(i));
          }
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': [], 'msg': res.data['message']};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err};
    }
  }

  // 操作用户关系
  static Future relationMod(
      {required int mid, required int act, required int reSrc}) async {
    var res = await Request().post(Api.relationMod, queryParameters: {
      'fid': mid,
      'act': act,
      're_src': reSrc,
      'csrf': await Request.getCsrf(),
    });
    if (res.data['code'] == 0) {
      if (act == 5) {
        List<int> blackMidsList =
            setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
        blackMidsList.add(mid);
        setting.put(SettingBoxKey.blackMidsList, blackMidsList);
      }
      return {'status': true, 'data': res.data['data'], 'msg': '成功'};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 视频播放进度
  static Future heartBeat({bvid, cid, progress, realtime}) async { 
    await Request().post(Api.heartBeat, queryParameters: {
      // 'aid': aid,
      'bvid': bvid,
      'cid': cid,
      // 'epid': '',
      // 'sid': '',
      // 'mid': '',
      'played_time': progress,
      // 'realtime': realtime,
      // 'type': '',
      // 'sub_type': '',
      'csrf': await Request.getCsrf(),
    });
  }

  // 视频排行
  static Future getRankVideoList(int rid) async {
    try {
      var rankApi = "${Api.getRankApi}?rid=$rid&type=all";
      var res = await Request().get(rankApi);
      if (res.data['code'] == 0) {
        List<HotVideoItemModel> list = [];
        List<int> blackMidsList =
            setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
        for (var i in res.data['data']['list']) {
          if (!blackMidsList.contains(i['owner']['mid'])) {
            list.add(HotVideoItemModel.fromJson(i));
          }
        }
        return {'status': true, 'data': list};
      } else {
        return {'status': false, 'data': [], 'msg': res.data['message']};
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err};
    }
  }
}