import 'package:bilibili/pages/bangumi/index.dart';
import 'package:bilibili/pages/hot/index.dart';
import 'package:bilibili/pages/live/index.dart';
import 'package:bilibili/pages/movie/index.dart';
import 'package:bilibili/pages/rcmd/index.dart';
import 'package:bilibili/pages/tv_series/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TabType { live, rcmd, hot, bangumi, tv, movie }

extension TabTypeDesc on TabType {
  String get description => ['直播', '推荐', '热门', '番剧', '电视剧', '电影'][index];
  String get id => ['live', 'rcmd', 'hot', 'bangumi', 'tv', 'movie'][index];
}

List tabsConfig = [
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': '直播',
    'type': TabType.live,
    'ctr': Get.find<LiveController>,
    'page': const LivePage(),
  },
  {
    'icon': const Icon(
      Icons.thumb_up_off_alt_outlined,
      size: 15,
    ),
    'label': '推荐',
    'type': TabType.rcmd,
    'ctr': Get.find<RcmdController>,
    'page': const RcmdPage(),
  },
  {
    'icon': const Icon(
      Icons.whatshot_outlined,
      size: 15,
    ),
    'label': '热门',
    'type': TabType.hot,
    'ctr': Get.find<HotController>,
    'page': const HotPage(),
  },
  {
    'icon': const Icon(
      Icons.play_circle_outlined,
      size: 15,
    ),
    'label': '番剧',
    'type': TabType.bangumi,
    'ctr': Get.find<BangumidController>,
    'page': const BangumiPage(),
  },
  {
    'icon': const Icon(
      Icons.tv,
      size: 15,
    ),
    'label': '电视剧',
    'type': TabType.tv,
    'ctr': Get.find<TvSeriesController>,
    'page': const TvSeries(),
  },
  {
    'icon': const Icon(
      Icons.movie,
      size: 15,
    ),
    'label': '电影',
    'type': TabType.movie,
    'ctr': Get.find<MovieController>,
    'page': const MoviePage(),
  },
];