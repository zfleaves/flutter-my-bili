import 'package:bilibili/models/model_owner.dart';

class FavDetailData {
  FavDetailData({
    this.info,
    this.medias,
    this.hasMore,
  });

  Map? info;
  List<FavDetailItemData>? medias;
  bool? hasMore;

  FavDetailData.fromJson(Map<String, dynamic> json) {
    info = json['info'];
    medias = json['medias'] != null
        ? json['medias']
            .map<FavDetailItemData>((e) => FavDetailItemData.fromJson(e))
            .toList()
        : [];
    hasMore = json['has_more'];
  }
}

class FavDetailItemData {
  FavDetailItemData({
    this.id,
    this.type,
    this.title,
    this.pic,
    this.intro,
    this.page,
    this.duration,
    this.owner,
    this.attr,
    this.cntInfo,
    this.link,
    this.ctime,
    this.pubdate,
    this.favTime,
    this.bvId,
    this.bvid,
    // this.season,
    this.ogv,
    this.stat,
    this.cid,
    this.epId,
  });

  int? id;
  int? type;
  String? title;
  String? pic;
  String? intro;
  int? page;
  int? duration;
  Owner? owner;
  int? attr;
  Map? cntInfo;
  String? link;
  int? ctime;
  int? pubdate;
  int? favTime;
  String? bvId;
  String? bvid;
  Map? ogv;
  Stat? stat;
  int? cid;
  String? epId;

  FavDetailItemData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    pic = json['cover'];
    intro = json['intro'];
    page = json['page'];
    duration = json['duration'];
    owner = Owner.fromJson(json['upper']);
    attr = json['attr'];
    cntInfo = json['cnt_info'];
    link = json['link'];
    ctime = json['ctime'];
    pubdate = json['pubtime'];
    favTime = json['fav_time'];
    bvId = json['bv_id'];
    bvid = json['bvid'];
    ogv = json['ogv'];
    stat = Stat.fromJson(json['cnt_info']);
    cid = json['ugc'] != null ? json['ugc']['first_cid'] : null;
    if (json['link'] != null && json['link'].contains('/bangumi')) {
      epId = resolveEpId(json['link']);
    }
  }

  String resolveEpId(url) {
    RegExp regex = RegExp(r'\d+');
    Iterable<Match> matches = regex.allMatches(url);
    List<String> numbers = [];
    for (Match match in matches) {
      numbers.add(match.group(0)!);
    }
    return numbers[0];
  }
}

class Stat {
  Stat({
    this.view,
    this.danmaku,
  });

  int? view;
  int? danmaku;

  Stat.fromJson(Map<String, dynamic> json) {
    view = json['play'];
    danmaku = json['danmaku'];
  }
}