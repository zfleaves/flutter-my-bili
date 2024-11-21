import 'dart:io';

import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/pages/live_room/controller.dart';
import 'package:bilibili/pages/live_room/widgets/bottom_control.dart';
import 'package:bilibili/plugin/pl_player/controller.dart';
import 'package:bilibili/plugin/pl_player/utils/fullscreen.dart';
import 'package:bilibili/plugin/pl_player/view.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key});

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final LiveRoomController _liveRoomController = Get.put(LiveRoomController());
  PlPlayerController? plPlayerController;
  late Future? _futureBuilder;
  late Future? _futureBuilderFuture;

  bool isShowCover = true;
  bool isPlay = true;
  Floating? floating;

  late double statusBarHeight;

  @override
  void initState() {
    super.initState();
    statusBarHeight = localCache.get('statusBarHeight');
    if (Platform.isAndroid) {
      floating = Floating();
    }
    videoSourceInit();
    _futureBuilderFuture = _liveRoomController.queryLiveInfo();
  }

  Future<void> videoSourceInit() async {
    _futureBuilder = _liveRoomController.queryLiveInfoH5();
    plPlayerController = _liveRoomController.plPlayerController;
  }

  @override
  void dispose() {
    plPlayerController!.dispose();
    if (floating != null) {
      floating!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeContext = MediaQuery.sizeOf(context);
    final _context = MediaQuery.of(context);
    late double defaultVideoHeight = sizeContext.width * 9 / 16;
    late RxDouble videoHeight = defaultVideoHeight.obs;
    final double pinnedHeaderHeight =
        statusBarHeight + kToolbarHeight + videoHeight.value;
    // ignore: no_leading_underscores_for_local_identifiers

    // 竖屏
    final bool isPortrait = _context.orientation == Orientation.portrait;
    // 横屏
    final bool isLandscape = _context.orientation == Orientation.landscape;
    final Rx<bool> isFullScreen = plPlayerController?.isFullScreen ?? false.obs;
    // 全屏时高度撑满
    if (isLandscape || isFullScreen.value == true) {
      videoHeight.value = Get.size.height;
      enterFullScreen();
    } else {
      videoHeight.value = defaultVideoHeight;
      exitFullScreen();
    }

    Widget videoPlayerPanel = FutureBuilder(
      future: _futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data['status']) {
          if (snapshot.hasData && snapshot.data['status']) {
            return PLVideoPlayer(
              controller: plPlayerController!,
              bottomControl: BottomControl(
                controller: plPlayerController!,
                liveRoomCtr: _liveRoomController,
                floating: floating,
                onRefresh: () {
                  setState(() {
                    _futureBuilderFuture = _liveRoomController.queryLiveInfo();
                  });
                },
                fullScreenCb: (bool status) {
                  if (status) {
                    videoHeight.value = Get.size.height;
                  } else {
                    videoHeight.value = defaultVideoHeight;
                  }
                },
              ),
            );
          }
        }
        return const SizedBox();
      },
    );

    Widget childWhenDisabled = Scaffold(
      primary: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/live/default_bg.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Obx(
            () => Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _liveRoomController
                              .roomInfoH5.value.roomInfo?.appBackground !=
                          '' &&
                      _liveRoomController
                              .roomInfoH5.value.roomInfo?.appBackground !=
                          null
                  ? Opacity(
                      opacity: 0.8,
                      child: NetworkImgLayer(
                        width: Get.width,
                        height: Get.height,
                        type: 'bg',
                        src: _liveRoomController
                                .roomInfoH5.value.roomInfo?.appBackground ??
                            '',
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          Column(
            children: [
              AppBar(
                centerTitle: false,
                titleSpacing: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                toolbarHeight:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 56
                        : 0,
                title: FutureBuilder(
                  future: _futureBuilder,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return const SizedBox();
                    }
                    Map data = snapshot.data as Map;
                    if (data['status']) {
                      return Obx(() => Row(
                            children: [
                              NetworkImgLayer(
                                width: 34,
                                height: 34,
                                type: 'avatar',
                                src: _liveRoomController.roomInfoH5.value
                                    .anchorInfo!.baseInfo!.face,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _liveRoomController.roomInfoH5.value
                                        .anchorInfo!.baseInfo!.uname!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 1),
                                  if (_liveRoomController
                                          .roomInfoH5.value.watchedShow !=
                                      null)
                                    Text(
                                      _liveRoomController.roomInfoH5.value
                                              .watchedShow!['text_large'] ??
                                          '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                            ],
                          ));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              PopScope(
                canPop: plPlayerController?.isFullScreen.value != true,
                onPopInvokedWithResult: (bool didPop, dynamic) {
                  if (plPlayerController?.isFullScreen.value == true) {
                    plPlayerController!.triggerFullScreen(status: false);
                  }
                  if (MediaQuery.of(context).orientation ==
                      Orientation.landscape) {
                    verticalScreen();
                  }
                },
                child: SizedBox(
                  width: Get.size.width,
                  height: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? Get.size.height
                      : Get.size.width * 9 / 16,
                  child: videoPlayerPanel,
                ),
              )
            ],
          )
        ],
      ),
    );

    if (Platform.isAndroid) {
      return PiPSwitcher(
        childWhenDisabled: childWhenDisabled,
        childWhenEnabled: videoPlayerPanel,
        floating: floating,
      );
    } else {
      return childWhenDisabled;
    }
  }
}
