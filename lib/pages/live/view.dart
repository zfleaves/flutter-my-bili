import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/pages/live/controller.dart';
import 'package:bilibili/pages/live/widgets/live_item.dart';
import 'package:bilibili/utils/main_stream.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/skeleton/video_card_v.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with AutomaticKeepAliveClientMixin {
  final LiveController _liveController = Get.put(LiveController());
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _liveController.queryLiveList('init');
    scrollController = _liveController.scrollController;
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        EasyThrottle.throttle('liveList', const Duration(milliseconds: 200),
            () {
          _liveController.onLoad();
        });
      }
      handleScrollEvent(scrollController);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      // Clip.hardEdge表示使用硬边缘裁剪，即直接裁剪掉超出边界的部分，不会应用任何平滑或抗锯齿效果。
      // 与之相对的是Clip.antiAlias，后者会在裁剪时应用平滑效果，但可能会消耗更多的性能。
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
          left: StyleString.safeSpace, right: StyleString.safeSpace),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(StyleString.imgRadius),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await _liveController.onRefresh();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          controller: _liveController.scrollController,
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(0, StyleString.safeSpace, 0, 0),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    Map data = snapshot.data as Map;
                    if (data['status']) {
                      return SliverLayoutBuilder(
                        builder: (context, constraints) {
                          return Obx(() {
                            return contentGrid(
                                _liveController, _liveController.liveList);
                          });
                        },
                      );
                    } else {
                      return HttpError(
                          errMsg: data['msg'],
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  _liveController.queryLiveList('init');
                            });
                          });
                    }
                  } else {
                    return contentGrid(_liveController, []);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget contentGrid(ctr, liveList) {
    int crossAxisCount = ctr.crossAxisCount.value;
    return SliverGrid(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return liveList!.isNotEmpty
              ? LiveCardV(
                  liveItem: liveList[index],
                  crossAxisCount: crossAxisCount,
                )
              : const VideoCardVSkeleton();
        }, childCount: liveList!.isNotEmpty ? liveList!.length : 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // 行间距
          mainAxisSpacing: StyleString.safeSpace,
          // 列间距
          crossAxisSpacing: StyleString.safeSpace,
          // 列数
          crossAxisCount: crossAxisCount,
          mainAxisExtent:
              Get.size.width / crossAxisCount / StyleString.aspectRatio +
                  MediaQuery.textScalerOf(context).scale(
                    (crossAxisCount == 1 ? 48 : 68),
                  ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
