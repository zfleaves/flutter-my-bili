class TVModel {
  final List<TvItemData>? items;
  final int? coursor;
  final bool? hasNext;
  TVModel({
    this.coursor,
    this.hasNext,
    this.items,
  });

  factory TVModel.fromJson(Map<String, dynamic> json) {
    return TVModel(
      coursor: json['coursor'],
      hasNext: json['has_next'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map<TvItemData>((i) => TvItemData.fromJson(i))
              .toList()
          : null,
    );
  }
}

class TvItemData {
  String? cover;
  int? episodeId;
  Map? hover;
  Map? inline;
  String? link;
  int? rankId;
  String? rating;
  int? seasonId;
  int? seasonType;
  Map? stat;
  String? subTitle;
  String? title;
  Map? userStatus;

  TvItemData(
    this.cover,
    this.episodeId,
    this.hover,
    this.inline,
    this.link,
    this.rankId,
    this.rating,
    this.seasonId,
    this.seasonType,
    this.stat,
    this.subTitle,
    this.title,
    this.userStatus,
  );

  TvItemData.fromJson(Map<String, dynamic> json) {
    cover = json['cover'];
    episodeId = json['episode_id'];
    hover = json['hover'];
    inline = json['inline'];
    link = json['link'];
    rankId = json['rank_id'];
    rating = json['rating'];
    seasonId = json['season_id'];
    seasonType = json['season_type'];
    stat = json['stat'];
    subTitle = json['sub_title'];
    title = json['title'];
    userStatus = json['user_status'];
  }
}