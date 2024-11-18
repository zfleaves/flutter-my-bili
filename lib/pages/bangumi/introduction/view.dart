import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/stat/danmu.dart';
import 'package:bilibili/common/widgets/stat/view.dart';
import 'package:bilibili/models/bangumi/info.dart';
import 'package:bilibili/pages/bangumi/introduction/controller.dart';
import 'package:bilibili/pages/bangumi/introduction/widgets/intro_detail.dart';
import 'package:bilibili/pages/bangumi/widgets/bangumi_panel.dart';
import 'package:bilibili/pages/video/detail/controller.dart';
import 'package:bilibili/pages/video/detail/introduction/widgets/action_item.dart';
import 'package:bilibili/pages/video/detail/introduction/widgets/fav_panel.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class BangumiIntroPanel extends StatefulWidget {
  final int? cid;
  const BangumiIntroPanel({super.key, this.cid});

  @override
  State<BangumiIntroPanel> createState() => _BangumiIntroPanelState();
}

class _BangumiIntroPanelState extends State<BangumiIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late BangumiIntroController bangumiIntroController;
  late VideoDetailController videoDetailCtr;
  BangumiInfoModel? bangumiDetail;
  late Future _futureBuilderFuture;
  late int cid;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    heroTag = Get.arguments['heroTag'];
    cid = widget.cid!;
    bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    _futureBuilderFuture = bangumiIntroController.queryBangumiIntro();
    videoDetailCtr.cid.listen((int p0) {
      cid = p0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const SliverToBoxAdapter(child: SizedBox());
          }
          if (snapshot.data['status']) {
            // 请求成功
            return Obx(
              () => BangumiInfo(
                bangumiDetail: bangumiIntroController.bangumiDetail.value,
                cid: cid,
              ),
            );
          }
          // 请求错误
          return HttpError(
            errMsg: snapshot.data['msg'],
            fn: () => Get.back(),
          );
        }
        return const SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BangumiInfo extends StatefulWidget {
  final BangumiInfoModel? bangumiDetail;
  final int? cid;
  const BangumiInfo({super.key, this.bangumiDetail, this.cid});

  @override
  State<BangumiInfo> createState() => _BangumiInfoState();
}

class _BangumiInfoState extends State<BangumiInfo> {
  String heroTag = Get.arguments['heroTag'];
  late final BangumiIntroController bangumiIntroController;
  late final VideoDetailController videoDetailCtr;
  Box localCache = GStrorage.localCache;
  late double sheetHeight;
  int? cid;
  bool isProcessing = false;

  void Function()? handleState(Future Function() action) {
    return isProcessing
        ? null
        : () async {
            setState(() => isProcessing = true);
            await action();
            setState(() => isProcessing = false);
          };
  }

