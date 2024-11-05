import 'dart:io';

import 'package:bilibili/pages/preview/controller.dart';
import 'package:bilibili/utils/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';
import 'package:extended_image/extended_image.dart';

typedef DoubleClickAnimationListener = void Function();

class ImagePreview extends StatefulWidget {
  final int? initialPage;
  final List<String>? imgList;
  const ImagePreview({super.key, this.initialPage, this.imgList});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview>
    with TickerProviderStateMixin {
  final PreviewController _previewController = Get.put(PreviewController());
  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  bool _dismissDisabled = false;

  @override
  void initState() {
    super.initState();
    _previewController.initialPage.value = widget.initialPage!;
    _previewController.currentPage.value = widget.initialPage! + 1;
    _previewController.imgList.value = widget.imgList!;
    _previewController.currentImgUrl = widget.imgList![widget.initialPage!];
    // animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 400));
    setStatusBar();
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
  }

  // 隐藏状态栏，避免遮挡图片内容
  setStatusBar() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await StatusBarControl.setHidden(true,
          animation: StatusBarAnimation.SLIDE);
    }
  }

  onOpenMenu() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            clipBehavior: Clip.hardEdge,
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    _previewController.onShareImg();
                    Get.back();
                  },
                  dense: true,
                  title: const Text('分享', style: TextStyle(fontSize: 14)),
                ),
                ListTile(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                            text: _previewController.currentImgUrl))
                        .then((value) {
                      Get.back();
                      SmartDialog.showToast('已复制到粘贴板');
                    }).catchError((err) {
                      SmartDialog.showNotify(
                        msg: err.toString(),
                        notifyType: NotifyType.error,
                      );
                    });
                  },
                  dense: true,
                  title: const Text('复制链接', style: TextStyle(fontSize: 14)),
                ),
                ListTile(
                  onTap: () {
                    Get.back();
                    DownloadUtils.downloadImg(_previewController.currentImgUrl);
                  },
                  dense: true,
                  title: const Text('保存到手机', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    // animationController.dispose();
    try {
      StatusBarControl.setHidden(false, animation: StatusBarAnimation.SLIDE);
    } catch (_) {}
    _doubleClickAnimationController.dispose();
    clearGestureDetailsCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      primary: false,
      extendBody: true,
      appBar: AppBar(
        primary: false,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onLongPress: () => onOpenMenu(),
            child: ExtendedImageGesturePageView.builder(
                controller: ExtendedPageController(
                  initialPage: _previewController.initialPage.value,
                  pageSpacing: 0,
                ),
                onPageChanged: (int index) =>
                    _previewController.onChange(index),
                canScrollPage: (GestureDetails? gestureDetails) =>
                    gestureDetails!.totalScale! <= 1.0,
                itemCount: widget.imgList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ExtendedImage.network(
                    widget.imgList![index],
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    onDoubleTap: (ExtendedImageGestureState state) {
                      final Offset? pointerDownPosition =
                          state.pointerDownPosition;
                      final double? begin = state.gestureDetails!.totalScale;
                      double end;

                      //remove old
                      _doubleClickAnimation
                          ?.removeListener(_doubleClickAnimationListener);

                      //stop pre
                      _doubleClickAnimationController.stop();

                      //reset to use
                      _doubleClickAnimationController.reset();

                      if (begin == doubleTapScales[0]) {
                        setState(() {
                          _dismissDisabled = true;
                        });
                        end = doubleTapScales[1];
                      } else {
                        setState(() {
                          _dismissDisabled = false;
                        });
                        end = doubleTapScales[0];
                      }

                      _doubleClickAnimationListener = () {
                        state.handleDoubleTap(
                            scale: _doubleClickAnimation!.value,
                            doubleTapPosition: pointerDownPosition);
                      };
                      _doubleClickAnimation = _doubleClickAnimationController
                          .drive(Tween<double>(begin: begin, end: end));

                      _doubleClickAnimation!
                          .addListener(_doubleClickAnimationListener);

                      _doubleClickAnimationController.forward();
                    },
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.loading) {
                        final ImageChunkEvent? loadingProgress =
                            state.loadingProgress;
                        final double? progress =
                            loadingProgress?.expectedTotalBytes != null
                                ? loadingProgress!.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 150.0,
                                child: LinearProgressIndicator(
                                  value: progress,
                                  color: Colors.white,
                                ),
                              ),
                              // const SizedBox(height: 10.0),
                              // Text('${((progress ?? 0.0) * 100).toInt()}%',),
                            ],
                          ),
                        );
                      }
                      return null;
                    },
                    initGestureConfigHandler: (ExtendedImageState state) {
                      return GestureConfig(
                        inPageView: true,
                        initialScale: 1.0,
                        maxScale: 5.0,
                        animationMaxScale: 6.0,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                  );
                }),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black87,
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.imgList!.length > 1
                        ? Obx(() => Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  children: [
                                    TextSpan(
                                        text: _previewController.currentPage
                                            .toString()),
                                    const TextSpan(text: ' / '),
                                    TextSpan(
                                        text:
                                            widget.imgList!.length.toString()),
                                  ]),
                            ))
                        : const SizedBox(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
