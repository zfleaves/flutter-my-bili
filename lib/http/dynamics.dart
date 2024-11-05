import 'dart:math';

import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/dynamics/result.dart';
import 'package:bilibili/models/dynamics/up.dart';

class DynamicsHttp {
  static Future followDynamic({
    String? type,
    int? page,
    String? offset,
    int? mid,
  }) async {
    Map<String, dynamic> data = {
      'type': type ?? 'all',
      'page': page ?? 1,
      'timezone_offset': '-480',
      'offset': page == 1 ? '' : offset,
      'features': 'itemOpusStyle'
    };
    if (mid != -1) {
      data['host_mid'] = mid;
      data.remove('timezone_offset');
    }
    var res = await Request().get(Api.followDynamic, data: data);
    print(res);
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': DynamicsDataModel.fromJson(res.data['data']),
        };
      } catch (err) {
        return {
          'status': false,
          'data': [],
          'msg': err.toString(),
        };
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

  // 正在直播的up & 关注的up
  static Future followUp() async {
    var res = await Request().get(Api.followUp);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': FollowUpModel.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 动态点赞
  static Future likeDynamic({
    required String? dynamicId,
    required int? up,
  }) async {
    var res = await Request().post(
      Api.likeDynamic,
      queryParameters: {
        'dynamic_id': dynamicId,
        'up': up,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future dynamicDetail({String? id,}) async {
    var res = await Request().get(Api.dynamicDetail, data: {
      'timezone_offset': -480,
      'id': id,
      'features': 'itemOpusStyle',
    });
    if (res.data['code'] == 0) {
      try {
        return {
          'status': true,
          'data': DynamicItemModel.fromJson(res.data['data']['item']),
        };
      } catch (err) {
        return {
          'status': false,
          'data': [],
          'msg': err.toString(),
        };
      }
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }

  // 转发 发布
  static Future dynamicCreate({
    required int mid,
    required int scene,
    int? oid,
    String? dynIdStr,
    String? rawText,
  }) async {
    DateTime now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch ~/ 1000;
    Random random = Random();
    int randomNumber = random.nextInt(9000) + 1000;
    String uploadId = '${mid}_${timestamp}_$randomNumber';
    Map<String, dynamic> webRepostSrc = {
      'dyn_id_str': dynIdStr ?? '',
    };
    /// 投稿转发
    if (scene == 5) {
      webRepostSrc = {
        'revs_id': {'dyn_type': 8, 'rid': oid}
      };
    }
     var res = await Request().post(Api.dynamicCreate, queryParameters: {
      'platform': 'web',
      'csrf': await Request.getCsrf(),
      'x-bili-device-req-json': {'platform': 'web', 'device': 'pc'},
      'x-bili-web-req-json': {'spm_id': '333.999'},
    }, data: {
      'dyn_req': {
        'content': {
          'contents': [
            {'raw_text': rawText ?? '', 'type': 1, 'biz_id': ''}
          ]
        },
        'scene': scene,
        'attach_card': null,
        'upload_id': uploadId,
        'meta': {
          'app_meta': {'from': 'create.dynamic.web', 'mobi_app': 'web'}
        }
      },
      'web_repost_src': webRepostSrc
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['data'],
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
      };
    }
  }
}