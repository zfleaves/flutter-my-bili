enum SubType {
  // 番剧：media_bangumi,
  media_bangumi,
  // 视频：video
  video,
}

extension SubTypeExtension on SubType {
  String get id =>
      ['media_bangumi', 'video'][index];
  String get label => ['我的追番', '我的追剧'][index];
  int get type =>
      [1, 2][index];
}


// 搜索类型为视频、专栏及相簿时
enum SubFilterType {
  all,
  want,
  watching,
  seen,
}

extension SubFilterTypeExtension on SubFilterType {
  int get followStatus =>
      [0, 1, 2, 3][index];
  String get id =>
      ['all', 'want', 'watching', 'seen'][index];
  String get label =>
      ['全部', '想看', '在看', '看过'][index];
}