  @override
  void initState() {
    super.initState();
    bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    sheetHeight = localCache.get('sheetHeight');
    cid = widget.cid!;
    videoDetailCtr.cid.listen((p0) {
      cid = p0;
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  // 收藏
  showFavBottomSheet() {
    if (bangumiIntroController.userInfo.mid == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FavPanel(ctr: bangumiIntroController);
      },
    );
  }

  // 视频介绍
  showIntroDetail() {
    feedBack();
    showBottomSheet(
      context: context,
      enableDrag: true,
      builder: (BuildContext context) {
        return IntroDetail(bangumiDetail: widget.bangumiDetail!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(
          left: StyleString.safeSpace, right: StyleString.safeSpace, top: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    NetworkImgLayer(
                      width: 105,
                      height: 160,
                      src: widget.bangumiDetail!.cover!,
                    ),
                    PBadge(
                      text:
                          '评分 ${widget.bangumiDetail?.rating?['score']! ?? '暂无'}',
                      top: null,
                      right: 6,
                      bottom: 6,
                      left: null,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => showIntroDetail(),
                    child: SizedBox(
                      height: 158,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.bangumiDetail!.title!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 34,
                                height: 34,
                                child: IconButton(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero),
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith(
                                            (Set<WidgetState> states) {
                                      return t.colorScheme.primaryContainer
                                          .withOpacity(0.7);
                                    }),
                                  ),
                                  onPressed: () =>
                                      bangumiIntroController.bangumiAdd(),
                                  icon: Icon(
                                    Icons.favorite_border_rounded,
                                    color: t.colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              StatView(
                                theme: 'gray',
                                view: widget.bangumiDetail!.stat!['views'],
                                size: 'medium',
                              ),
                              const SizedBox(width: 6),
                              StatDanMu(
                                theme: 'gray',
                                danmu: widget.bangumiDetail!.stat!['danmakus'],
                                size: 'medium',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                (widget.bangumiDetail!.areas!.isNotEmpty
                                    ? widget.bangumiDetail!.areas!.first['name']
                                    : ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: t.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.bangumiDetail!.publish!['pub_time_show'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: t.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.bangumiDetail!.newEp!['desc'],
                            style: TextStyle(
                              fontSize: 12,
                              color: t.colorScheme.outline,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '简介：${widget.bangumiDetail!.evaluate!}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: t.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            /// 点赞收藏转发
            actionGrid(context, bangumiIntroController),

            // 番剧分p
            if (widget.bangumiDetail!.episodes!.isNotEmpty) ...[
              BangumiPanel(
                pages: widget.bangumiDetail!.episodes!,
                cid: cid! ?? widget.bangumiDetail!.episodes!.first.cid!,
                sheetHeight: sheetHeight,
                changeFuc: (bvid, cid, aid, cover) => bangumiIntroController
                    .changeSeasonOrbangu(bvid, cid, aid, cover),
                bangumiDetail: bangumiIntroController.bangumiDetail.value,
                bangumiIntroController: bangumiIntroController,
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget actionGrid(BuildContext context, bangumiIntroController) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: SizedBox(
            height: constraints.maxWidth / 5 * 0.8,
            child: GridView.count(
              primary: false,
              padding: EdgeInsets.zero,
              crossAxisCount: 5,
              childAspectRatio: 1.25,
              children: <Widget>[
                Obx(
                  () => ActionItem(
                    icon: const Icon(FontAwesomeIcons.thumbsUp),
                    selectIcon: const Icon(FontAwesomeIcons.solidThumbsUp),
                    onTap: handleState(bangumiIntroController.actionLikeVideo),
                    selectStatus: bangumiIntroController.hasLike.value,
                    text: widget.bangumiDetail!.stat!['likes']!.toString(),
                  ),
                ),
                Obx(
                  () => ActionItem(
                    icon: const Icon(FontAwesomeIcons.b),
                    selectIcon: const Icon(FontAwesomeIcons.b),
                    onTap: handleState(bangumiIntroController.actionCoinVideo),
                    selectStatus: bangumiIntroController.hasCoin.value,
                    text: widget.bangumiDetail!.stat!['coins']!.toString(),
                  ),
                ),
                Obx(
                  () => ActionItem(
                    icon: const Icon(FontAwesomeIcons.star),
                    selectIcon: const Icon(FontAwesomeIcons.solidStar),
                    onTap: () => showFavBottomSheet(),
                    selectStatus: bangumiIntroController.hasFav.value,
                    text: widget.bangumiDetail!.stat!['favorite']!.toString(),
                  ),
                ),
                ActionItem(
                  icon: const Icon(FontAwesomeIcons.comment),
                  selectIcon: const Icon(FontAwesomeIcons.reply),
                  onTap: () => videoDetailCtr.tabCtr.animateTo(1),
                  selectStatus: false,
                  text: widget.bangumiDetail!.stat!['reply']!.toString(),
                ),
                ActionItem(
                  icon: const Icon(FontAwesomeIcons.shareFromSquare),
                  onTap: () => bangumiIntroController.actionShareVideo(),
                  selectStatus: false,
                  text: widget.bangumiDetail!.stat!['share']!.toString(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
