import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/video/reply/data.dart';
import 'package:bilibili/models/video/reply/emote.dart';

class ReplyHttp {
  static Future replyList({
    required int oid,
    required int pageNum,
    required int type,
    int? ps,
    int sort = 1,
  }) async {
    var res = await Request().get(Api.replyList, data: {
      'oid': oid,
      'pn': pageNum,
      'type': type,
      'sort': sort,
      'ps': ps ?? 20
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': ReplyData.fromJson(res.data['data']),
        'code': 200,
      };
    } else {
      return {
        'status': false,
        'date': [],
        'code': res.data['code'],
        'msg': res.data['message'],
      };
    }
  }

  static Future replyReplyList({
    required int oid,
    required String root,
    required int pageNum,
    required int type,
    int sort = 1,
  }) async {
    var res = await Request().get(Api.replyReplyList, data: {
      'oid': oid,
      'root': root,
      'pn': pageNum,
      'type': type,
      'sort': 1,
      'csrf': await Request.getCsrf(),
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': ReplyData.fromJson(res.data['data']),
      };
    } else {
      Map errMap = {
        -400: '请求错误',
        -404: '无此项',
        12002: '评论区已关闭',
        12009: '评论主体的type不合法',
      };
      return {
        'status': false,
        'date': [],
        'msg': errMap[res.data['code']] ?? '请求异常',
      };
    }
  }

  // 评论点赞
  static Future likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    var res = await Request().post(
      Api.likeReply,
      queryParameters: {
        'type': type,
        'oid': oid,
        'rpid': rpid,
        'action': action,
        'csrf': await Request.getCsrf(),
      },
    );
    if (res.data['code'] == 0) {
      return {'status': true, 'data': res.data['data']};
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  static Future getEmoteList({String? business}) async {
    var res = await Request().get(Api.emojiList, data: {
      'business': business ?? 'reply',
      'web_location': '333.1245',
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': EmoteModelData.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }
}