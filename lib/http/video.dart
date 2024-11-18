import 'dart:developer';
import 'package:bilibili/common/constants.dart';
import 'package:bilibili/http/api.dart';
import 'package:bilibili/http/init.dart';
import 'package:bilibili/models/common/reply_type.dart';
import 'package:bilibili/models/home/rcmd/result.dart';
import 'package:bilibili/models/model_hot_video_item.dart';
import 'package:bilibili/models/model_rec_video_item.dart';
import 'package:bilibili/models/user/fav_folder.dart';
import 'package:bilibili/models/video/ai.dart';
import 'package:bilibili/models/video/play/url.dart';
import 'package:bilibili/models/video/subTitile/result.dart';
import 'package:bilibili/models/video_detail_res.dart';
import 'package:bilibili/utils/recommend_filter.dart';
import 'package:bilibili/utils/subtitle.dart';
import 'package:bilibili/utils/wbi_sign.dart';
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

  // 视频流
  static Future videoUrl(
      {int? avid, String? bvid, required int cid, int? qn}) async {
    Map<String, dynamic> data = {
      'cid': cid,
      'qn': qn ?? 80,
      // 获取所有格式的视频
      'fnval': 4048,
    };
    if (avid != null) {
      data['avid'] = avid;
    }
    if (bvid != null) {
      data['bvid'] = bvid;
    }

    // 免登录查看1080p
    if (userInfoCache.get('userInfoCache') == null &&
        setting.get(SettingBoxKey.p1080, defaultValue: true)) {
      data['try_look'] = 1;
    }

    Map params = await WbiSign().makSign({
      ...data,
      'fourk': 1,
      'voice_balance': 1,
      'gaia_source': 'pre-load',
      'web_location': 1550101,
    });

    try {
      var res = await Request().get(Api.videoUrl, data: params);
      if (res.data['code'] == 0) {
        return {
          'status': true,
          'data': PlayUrlModel.fromJson(res.data['data'])
        };
      } else {
        return {
          'status': false,
          'data': [],
          'code': res.data['code'],
          'msg': res.data['message'],
        };
      }
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err};
    }
  }

  // 视频信息 标题、简介
  static Future videoIntro({required String bvid}) async {
    var res = await Request().get(Api.videoIntro, data: {'bvid': bvid});
    if (res.data['code'] == 0) {
      VideoDetailResponse result = VideoDetailResponse.fromJson(res.data);
      return {'status': true, 'data': result.data!};
    } else {
      return {
        'status': false,
        'data': null,
        'code': res.data['code'],
        'msg': res.data['message'],
      };
    }
  }

  // 相关视频
  static Future relatedVideoList({required String bvid}) async {
    var res = await Request().get(Api.relatedList, data: {'bvid': bvid});
    if (res.data['code'] == 0) {
      List<HotVideoItemModel> list = [];
      for (var i in res.data['data']) {
        HotVideoItemModel videoItem = HotVideoItemModel.fromJson(i);
        if (!RecommendFilter.filter(videoItem, relatedVideos: true)) {
          list.add(videoItem);
        }
      }
      return {'status': true, 'data': list};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 获取点赞状态
  static Future hasLikeVideo({required String bvid}) async {
    var res = await Request().get(Api.hasLikeVideo, data: {'bvid': bvid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 获取投币状态
  static Future hasCoinVideo({required String bvid}) async {
    var res = await Request().get(Api.hasCoinVideo, data: {'bvid': bvid});
    print('res: $res');
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 投币
  static Future coinVideo({required String bvid, required int multiply}) async {
    var res = await Request().post(
      Api.coinVideo,
      queryParameters: {
        'bvid': bvid,
        'multiply': multiply,
        'select_like': 0,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 获取收藏状态
  static Future hasFavVideo({required int aid}) async {
    var res = await Request().get(Api.hasFavVideo, data: {'aid': aid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 一键三连
  static Future oneThree({required String bvid}) async {
    var res = await Request().post(
      Api.oneThree,
      queryParameters: {
        'bvid': bvid,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // （取消）点赞
  static Future likeVideo({required String bvid, required bool type}) async {
    var res = await Request().post(
      Api.likeVideo,
      queryParameters: {
        'bvid': bvid,
        'like': type ? 1 : 2,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // （取消）收藏
  static Future favVideo(
      {required int aid, String? addIds, String? delIds}) async {
    var res = await Request().post(Api.favVideo, queryParameters: {
      'rid': aid,
      'type': 2,
      'add_media_ids': addIds ?? '',
      'del_media_ids': delIds ?? '',
      'csrf': await Request.getCsrf(),
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 查看视频被收藏在哪个文件夹
  static Future videoInFolder({required int mid, required int rid}) async {
    var res = await Request()
        .get(Api.videoInFolder, data: {'up_mid': mid, 'rid': rid});
    if (res.data['code'] == 0) {
      FavFolderData data = FavFolderData.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'data': []};
    }
  }

  // 发表评论 replyAdd

  // type	num	评论区类型代码	必要	类型代码见表
  // oid	num	目标评论区id	必要
  // root	num	根评论rpid	非必要	二级评论以上使用
  // parent	num	父评论rpid	非必要	二级评论同根评论id 大于二级评论为要回复的评论id
  // message	str	发送评论内容	必要	最大1000字符
  // plat	num	发送平台标识	非必要	1：web端 2：安卓客户端  3：ios客户端  4：wp客户端
  static Future replyAdd({
    required ReplyType type,
    required int oid,
    required String message,
    int? root,
    int? parent,
  }) async {
    if (message == '') {
      return {'status': false, 'data': [], 'msg': '请输入评论内容'};
    }
    var res = await Request().post(Api.replyAdd, queryParameters: {
      'type': type.index,
      'oid': oid,
      'root': root == null || root == 0 ? '' : root,
      'parent': parent == null || parent == 0 ? '' : parent,
      'message': message,
      'csrf': await Request.getCsrf(),
    });
    log(res.toString());
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 查询是否关注up
  static Future hasFollow({required int mid}) async {
    var res = await Request().get(Api.hasFollow, data: {'fid': mid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': []};
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

  // 添加追番
  static Future bangumiAdd({int? seasonId}) async {
    var res = await Request().post(Api.bangumiAdd, queryParameters: {
      'season_id': seasonId,
      'csrf': await Request.getCsrf(),
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': res.data['result']['toast']};
    } else {
      return {'status': false, 'msg': res.data['result']['toast']};
    }
  }

  // 取消追番
  static Future bangumiDel({int? seasonId}) async {
    var res = await Request().post(Api.bangumiDel, queryParameters: {
      'season_id': seasonId,
      'csrf': await Request.getCsrf(),
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': res.data['result']['toast']};
    } else {
      return {'status': false, 'msg': res.data['result']['toast']};
    }
  }

  // 查看视频同时在看人数
  static Future onlineTotal({int? aid, String? bvid, int? cid}) async {
    var res = await Request().get(Api.onlineTotal, data: {
      'aid': aid,
      'bvid': bvid,
      'cid': cid,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'data': null, 'msg': res.data['message']};
    }
  }

  static Future aiConclusion({
    String? bvid,
    int? cid,
    int? upMid,
  }) async {
    Map params = await WbiSign().makSign({
      'bvid': bvid,
      'cid': cid,
      'up_mid': upMid,
    });
    var res = await Request().get(Api.aiConclusion, data: params);
    if (res.data['code'] == 0 && res.data['data']['code'] == 0) {
      return {
        'status': true,
        'data': AiConclusionModel.fromJson(res.data['data']),
      };
    } else {
      return {'status': false, 'data': []};
    }
  }

  static Future getSubtitle({int? cid, String? bvid}) async {
    var res = await Request().get(Api.getSubtitleConfig, data: {
      'cid': cid,
      'bvid': bvid,
    });
    try {
      if (res.data['code'] == 0) {
        return {
          'status': true,
          'data': SubTitlteModel.fromJson(res.data['data']),
        };
      } else {
        return {'status': false, 'data': [], 'msg': res.data['msg']};
      }
    } catch (err) {
      print(err);
    }
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

  // 获取字幕内容
  static Future<Map<String, dynamic>> getSubtitleContent(url) async {
    var res = await Request().get('https:$url');
    final String content = SubTitleUtils.convertToWebVTT(res.data['body']);
    final List body = res.data['body'];
    return {'content': content, 'body': body};
  }
}