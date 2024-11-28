class HitShowModel {
  String? note;
  List<HitShowItemData>? list;

  HitShowModel({
    this.note,
    this.list
  });

  factory HitShowModel.fromJson(Map<String, dynamic> json) {
    return HitShowModel(
      note: json['note'],
      list: json['list'] != null
          ? (json['list'] as List)
              .map<HitShowItemData>((i) => HitShowItemData.fromJson(i))
              .toList()
          : null,
    );
  }
}

class HitShowItemData {
  String? badge;
  Map? badgeInfo;
  int? badgeType;
  String? cover;
  String? pic;
  Map? iconFont;
  String? desc;
  Map? newEp;
  int? rank;
  String? rating;
  int? seasonId;
  String? ssHorizontalCover;
  Map? stat;
  String? title;
  String? url;

  HitShowItemData(
    this.badge,
    this.badgeInfo,
    this.badgeType,
    this.cover,
    this.pic,
    this.iconFont,
    this.desc,
    this.newEp,
    this.rank,
    this.rating,
    this.seasonId,
    this.ssHorizontalCover,
    this.stat,
    this.title,
    this.url,
  );

  HitShowItemData.fromJson(Map<String, dynamic> json) {
    badge = json['badge'];
    badgeInfo = json['badge_info'];
    badgeType = json['badge_type'];
    cover = json['cover'];
    pic = json['cover'];
    iconFont = json['icon_font'];
    desc = json['desc'] ?? '';
    newEp = json['new_ep'];
    rank = json['rank'];
    rating = json['rating'];
    seasonId = json['season_id'];
    ssHorizontalCover = json['ss_horizontal_cover'];
    stat = json['stat'];
    title = json['title'];
    url = json['url'];
  }
}