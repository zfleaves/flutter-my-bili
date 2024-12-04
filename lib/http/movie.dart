import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/movie/movie_line.dart';

class Moviehttp {
  // 推荐电视剧列表
  static Future movieLineList({int? coursor, name = 'tv'}) async {
    var res = await Request().get(Api.timelineList, data: {
      'type': 1,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': MovieLineModal.fromJson(res.data['result'])
      };
    } else {
      return {
        'status': false,
        'data': {
          'title': '',
          'items': []
        },
        'msg': res.data['message'],
      };
    }
  }
}