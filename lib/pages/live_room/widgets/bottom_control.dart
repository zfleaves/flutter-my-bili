import 'dart:io';

import 'package:bilibili/models/video/play/url.dart';
import 'package:bilibili/pages/live_room/controller.dart';
import 'package:bilibili/plugin/pl_player/controller.dart';
import 'package:bilibili/plugin/pl_player/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class BottomControl extends StatefulWidget implements PreferredSizeWidget {
  final PlPlayerController controller;
  final LiveRoomController? liveRoomCtr;
  final Floating? floating;
  final Function? onRefresh;
  final Function? fullScreenCb;
  const BottomControl(
      {super.key,
      required this.controller,
      this.liveRoomCtr,
      this.floating,
      this.fullScreenCb,
      this.onRefresh});

  @override
  State<BottomControl> createState() => _BottomControlState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _BottomControlState extends State<BottomControl> {
  late PlayUrlModel videoInfo;
  TextStyle subTitleStyle = const TextStyle(fontSize: 12);
  TextStyle titleStyle = const TextStyle(fontSize: 14);
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  Box localCache = GStrorage.localCache;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PlPlayerController _ = widget.controller;
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      primary: false,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 14,
      title: Row(
        children: [
          ComBtn(
            icon: const Icon(
              Icons.refresh_outlined,
              size: 18,
              color: Colors.white,
            ),
            fuc: widget.onRefresh,
          ),
          const Spacer(),
          SizedBox(
            width: 30,
            child: PopupMenuButton<int>(
              padding: EdgeInsets.zero,
              onSelected: (value) {
                widget.liveRoomCtr!.changeQn(value);
              },
              child: Obx(
                () => Text(
                  widget.liveRoomCtr!.currentQnDesc.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              itemBuilder: (BuildContext context) {
                return widget.liveRoomCtr!.acceptQnList.map((e) {
                  return PopupMenuItem<int>(
                    value: e['code'],
                    child: Text(e['desc']),
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(width: 10),
          if (Platform.isAndroid) ...[
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  bool canUsePiP = false;
                  widget.controller!.hiddenControls(false);
                  try {
                    canUsePiP = await widget.floating!.isPipAvailable;
                  } on PlatformException catch (_) {
                    canUsePiP = false;
                  }
                  if (canUsePiP) {
                    await widget.floating!.enable();
                  } else {}
                },
                icon: const Icon(
                  Icons.picture_in_picture_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            )
          ],
          ComBtn(
            icon: Obx(
              () => Icon(
                _.isFullScreen.value
                    ? FontAwesomeIcons.compress
                    : FontAwesomeIcons.expand,
                size: 15,
                color: Colors.white,
              ),
            ),
            fuc: () {
              _.triggerFullScreen(status: !_.isFullScreen.value);
              widget.fullScreenCb?.call(!_.isFullScreen.value);
            },
          )
        ],
      ),
    );
  }
}
