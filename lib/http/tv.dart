import 'package:bilibili/http/index.dart';
import 'package:bilibili/models/tv/hit_show.dart';
import 'package:bilibili/models/tv/model.dart';
import 'package:bilibili/models/tv/tv.dart';
import 'package:bilibili/models/tv/tv_navhide.dart';
import 'package:bilibili/utils/wbi_sign.dart';
import 'package:media_kit/generated/libmpv/bindings.dart';

class TVhttp {

  // 热播榜
  static Future hitShowList({
    required int seasonType,
  }) async {
    Map params = await WbiSign().makSign({
      'day': 3,
      'web_location': 333.999,
      'season_type': seasonType
    });
    var res = await Request().get(
      Api.hitShowList,
      data: {
        'day': 3,
        'web_location': 333.999,
        'season_type': seasonType,
        'w_rid': params['w_rid'],
        'wts': params['wts'],
      },
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': HitShowModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': {
          'seasonType': 0,
          'note': '',
          'items': []
        },
        'msg': res.data['message'],
      };
    }
  }

  // 推荐电视剧列表
  static Future tvList({int? coursor, name = 'tv'}) async {
    var res = await Request().get(Api.rcmdTvList, data: {
      'name': name,
      'coursor': coursor,
      'new_cursor_status': true,
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': TVModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': {
          'coursor': 0,
          'hasNext': false,
          'items': []
        },
        'msg': res.data['message'],
      };
    }
  }


  // 查询电影、电视剧、综艺、纪录片列表
  static Future tvSeasonList({
    required String key,
    required int st,
    required String seasonStatus,
    required String styleId,
    required int order,
    required int sort,
    required int page,
    required int pagesize,
    dynamic releaseDate,
    dynamic producerId,
    dynamic area,
  }) async {
    String releaseDateStr = '';
    // Map<String, dynamic> data = {
    //   'st': st,
    // };
    // if (key == 'documentary') { // 纪录片
    //   data['producer_id'] = producerId;
    // }
    // if (key == 'movie' || key == 'tv') { // 综艺没有年份
    //   data['area'] = area;
    // }
    // data['style_id'] = styleId;
    // if (key != 'variety') { // 综艺没有年份
    //   // data['release_date'] = releaseDate.toString();
    //   if (releaseDate is List) {
    //     String start = releaseDate.first.substring(0, 10);
    //     String end = releaseDate.last.substring(0, 10);
    //     if (releaseDate.first.contains('2024-01-01')) {
    //       releaseDateStr = '%5B$start%2000%3A00%3A00%2C$end%2000%3A00%3A00%5D';
    //     } else {
    //       releaseDateStr = '%5B$start%2000%3A00%3A00%2C$end%2000%3A00%3A00)';
    //     }
    //   } else {
    //     releaseDateStr = '-1';
    //   }
    // }
    // data['season_status'] = seasonStatus;
    // data['order'] = order;
    // data['sort'] = sort;
    // data['page'] = page;
    // data['season_type'] = st;
    // data['pagesize'] = pagesize;
    // data['type'] = 1;
    // pgc/season/index/result?st=5&area=3&style_id=-1&release_date=-1&season_status=-1&order=4&sort=0&page=1&season_type=5&pagesize=20&type=1
    String url = '${Api.tvSeasonList}?st=$st';
    if (key == 'documentary') {
      url = '$url&producer_id=$producerId';
    }
    if (key == 'movie' || key == 'tv') { // 综艺没有年份
      url = '$url&area=$area';
    }
    url = '$url&style_id=$styleId';
    if (key != 'variety') { // 综艺没有年份
      // data['release_date'] = releaseDate.toString();
      if (releaseDate is List) {
        String start = releaseDate.first.substring(0, 10);
        String end = releaseDate.last.substring(0, 10);
        if (releaseDate.first.contains('2024-01-01')) {
          releaseDateStr = '%5B$start%2000%3A00%3A00%2C$end%2000%3A00%3A00%5D';
        } else {
          releaseDateStr = '%5B$start%2000%3A00%3A00%2C$end%2000%3A00%3A00)';
        }
      } else {
        releaseDateStr = '-1';
      }
      url = '$url&release_date=$releaseDateStr';
    }
    url = '$url&season_status=$seasonStatus&order=$order&sort=$sort&page=$page&season_type=$st&pagesize=$pagesize&type=1';
    var res = await Request().get(
      url,
      // data: data,
    );
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': TVSearchDataModel.fromJson(res.data['data'])
      };
    } else {
      return {
        'status': false,
        'data': {
          'hasNext': 1,
          'num': 1,
          'size': pagesize,
          'total': 0,
          'list': []
        },
        'msg': res.data['message'],
      };
    }
  }

  // 【电视剧推荐】B站出品  必属精品
  static Future tvNavhideList({int? id = 61060}) async {
    var res = await Request().get(Api.tvNavhideList, data: {
      'id': id,
    });
    print(res);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': TvNavhideMode.fromJson(res.data['result'])
      };
    } else {
      return {
        'status': false,
        'data': null,
        'msg': res.data['message'],
      };
    }
  }

  // 【电视剧推荐】B站出品  必属精品
  static Future queryFollowList({required String seasonIds}) async {
    var res = await Request().get(Api.followList, data: {
      'season_ids': seasonIds,
    });
    print(res);
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': res.data['result']
      };
    } else {
      return {
        'status': false,
        'data': null,
        'msg': res.data['message'],
      };
    }
  }
}