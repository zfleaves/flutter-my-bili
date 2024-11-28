class TVSearchDataModel {
  final int? hasNext;
  final int? num;
  final int? size;
  final int? total;
  List<TVSearchItemModel>? list;

  TVSearchDataModel({
    this.hasNext,
    this.num,
    this.size,
    this.total,
    this.list,
  });

  factory TVSearchDataModel.fromJson(Map<String, dynamic> json) {
    return TVSearchDataModel(
      hasNext: json['has_next'],
      num: json['num'],
      size: json['size'],
      total: json['total'],
      list: json['list'] != null
          ? (json['list'] as List)
              .map<TVSearchItemModel>((i) => TVSearchItemModel.fromJson(i))
              .toList()
          : null,
    );
  }
}


class TVSearchItemModel {
  String? badge;
  Map? badgeInfo;
  int? badgeType;
  String? cover;
  String? pic;
  Map? firstEp;
  String? indexShow;
  String? link;
  int? mediaId;
  String? order;
  String? orderType;
  String? score;
  int? seasonId;
  int? seasonType;
  String? subTitle;
  String? title;

  TVSearchItemModel(
    this.badge,
    this.badgeInfo,
    this.badgeType,
    this.cover,
    this.pic,
    this.firstEp,
    this.indexShow,
    this.link,
    this.mediaId,
    this.order,
    this.orderType,
    this.score,
    this.seasonId,
    this.seasonType,
    this.subTitle,
    this.title,
  );

  TVSearchItemModel.fromJson(Map<String, dynamic> json) {
    badge = json['badge'] ?? '';
    badgeInfo = json['badge_info'];
    badgeType = json['badge_type'];
    cover = json['cover'];
    pic = json['cover'];
    firstEp = json['first_ep'];
    indexShow = json['index_show'] ?? '';
    link = json['link'];
    order = json['order'];
    orderType = json['order_type'];
    mediaId = json['media_id'];
    score = json['score'] ?? '';
    seasonId = json['season_id'];
    seasonType = json['season_type'];
    subTitle = json['subTitle'];
    title = json['title'];
  }
}