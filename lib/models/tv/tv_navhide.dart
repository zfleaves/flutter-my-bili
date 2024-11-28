class TvNavhideMode {

  final String? bgCover;
  final String? color;
  final String? cover;
  final int? id;
  final int? isFavorite;
  List<TvNavhideItem>? seasons;
  final String? summary;
  final String? title;
  final String? total;
  final UpInfo? upInfo;

  TvNavhideMode({
    this.bgCover,
    this.color,
    this.cover,
    this.id,
    this.isFavorite,
    this.seasons,
    this.summary,
    this.title,
    this.total,
    this.upInfo
  });

  factory TvNavhideMode.fromJson(Map<String, dynamic> json) {
    return TvNavhideMode(
      bgCover: json['bg_cover'],
      color: json['color'],
      cover: json['cover'],
      id: json['id'],
      isFavorite: json['is_favorite'],
      seasons: json['seasons'] != null
          ? (json['seasons'] as List)
              .map<TvNavhideItem>((i) => TvNavhideItem.fromJson(i))
              .toList()
          : null,
      summary: json['summary'],
      title: json['title'],
      total: json['total'],
      upInfo: UpInfo.fromJson(json['upInfo']),
    );
  }
}

class TvNavhideItem {
  String? actors;
  String? badge;
  Map? badgeInfo;
  int? badgeType;
  String? cover;
  String? pic;
  String? evaluate;
  String? link;
  int? mediaId;
  Map? newEp;
  Map? rating;
  Map? right;
  int? seasonId;
  int? seasonType;
  Map? stat;
  String? styles;
  String? subtitle;
  String? title;
  int? isFollow;

  TvNavhideItem(
    this.actors,
    this.badge,
    this.badgeInfo,
    this.badgeType,
    this.cover,
    this.pic,
    this.evaluate,
    this.link,
    this.mediaId,
    this.newEp,
    this.rating,
    this.right,
    this.seasonId,
    this.seasonType,
    this.stat,
    this.styles,
    this.subtitle,
    this.title,
  );

  TvNavhideItem.fromJson(Map<String, dynamic> json) {
    actors = json['actors'];
    badge = json['badge'];
    badgeInfo = json['badge_info'];
    badgeType = json['badge_type'];
    cover = json['cover'];
    pic = json['cover'];
    evaluate = json['evaluate'];
    link = json['link'];
    mediaId = json['media_id'];
    newEp = json['new_ep'];
    rating = json['rating'];
    right = json['right'];
    seasonId = json['seasonId'];
    seasonType = json['season_type'];
    stat = json['stat'];
    styles = json['styles'];
    subtitle = json['subtitle'];
    title = json['title'];
    isFollow = json['is_follow'] ?? 0;
  }
}

class UpInfo {
  final String? avatar;
  final String? uname;
  final int? mid;
  late final int? isFollow;

  UpInfo({
    this.avatar,
    this.uname,
    this.mid,
    this.isFollow
  });

  factory UpInfo.fromJson(Map<String, dynamic> json) {
    return UpInfo(
      avatar: json['avatar'],
      uname: json['uname'],
      mid: json['mid'],
      isFollow: json['is_follow'],
    );
  }

}