import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/pages/hot/controller.dart';
import 'package:bilibili/utils/main_stream.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HotPage extends StatefulWidget {
  const HotPage({super.key});

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with AutomaticKeepAliveClientMixin {
  final HotController _hotController = Get.put(HotController());
  List videoList = [];
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _hotController.queryHotFeed('init');
    scrollController = _hotController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_hotController.isLoadingMore) {
            _hotController.isLoadingMore = true;
            _hotController.onLoad();
          }
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        return await _hotController.onRefresh();
      },
      child: CustomScrollView(
        controller: _hotController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            // 单列布局 EdgeInsets.zero
            padding:
                const EdgeInsets.fromLTRB(0, StyleString.safeSpace - 5, 0, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // print(snapshot.data);
                  if (snapshot.data == null) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return const VideoCardHSkeleton();
                      }, childCount: 2),
                    );
                  }
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return VideoCardH(
                          videoItem: _hotController.videoList[index],
                          showPubdate: true,
                        );
                      }, childCount: _hotController.videoList.length),
                    );
                  }
                  return HttpError(
                    errMsg: data['msg'],
                    fn: () {
                      setState(() {
                        _hotController.isLoadingMore = true;
                        _futureBuilderFuture =
                            _hotController.queryHotFeed('init');
                      });
                    },
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return const VideoCardHSkeleton();
                  }, childCount: 10),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            ),
          )
        ],
      ),
    );
  }

  Widget contentGrid(ctr, videoList) {
    double mainAxisExtent = (Get.size.width / StyleString.aspectRatio) + 68;
    return SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return videoList!.isNotEmpty
                ? VideoCardH(
                    videoItem: videoList[index],
                    showPubdate: true,
                  )
                : const VideoCardHSkeleton(); // 骨架屏
          },
          childCount: videoList!.isNotEmpty ? videoList!.length : 10,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // 行间距
          mainAxisSpacing: StyleString.safeSpace,
          // 列间距
          crossAxisSpacing: StyleString.safeSpace,
          // 列数
          crossAxisCount: 1,
          mainAxisExtent: mainAxisExtent,
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
