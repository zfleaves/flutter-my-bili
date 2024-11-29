class SubScribeModelData {
  final List<SubScribeItemData>? list;
  final int? pn;
  final int? ps;
  final int? total;
  SubScribeModelData({
    this.total,
    this.pn,
    this.ps,
    this.list,
  });

  factory SubScribeModelData.fromJson(Map<String, dynamic> json) {
    return SubScribeModelData(
      ps: json['ps'],
      pn: json['pn'],
      total: json['total'],
      list: json['list'] != null
          ? (json['list'] as List)
              .map<SubScribeItemData>((i) => SubScribeItemData.fromJson(i))
              .toList()
          : null,
    );
  }
}

class SubScribeItemData {
  List? areas;
  String? badge;
  String? badgeEp;
  Map? badgeInfo;
  int? badgeType;
  String? cover;
  String? evaluate;
  int? followStatus;
  int? mediaId;
  Map? newEp;
  String? progress;
  Map? publish;
  Map? rating;
  Map? rights;
  int? seasonId;
  String? seasonTitle;
  int? seasonType;
  String? seasonTypeName;
  String? seasonVersion;
  String? shortUrl;
  String? squareCover;
  Map? stat;
  List? styles;
  String? subtitle;
  String? subtitle14;
  String? summary;
  String? title;
  String? url;
  String? pic;

  SubScribeItemData({
    this.areas,
    this.badge,
    this.badgeEp,
    this.badgeInfo,
    this.badgeType,
    this.cover,
    this.pic,
    this.evaluate,
    this.followStatus,
    this.mediaId,
    this.newEp,
    this.progress,
    this.publish,
    this.rating,
    this.rights,
    this.seasonId,
    this.seasonTitle,
    this.seasonType,
    this.seasonTypeName,
    this.seasonVersion,
    this.shortUrl,
    this.squareCover,
    this.stat,
    this.styles,
    this.subtitle,
    this.subtitle14,
    this.summary,
    this.title,
    this.url,
  });

  SubScribeItemData.fromJson(Map<String, dynamic> json) {
    areas = json['areas'];
    badge = json['badge'] != '' ? json['badge'] : null;
    badgeEp = json['badge_ep'] != '' ? json['badge_ep'] : null;
    badgeInfo = json['badge_info'];
    badgeType = json['badge_type'];
    cover = json['cover'];
    pic = json['cover'];
    evaluate = json['evaluate'];
    followStatus = json['follow_status'];
    mediaId = json['media_id'];
    newEp = json['new_ep'];
    progress = json['progress'];
    publish = json['publish'];
    rating = json['rating'];
    rights = json['rights'];
    seasonId = json['season_id'];
    seasonTitle = json['season_title'];
    seasonType = json['season_type'];
    seasonTypeName = json['season_type_name'];
    seasonVersion = json['season_version'];
    shortUrl = json['short_url'];
    squareCover = json['square_cover'];
    stat = json['stat'];
    styles = json['styles'];
    subtitle = json['subtitle'];
    subtitle14 = json['subtitle_14'];
    summary = json['summary'];
    title = json['title'];
    url = json['url'];
  }
}
