enum TvRankType {
  // 番剧
  bangumi,
  // 电影
  movie,
  // 纪录片
  documentary,
  // 国产动画
  guochan,
  // 电视剧
  tv,
  // 综艺
  variety,
}

extension TvRankTypeExtension on TvRankType {
  String get id =>
      ['bangumi', 'movie', 'documentary', 'guochan', 'tv', 'variety'][index];
  String get label => ['番剧', '电影', '纪录片', '国产动画', '电视剧', '综艺'][index];
  int get seasonType =>
      [1, 2, 3, 4, 5, 7][index];
}



