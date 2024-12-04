import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/models/tv/movie_column_type.dart';
import 'package:bilibili/pages/movie/controller.dart';
import 'package:bilibili/pages/tv_series/widgets/tv_card_feed.dart';
import 'package:bilibili/pages/tv_series/widgets/tv_card_v.dart';
import 'package:bilibili/utils/main_stream.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with AutomaticKeepAliveClientMixin {
  final MovieController _movieController = Get.put(MovieController());
  late Future? _futureBuilderFuture;
  late Future? _futureBuilderFutureHit;
  late ScrollController scrollController;
  int defaultHitShowLen = 7; // 默认展示

  @override
  void initState() {
    super.initState();
    scrollController = _movieController.scrollController;
    _futureBuilderFuture = _movieController.queryMovieListFeed();
    _futureBuilderFutureHit = _movieController.queryMovieListHit();
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('my-throttler', const Duration(seconds: 1), () {
            _movieController.hasNext = true;
            _movieController.onLoad();
          });
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        await _movieController.queryMovieListHit();
        await _movieController.queryMovieListFeed();
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: StyleString.safeSpace,
                      bottom: 10,
                      left: 16,
                      right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '电影热播榜',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed("/tvRankTop?type=movie");
                          // _movieController.htmlTest();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 14, right: 7, top: 2, bottom: 2),
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(36, 38, 40, 1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Text(
                                'Top100',
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 254,
                  child: FutureBuilder(
                    future: _futureBuilderFutureHit,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null) {
                          return const SizedBox();
                        }
                        Map data = snapshot.data as Map;
                        List list = _movieController.hitShowList;
                        if (data['status']) {
                          return Obx(() => list.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: defaultHitShowLen,
                                  itemBuilder: (context, index) {
                                    return Container(
                                        width: Get.size.width / 3,
                                        height: 250,
                                        margin: EdgeInsets.only(
                                            left: StyleString.safeSpace,
                                            right:
                                                index == defaultHitShowLen - 1
                                                    ? StyleString.safeSpace
                                                    : 0),
                                        child: TvCardV(
                                            tVItem: list[index],
                                            seasonType: 2,
                                            index: index + 1));
                                  },
                                )
                              : const SizedBox(
                                  child: Center(
                                    child: Text('暂无热播电影'),
                                  ),
                                ));
                        } else {
                          return const SizedBox();
                        }
                      }
                      return const SizedBox();
                    },
                  ),
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
              child: Container(
            padding:
                const EdgeInsets.only(left: 14, right: 7, top: 2, bottom: 2),
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [...videoColumns()],
            ),
          )),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '更多推荐',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                StyleString.safeSpace, 0, StyleString.safeSpace, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return Obx(() {
                      return contentGrid(
                          _movieController, _movieController.movieList);
                    });
                  }
                  return HttpError(
                    errMsg: data['msg'],
                    fn: () {
                      _futureBuilderFuture =
                          _movieController.queryMovieListFeed();
                    },
                  );
                } else {
                  return contentGrid(_movieController, []);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> videoColumns() {
    List<Widget> list = movieColumnTypeConfig
        .map((item) => Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () => item.onTap(),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(25)),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelMedium,
                    )
                  ],
                ),
              ),
            ))
        .toList();
    return list;
  }

  Widget contentGrid(ctr, movieList) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 行间距
        mainAxisSpacing: StyleString.cardSpace - 2,
        // 列间距
        crossAxisSpacing: StyleString.cardSpace,
        // 列数
        crossAxisCount: 3,
        mainAxisExtent: Get.size.width / 3 / 0.65 +
            MediaQuery.textScalerOf(context).scale(32.0),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return movieList!.isNotEmpty
              ? TvCardFeed(tVItem: movieList[index])
              : const SizedBox();
        },
        childCount: movieList!.isNotEmpty ? movieList!.length : 10,
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
