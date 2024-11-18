import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/pages/video/detail/related/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RelatedVideoPanel extends StatefulWidget {
  const RelatedVideoPanel({super.key});

  @override
  State<RelatedVideoPanel> createState() => _RelatedVideoPanelState();
}

class _RelatedVideoPanelState extends State<RelatedVideoPanel> with AutomaticKeepAliveClientMixin {
  late ReleatedController _releatedController;
  late Future _futureBuilder;

  @override
  void initState() {
    super.initState();
    _releatedController =
        Get.put(ReleatedController(), tag: Get.arguments?['heroTag']);
    _futureBuilder = _releatedController.queryRelatedVideo();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilder,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const SliverToBoxAdapter(child: SizedBox());
          }
          if (snapshot.data!['status'] && snapshot.data != null) {
            RxList relatedVideoList = _releatedController.relatedVideoList;
            // 请求成功
            return Obx(
              () => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == relatedVideoList.length) {
                    return SizedBox(height: MediaQuery.of(context).padding.bottom,);
                  }
                  return Material(
                    child: VideoCardH(
                      videoItem: relatedVideoList[index],
                      showPubdate: true,
                    ),
                  );
                }, childCount: relatedVideoList.length + 1)
              )
            );
          }
          // 请求错误
          return HttpError(errMsg: '出错了', fn: () {});
        }
        // 骨架屏
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return const VideoCardHSkeleton();
          }, childCount: 5),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}