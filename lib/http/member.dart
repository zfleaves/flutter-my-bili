import 'package:bilibili/common/constants.dart';
import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/dynamics/result.dart';
import 'package:bilibili/models/follow/result.dart';
import 'package:bilibili/models/member/archive.dart';
import 'package:bilibili/models/member/coin.dart';
import 'package:bilibili/models/member/info.dart';
import 'package:bilibili/models/member/seasons.dart';
import 'package:bilibili/models/member/tags.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:bilibili/utils/wbi_sign.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';

class MemberHttp {

  static Future memberInfo({
    int? mid,
    String token = '',
  }) async {
    Map params = await WbiSign().makSign({
      'mid': mid,
      'token': token,
      'platform': 'web',
      'web_location': 1550101
    });
    var res = await Request().get(
      Api.memberInfo,
      data: params,
      extra: {'ua': 'pc'},
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': MemberInfoModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future memberStat({int? mid}) async {
    var res = await Request().get(Api.userStat, data: {'vmid': mid});
    print('abcdef-${res}');
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future memberArchive({
    int? mid,
    int ps = 30,
    int tid = 0,
    int? pn,
    String? keyword,
    String order = 'pubdate',
    bool orderAvoided = true,
  }) async {
    String dmImgStr = Utils.base64EncodeRandomString(16, 64);
    String dmCoverImgStr = Utils.base64EncodeRandomString(32, 128);
    Map params = await WbiSign().makSign({
      'mid': mid,
      'ps': ps,
      'tid': tid,
      'pn': pn,
      'keyword': keyword ?? '',
      'order': order,
      'platform': 'web',
      'web_location': 1550101,
      'order_avoided': orderAvoided,
      'dm_img_list': '[]',
      'dm_img_str': dmImgStr.substring(0, dmImgStr.length - 2),
      'dm_cover_img_str': dmCoverImgStr.substring(0, dmCoverImgStr.length - 2),
      'dm_img_inter': '{"ds":[],"wh":[0,0,0],"of":[0,0,0]}',
    });
    var res = await Request().get(
      Api.memberArchive,
      data: params,
      extra: {'ua': 'pc'},
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': MemberArchiveDataModel.fromJson(res.data['data'])
      };
    } else {
      Map errMap = {
        -352: '风控校验失败，请检查登录状态',
      };
      return {
        'status': false,
        'data': [],
        'msg': errMap[res.data['code']] ?? res.data['message'],
      };
    }
  }

  // 用户动态
  static Future memberDynamic({String? offset, int? mid}) async {
    var res = await Request().get(Api.memberDynamic, data: {
      'offset': offset ?? '',
      'host_mid': mid,
      'timezone_offset': '-480',
      'features': 'itemOpusStyle',
    });
    print('memberDynamic-${res}');
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': DynamicsDataModel.fromJson(res.data['data']),
      };
    } else {
      Map errMap = {
        -352: '风控校验失败，请检查登录状态',
      };
      return {
        'status': false,
        'data': [],
        'msg': errMap[res.data['code']] ?? res.data['message'],
      };
    }
  }

  // 查询分组
  static Future followUpTags() async {
    var res = await Request().get(Api.followUpTag);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data']
            .map<MemberTagItemModel>((e) => MemberTagItemModel.fromJson(e))
            .toList()
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 设置分组
  static Future addUsers(int? fids, String? tagids) async {
    var res = await Request().post(Api.addUsers, queryParameters: {
      'fids': fids,
      'tagids': tagids ?? '0',
      'csrf': await Request.getCsrf(),
    }, data: {
      'cross_domain': true
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': [], 'msg': '操作成功'};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 获取某分组下的up
  static Future followUpGroup(
    int? mid,
    int? tagid,
    int? pn,
    int? ps,
  ) async {
    var res = await Request().get(Api.followUpGroup, data: {
      'mid': mid,
      'tagid': tagid,
      'pn': pn,
      'ps': ps,
    });
    if (res.data['code'] == 0) {
      // FollowItemModel
      return {
        'status': true,
        'data': res.data['data']
            .map<FollowItemModel>((e) => FollowItemModel.fromJson(e))
            .toList()
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 获取uo专栏
  static Future getMemberSeasons(int? mid, int? pn, int? ps) async {
    var res = await Request().get(Api.getMemberSeasonsApi, data: {
      'mid': mid,
      'page_num': pn,
      'page_size': ps,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': MemberSeasonsDataModel.fromJson(res.data['data']['items_lists'])
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 最近投币
  static Future getRecentCoinVideo({required int mid}) async {
    Map params = await WbiSign().makSign({
      'mid': mid,
      'gaia_source': 'main_web',
      'web_location': 333.999,
    });
    var res = await Request().get(
      Api.getRecentCoinVideoApi,
      data: {
        'vmid': mid,
        'gaia_source': 'main_web',
        'web_location': 333.999,
        'w_rid': params['w_rid'],
        'wts': params['wts'],
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data']
            .map<MemberCoinsDataModel>((e) => MemberCoinsDataModel.fromJson(e))
            .toList(),
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 查看某个专栏
  static Future getSeasonDetail({
    required int mid,
    required int seasonId,
    bool sortReverse = false,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(
      Api.getSeasonDetailApi,
      data: {
        'mid': mid,
        'season_id': seasonId,
        'sort_reverse': sortReverse,
        'page_num': pn,
        'page_size': ps,
      },
    );
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': MemberSeasonsList.fromJson(res.data['data'])
        };
      } catch (err) {
        print(err);
      }
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 获取TV authCode
  static Future getTVCode() async {
    SmartDialog.showLoading();
    var params = {
      'appkey': Constants.appKey,
      'local_id': '0',
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    };
    String sign = Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request().post(Api.getTVCode, queryParameters: {...params, 'sign': sign});
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data']['auth_code'],
        'msg': '操作成功'
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 获取access_key
  static Future cookieToKey() async {
    var authCodeRes = await getTVCode();
    if (authCodeRes['status']) {
      var res = await Request().post(Api.cookieToKey, queryParameters: {
        'auth_code': authCodeRes['data'],
        'build': 708200,
        'csrf': await Request.getCsrf(),
      });
      await Future.delayed(const Duration(milliseconds: 300));
      await qrcodePoll(authCodeRes['data']);
      if (res.data['code'] == 0) {
        return {'status': true, 'data': [], 'msg': '操作成功'};
      } else {
        return {
          'status': false,
          'data': [],
          'msg': res.data['message'],
        };
      }
    }
  }


  static Future qrcodePoll(authCode) async {
    var params = {
      'appkey': Constants.appKey,
      'auth_code': authCode.toString(),
      'local_id': '0',
      'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    };
    String sign = Utils.appSign(
      params,
      Constants.appKey,
      Constants.appSec,
    );
    var res = await Request()
        .post(Api.qrcodePoll, queryParameters: {...params, 'sign': sign});
    SmartDialog.dismiss();
    if (res.data['code'] == 0) {
      String accessKey = res.data['data']['access_token'];
      Box localCache = GStrorage.localCache;
      Box userInfoCache = GStrorage.userInfo;
      var userInfo = userInfoCache.get('userInfoCache');
      localCache.put(
          LocalCacheKey.accessKey, {'mid': userInfo.mid, 'value': accessKey});
      return {'status': true, 'data': [], 'msg': '操作成功'};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 获取up播放数、点赞数
  static Future memberView({required int mid}) async {
    var res = await Request().get(Api.getMemberViewApi, data: {'mid': mid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }
}