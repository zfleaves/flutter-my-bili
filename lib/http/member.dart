import 'package:bilibili/common/constants.dart';
import 'package:bilibili/http/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';

class MemberHttp {

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
}