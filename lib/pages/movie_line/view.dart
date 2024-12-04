import 'package:bilibili/common/widgets/bottom_seat.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/models/movie/movie_line.dart';
import 'package:bilibili/pages/movie_line/controller.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:timeline_list/timeline_list.dart';

class MovieLinePage extends StatefulWidget {
  const MovieLinePage({super.key});

  @override
  State<MovieLinePage> createState() => _MovieLinePageState();
}

class _MovieLinePageState extends State<MovieLinePage> {
  final MovieLineController _movieLineController =
      Get.put(MovieLineController());
  late Future _futureBuilder;

  @override
  void initState() {
    super.initState();
    _futureBuilder = _movieLineController.queryMovieLine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '即将上映',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _movieLineController.queryMovieLine();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 24, left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '点击“追剧”',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '第一时间获取上新资讯',
                      style: Theme.of(context).textTheme.labelLarge,
                    )
                  ],
                ),
              ),
              Expanded(
                  child: FutureBuilder(
                future: _futureBuilder,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) return const SizedBox();
                    Map data = snapshot.data as Map;
                    if (data['status']) {
                      return _timeLine(
                          _movieLineController.movieLineList, context);
                    }
                    return const SizedBox();
                  }
                  return const SizedBox();
                },
              )),
              const BottomSeat(
                isCustomScroll: false,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeLine(movieLineList, context) {
    return Obx(
      () => _movieLineController.movieLineList.isEmpty
          ? const SizedBox()
          : Timeline.builder(
              context: context,
              markerCount: _movieLineController.movieLineList.length,
              horizontalPadding: 0,
              properties: const TimelineProperties(
                  iconAlignment: MarkerIconAlignment.top,
                  iconSize: 12,
                  timelinePosition: TimelinePosition.start),
              markerBuilder: (context, index) {
                MovieLineItem item = _movieLineController.movieLineList[index];
                String heroTag = Utils.makeHeroTag(item.seasonId);
                return Marker(
                  child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double width = constraints.maxWidth - 28;
                          return SizedBox(
                            width: width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  item.desc!,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                     RoutePush.bangumiPush(item.seasonId, null, heroTag: heroTag, videoType: SearchType.media_ft);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 14),
                                    width: double.infinity,
                                    height: 180,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: heroTag,
                                          child: NetworkImgLayer(
                                            src: item.cover,
                                            width: 137,
                                            height: 180,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '电影',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        251, 114, 153, 1),
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                item.title!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                item.styles!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                item.actors!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/images/tv/quoto.svg",
                                                    height: 14,
                                                    width: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    item.subtitle!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium,
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        _movieLineController
                                                            .updateSub(item);
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 50,
                                                        margin: const EdgeInsets
                                                            .only(right: 8),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 4,
                                                                bottom: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: item.follow ==
                                                                        0
                                                                    ? const Color
                                                                        .fromRGBO(
                                                                        255,
                                                                        240,
                                                                        244,
                                                                        1,
                                                                      )
                                                                    : const Color
                                                                        .fromRGBO(
                                                                        231,
                                                                        231,
                                                                        231,
                                                                        1,
                                                                      )),
                                                        child: Text(
                                                          item.follow == 0
                                                              ? item.rights
                                                                          ?.canWatch ==
                                                                      0
                                                                  ? '想看'
                                                                  : '追剧'
                                                              : item.rights
                                                                          ?.canWatch ==
                                                                      0
                                                                  ? '已想看'
                                                                  : '已追剧',
                                                          // item.rights?.canWatch == 1 ? '想看' : '追剧',
                                                          style: TextStyle(
                                                              fontSize: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelMedium
                                                                  ?.fontSize,
                                                              fontWeight: Theme
                                                                      .of(
                                                                          context)
                                                                  .textTheme
                                                                  .labelMedium
                                                                  ?.fontWeight,
                                                              color: item.follow ==
                                                                      0
                                                                  ? const Color
                                                                      .fromRGBO(
                                                                      251,
                                                                      114,
                                                                      153,
                                                                      1,
                                                                    )
                                                                  : const Color
                                                                      .fromRGBO(
                                                                      153,
                                                                      153,
                                                                      153,
                                                                      1)),
                                                        ),
                                                      )),
                                                  Text(
                                                    '${Utils.numFormat(item.stat?.follower)}人${item.rights?.canWatch == 0 ? '想看' : '追剧'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      )),
                  position: MarkerPosition.left,
                );
              },
            ),
    );
  }
}
