import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/video/reply/emote.dart';

class ReplyHttp {
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