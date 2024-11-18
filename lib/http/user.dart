import 'package:bilibili/http/api.dart';
import 'package:bilibili/http/init.dart';
import 'package:bilibili/models/model_hot_video_item.dart';
import 'package:bilibili/models/user/fav_detail.dart';
import 'package:bilibili/models/user/fav_folder.dart';
import 'package:bilibili/models/user/history.dart';
import 'package:bilibili/models/user/info.dart';
import 'package:bilibili/models/user/stat.dart';
import 'package:bilibili/models/user/sub_folder.dart';

class UserHttp {
  static Future<dynamic> userStat({required int mid}) async {
    var res = await Request().get(Api.userStat, data: {'vmid': mid});
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false};
    }
  }

  // 获取当前用户状态
  static Future<dynamic> userStatOwner() async {
    var res = await Request().get(Api.userStatOwner);
    if (res.data['code'] == 0) {
      UserStat data = UserStat.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 获取用户信息
  static Future<dynamic> userInfo() async {
    var res = await Request().get(Api.userInfo);
    // print('-获取用户信息-$res');
    if (res.data['code'] == 0) {
      UserInfoData data = UserInfoData.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }
  

  // 收藏夹
  static Future<dynamic> userfavFolder({
    required int pn,
    required int ps,
    required int mid,
  }) async {
    var res = await Request().get(Api.userFavFolder, data: {
      'pn': pn,
      'ps': ps,
      'up_mid': mid,
    });
    if (res.data['code'] == 0) {
      late FavFolderData data;
      if (res.data['data'] != null) {
        data = FavFolderData.fromJson(res.data['data']);
        return {'status': true, 'data': data};
      }
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
        'code': res.data['code'],
      };
    }
  }

    /// 收藏夹 详情
  static Future<dynamic> userFavFolderDetail(
      {required int mediaId,
      required int pn,
      required int ps,
      String keyword = '',
      String order = 'mtime',
      int type = 0}) async {
    var res = await Request().get(Api.userFavFolderDetail, data: {
      'media_id': mediaId,
      'pn': pn,
      'ps': ps,
      'keyword': keyword,
      'order': order,
      'type': type,
      'tid': 0,
      'platform': 'web'
    });
    if (res.data['code'] == 0) {
      FavDetailData data = FavDetailData.fromJson(res.data['data']);
      return {'status': true, 'data': data};
    } else {
      return {'status': false, 'data': [], 'msg': res.data['message']};
    }
  }

  // 稍后再看
  static Future<dynamic> seeYouLater() async {
    var res = await Request().get(Api.seeYouLater);
    if (res.data['code'] == 0) {
      if (res.data['data']['count'] == 0) {
        return {
          'status': true,
          'data': {'list': [], 'count': 0}
        };
      }
      List<HotVideoItemModel> list = [];
      for (var i in res.data['data']['list']) {
        list.add(HotVideoItemModel.fromJson(i));
      }
      return {
        'status': true,
        'data': {'list': list, 'count': res.data['data']['count']}
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
        'code': res.data['code'],
      };
    }
  }

  // 观看历史
  static Future historyList(int? max, int? viewAt) async {
    var res = await Request().get(Api.historyList, data: {
      'type': 'all',
      'ps': 20,
      'max': max ?? 0,
      'view_at': viewAt ?? 0,
    });
    if (res.data['code'] == 0) {
      return {'status': true, 'data': HistoryData.fromJson(res.data['data'])};
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
        'code': res.data['code'],
      };
    }
  }

  // 暂停观看历史
  static Future pauseHistory(bool switchStatus) async {
    // 暂停switchStatus传true 否则false
    var res = await Request().post(
      Api.pauseHistory,
      queryParameters: {
        'switch': switchStatus,
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    return res;
  }

    // 观看历史暂停状态
  static Future historyStatus() async {
    var res = await Request().get(Api.historyStatus);
    return res;
  }

  // 清空历史记录
  static Future clearHistory() async {
    var res = await Request().post(
      Api.clearHistory,
      queryParameters: {
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    return res;
  }

  // 稍后再看
  static Future toViewLater({String? bvid, dynamic aid}) async {
    var data = {'csrf': await Request.getCsrf()};
    if (bvid != null) {
      data['bvid'] = bvid;
    } else if (aid != null) {
      data['aid'] = aid;
    }
    var res = await Request().post(
      Api.toViewLater,
      queryParameters: data,
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': 'yeah！稍后再看'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 移除已观看
  static Future toViewDel({int? aid}) async {
    final Map<String, dynamic> params = {
      'jsonp': 'jsonp',
      'csrf': await Request.getCsrf(),
    };

    params[aid != null ? 'aid' : 'viewed'] = aid ?? true;
    var res = await Request().post(
      Api.toViewDel,
      queryParameters: params,
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': 'yeah！成功移除'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 清空稍后再看
  static Future toViewClear() async {
    var res = await Request().post(
      Api.toViewClear,
      queryParameters: {
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': '操作完成'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 删除历史记录
  static Future delHistory(kid) async {
    var res = await Request().post(
      Api.delHistory,
      queryParameters: {
        'kid': kid,
        'jsonp': 'jsonp',
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'msg': '已删除'};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 查询关系
  static Future hasFollow(int mid) async {
    var res = await Request().get(
      Api.hasFollow,
      data: {
        'fid': mid,
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 搜索历史记录
  static Future searchHistory(
      {required int pn, required String keyword}) async {
    // https://api.bilibili.com/x/web-interface/history/search?pn=1&keyword=11&business=all
    var res = await Request().get(
      Api.searchHistory,
      data: {
        'pn': pn,
        'keyword': keyword,
        'business': 'all',
      },
    );
    print('1111$res');
    if (res.data['code'] == 0) {
      return {'status': true, 'data': HistoryData.fromJson(res.data['data'])};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 我的订阅
  static Future userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async {
    var res = await Request().get(Api.userSubFolder, data: {
      'up_mid': mid,
      'ps': ps,
      'pn': pn,
      'platform': 'web',
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SubFolderModelData.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
        'code': res.data['code'],
      };
    }
  }

  // 取消订阅
  static Future cancelSub({required int seasonId}) async {
    var res = await Request().post(
      Api.cancelSub,
      queryParameters: {
        'platform': 'web',
        'season_id': seasonId,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }

  // 删除文件夹
  static Future delFavFolder({required int mediaIds}) async {
    var res = await Request().post(
      Api.delFavFolder,
      queryParameters: {
        'media_ids': mediaIds,
        'platform': 'web',
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true};
    } else {
      return {'status': false, 'msg': res.data['message']};
    }
  }
}