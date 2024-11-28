import 'dart:async';
import 'package:bilibili/common/skeleton/tv_rank_card_h.dart';
import 'package:bilibili/common/widgets/bottom_seat.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/tv/tv_rank_type.dart';
import 'package:bilibili/models/tv/hit_show.dart';
import 'package:bilibili/pages/tv_rank_top/index.dart';
import 'package:bilibili/pages/tv_rank_top/widgets/tv_rank_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class TvRankTopPage extends StatefulWidget {
  const TvRankTopPage({super.key});

  @override
  State<TvRankTopPage> createState() => _TvRankTopPageState();
}

class _TvRankTopPageState extends State<TvRankTopPage>
    with TickerProviderStateMixin {
  late TabController? _tabController;
  late final ScrollController scrollController;
  late Future _futureBuilderFuture;
  final TvRankTopController _tvRankTopController =
      Get.put(TvRankTopController());
  // Future? _futureBuilderFuture;
  late StreamController<bool> titleStreamC; // a

  @override
  void initState() {
    super.initState();
    scrollController = _tvRankTopController.scrollController;
    _futureBuilderFuture = _tvRankTopController.queryTvListHit();
    _tabController = TabController(
      vsync: this,
      length: TvRankType.values.length,
      initialIndex: _tvRankTopController.tabIndex,
    );
    titleStreamC = StreamController<bool>();
    scrollController.addListener(
      () {
        if (scrollController.offset > 160) {
          titleStreamC.add(true);
        } else if (scrollController.offset <= 160) {
          titleStreamC.add(false);
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    titleStreamC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220 - MediaQuery.of(context).padding.top,
            pinned: true,
            titleSpacing: 0,
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromRGBO(54, 30, 20, 1),
            title: StreamBuilder(
                stream: titleStreamC.stream.distinct(),
                initialData: false,
                builder: (context, AsyncSnapshot snapshot) {
                  return AnimatedOpacity(
                    opacity: snapshot.data ? 1 : 0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '热播榜',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .fontSize,
                                  color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: 140,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/top/111.png'),
                        fit: BoxFit.cover)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 120,
                      ),
                      Text(
                        '热播榜',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '根据内容得热度排名，每小时更新一次',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _MySliverPersistentHeaderDelegate(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(54, 30, 20, 1),
                  border: Border(
                    top: BorderSide(
                      width: 0.6,
                      color: Theme.of(context).dividerColor.withOpacity(0.05),
                    ),
                  ),
                ),
                height: 40,
                padding: const EdgeInsets.only(
                  // top: StyleString.safeSpace * 2,
                  // bottom: 10,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Theme(
                    data: ThemeData(
                      splashColor: Colors.transparent, // 点击时的水波纹颜色设置为透明
                      highlightColor: Colors.transparent, // 点击时的背景高亮颜色设置为透明
                    ),
                    child: Obx(() => TabBar(
                          controller: _tabController,
                          tabs: [
                            for (var i in _tvRankTopController.rankTabs)
                              Tab(text: "${i['label']}")
                          ],
                          isScrollable: true,
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: const TextStyle(fontSize: 13),
                          dividerColor: Colors.transparent,
                          tabAlignment: TabAlignment.start,
                          onTap: (index) async {
                            print(_tvRankTopController.rankTabs[index]);
                            _tvRankTopController.seasonType.value = _tvRankTopController.rankTabs[index]['seasonType'];
                            SmartDialog.showLoading();
                            _tvRankTopController.animateToTop();
                            _tvRankTopController.onRefresh();
                            SmartDialog.dismiss();
                          },
                        )),
                  ),
                ),
              ),
            ),
            pinned: true,
          ),
          FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map data = snapshot.data as Map;
                if (snapshot.data['status']) {
                  RxList<HitShowItemData> list =
                      _tvRankTopController.hitShowList;
                  return Obx(() => list.isEmpty
                      ? const NoData()
                      : SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return TvRankItem(tvRankItem: _tvRankTopController.hitShowList[index], index: index + 1);
                          }, childCount: _tvRankTopController.hitShowList.length),
                        ));
                }
                // 请求错误
                return HttpError(
                  errMsg: data['msg'],
                  fn: () => setState(() {}),
                );
              }
              // 骨架屏
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const TvRankCardHSkeleton();
                }, childCount: 8),
              );
            },
          ),
          const BottomSeat(),
        ],
      ),
      backgroundColor: const Color.fromRGBO(54, 30, 20, 1),
    );
  }
}

class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent = 40;
  final double _maxExtent = 40;
  final Widget child;

  _MySliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    //shrinkOffset：child偏移值minExtent~maxExtent
    //overlapsContent：SliverPersistentHeader覆盖其他子组件返回true，否则返回false
    return child;
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
