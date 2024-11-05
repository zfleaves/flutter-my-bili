import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/pages/rank/zone/controller.dart';
import 'package:bilibili/utils/main_stream.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZonePage extends StatefulWidget {
  final int rid;
  const ZonePage({super.key, required this.rid});

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin {
  late ZoneController _zoneController;
  List videoList = [];
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _zoneController = Get.put(ZoneController(), tag: widget.rid.toString());
    _futureBuilderFuture = _zoneController.queryRankFeed('init', widget.rid);
    scrollController = _zoneController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_zoneController.isLoadingMore) {
            EasyThrottle.throttle('my-throttler', const Duration(seconds: 1),
                () {
              _zoneController.isLoadingMore = true;
              _zoneController.onLoad();
            });
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
        await _zoneController.onRefresh();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: CustomScrollView(
        controller: _zoneController.scrollController,
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(0, StyleString.safeSpace - 5, 0, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return Obx(() {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return VideoCardH(
                              videoItem: _zoneController.videoList[index],
                              showPubdate: true,
                            );
                          },
                        childCount: _zoneController.videoList.length),
                      );
                    });
                  } else {
                    return HttpError(
                      errMsg: data['msg'],
                      fn: () {
                        setState(() {
                          _futureBuilderFuture =
                              _zoneController.queryRankFeed('init', widget.rid);
                        });
                      },
                    );
                  }
                } else {
                  // 骨架屏
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return const VideoCardHSkeleton();
                    }, childCount: 10),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
