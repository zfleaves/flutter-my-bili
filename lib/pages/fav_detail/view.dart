import 'dart:async';

import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/pages/fav_detail/controller.dart';
import 'package:bilibili/pages/fav_detail/widgets/fav_video_card.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavDetailPage extends StatefulWidget {
  const FavDetailPage({super.key});

  @override
  State<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends State<FavDetailPage> {
  late final ScrollController _controller = ScrollController();
  final FavDetailController _favDetailController =
      Get.put(FavDetailController());
  late StreamController<bool> titleStreamC; // a
  Future? _futureBuilderFuture;
  late String mediaId;

  @override
  void initState() {
    super.initState();
    mediaId = Get.parameters['mediaId']!;
    _futureBuilderFuture = _favDetailController.queryUserFavFolderDetail();
    titleStreamC = StreamController<bool>();
    _controller.addListener(
      () {
        if (_controller.offset > 160) {
          titleStreamC.add(true);
        } else if (_controller.offset <= 160) {
          titleStreamC.add(false);
        }

        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('favDetail', const Duration(seconds: 1), () {
            _favDetailController.onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    titleStreamC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            expandedHeight: 260 - MediaQuery.of(context).padding.top,
            pinned: true,
            titleSpacing: 0,
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
                              _favDetailController.item!.title!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '共${_favDetailController.mediaCount}条视频',
                              style: Theme.of(context).textTheme.labelMedium,
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }),
            actions: [
              IconButton(
                onPressed: () =>
                    Get.toNamed('/favSearch?searchType=0&mediaId=$mediaId'),
                icon: const Icon(Icons.search_outlined),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_outlined),
                position: PopupMenuPosition.under,
                onSelected: (String type) {},
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    onTap: () => _favDetailController.onDelFavFolder(),
                    value: 'pause',
                    child: const Text('删除收藏夹'),
                  ),
                ],
              ),
              const SizedBox(width: 14),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: kTextTabBarHeight +
                        MediaQuery.of(context).padding.top +
                        30,
                    left: 20,
                    right: 20),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: _favDetailController.heroTag,
                        child: NetworkImgLayer(
                          width: 180,
                          height: 110,
                          src: _favDetailController.item!.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              _favDetailController.item!.title!,
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .fontSize,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _favDetailController.item!.upper!.name!,
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .fontSize,
                                  color: Theme.of(context).colorScheme.outline),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 8, left: 14),
              child: Obx(
                () => Text(
                  '共${_favDetailController.mediaCount}条视频',
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                      letterSpacing: 1),
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map data = snapshot.data;
                if (data['status']) {
                  if (_favDetailController.item!.mediaCount == 0) {
                    return const NoData();
                  }
                  List favList = _favDetailController.favList;
                  return Obx(
                    () => favList.isEmpty
                        ? const SliverToBoxAdapter(child: SizedBox())
                        : SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return FavVideoCardH(
                                videoItem: favList[index],
                                callFn: () => _favDetailController
                                    .onCancelFav(favList[index].id),
                              );
                            }, childCount: favList.length),
                          ),
                  );
                }
                return HttpError(
                  errMsg: data['msg'],
                  fn: () => setState(() {}),
                );
              }
              // 骨架屏
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const VideoCardHSkeleton();
                }, childCount: 10),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).padding.bottom + 60,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: Center(
                child: Obx(
                  () => Text(
                    _favDetailController.loadingText.value,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 13),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
