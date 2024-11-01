import 'dart:convert';

import 'package:bilibili/http/api.dart';
import 'package:bilibili/http/init.dart';
import 'package:bilibili/http/suggest.dart';
import 'package:bilibili/models/bangumi/info.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/models/search/all.dart';
import 'package:bilibili/models/search/hot.dart';
import 'package:bilibili/models/search/result.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/wbi_sign.dart';
import 'package:hive/hive.dart';

class SearchHttp { 
  static Box setting = GStrorage.setting;
  static Future hotSearchList() async { 
    var res = await Request().get(Api.hotSearchList);
    if (res.data is String) {
      Map<String, dynamic> resultMap = json.decode(res.data);
      if (resultMap['code'] == 0) {
        return {
          'status': true,
          'data': HotSearchModel.fromJson(resultMap),
        };
      }
    } else if (res.data is Map<String, dynamic> && res.data['code'] == 0) {
      return {
        'status': true,
        'data': HotSearchModel.fromJson(res.data),
      };
    }
    return {
      'status': false,
      'data': [],
      'msg': '请求错误 🙅',
    };
  }
  
  // 获取搜索建议
  static Future searchSuggest({required term}) async { 
    var res = await Request().get(Api.searchSuggest,
        data: {'term': term, 'main_ver': 'v1', 'highlight': term});
    if (res.data is String) {
      Map<String, dynamic> resultMap = json.decode(res.data);
      if (resultMap['code'] == 0) {
        if (resultMap['result'] is Map) {
          resultMap['result']['term'] = term;
        }
        return {
          'status': true,
          'data': resultMap['result'] is Map
              ? SearchSuggestModel.fromJson(resultMap['result'])
              : [],
        };
      } else {
        return {
          'status': false,
          'data': [],
          'msg': '请求错误 🙅',
        };
      }
    } else {
      return {
        'status': false,
        'data': [],
        'msg': '请求错误 🙅',
      };
    }
  }

  // 分类搜索
  static Future searchByType({
    required SearchType searchType,
    required String keyword,
    required page,
    String? order,
    int? duration,
    int? tids,
  }) async {
    var reqData = {
      'search_type': searchType.type,
      'keyword': keyword,
      // 'order_sort': 0,
      // 'user_type': 0,
      'page': page,
      if (order != null) 'order': order,
      if (duration != null) 'duration': duration,
      if (tids != null && tids != -1) 'tids': tids,
    };
    var res = await Request().get(Api.searchByType, data: reqData);
    if (res.data['code'] == 0) {
      if (res.data['data']['numPages'] == 0) {
        // 我想返回数据，使得可以通过data.list 取值，结果为[]
        return {'status': true, 'data': Data()};
      }
      Object data;
      try {
        switch (searchType) {
          case SearchType.video:
            List<int> blackMidsList =
                setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
            for (var i in res.data['data']['result']) {
              // 屏蔽推广和拉黑用户
              i['available'] = !blackMidsList.contains(i['mid']);
            }
            data = SearchVideoModel.fromJson(res.data['data']);
            break;
          case SearchType.live_room:
            data = SearchLiveModel.fromJson(res.data['data']);
            break;
          case SearchType.bili_user:
            data = SearchUserModel.fromJson(res.data['data']);
            break;
          case SearchType.media_bangumi:
            data = SearchMBangumiModel.fromJson(res.data['data']);
            break;
          case SearchType.article:
            data = SearchArticleModel.fromJson(res.data['data']);
            break;
        }
        return {
          'status': true,
          'data': data,
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

  static Future<int> ab2c({int? aid, String? bvid}) async {
    Map<String, dynamic> data = {};
    if (aid != null) {
      data['aid'] = aid;
    } else if (bvid != null) {
      data['bvid'] = bvid;
    }
    final dynamic res =
        await Request().get(Api.ab2c, data: <String, dynamic>{...data});
    return res.data['data'].first['cid'];
  }

  static Future<Map<String, dynamic>> bangumiInfo(
      {int? seasonId, int? epId}) async {
    final Map<String, dynamic> data = {};
    if (seasonId != null) {
      data['season_id'] = seasonId;
    } else if (epId != null) {
      data['ep_id'] = epId;
    }
    final dynamic res =
        await Request().get(Api.bangumiInfo, data: <String, dynamic>{...data});
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': BangumiInfoModel.fromJson(res.data['result']),
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': '请求错误 🙅',
      };
    }
  }

  static Future<Map<String, dynamic>> ab2cWithPic(
      {int? aid, String? bvid}) async {
    Map<String, dynamic> data = {};
    if (aid != null) {
      data['aid'] = aid;
    } else if (bvid != null) {
      data['bvid'] = bvid;
    }
    final dynamic res =
        await Request().get(Api.ab2c, data: <String, dynamic>{...data});
    return {
      'cid': res.data['data'].first['cid'],
      'pic': res.data['data'].first['first_frame'],
    };
  }

  static Future<Map<String, dynamic>> searchCount(
      {required String keyword}) async {
    Map<String, dynamic> data = {
      'keyword': keyword,
      'web_location': 333.999,
    };
    Map params = await WbiSign().makSign(data);
    final dynamic res = await Request().get(Api.searchCount, data: params);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': SearchAllModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': '请求错误 🙅',
      };
    }
  }
}

class Data {
  List<dynamic> list;

  Data({this.list = const []});
}
