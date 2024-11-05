import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/live/item.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class LiveCardV extends StatelessWidget {
  final LiveItemModel liveItem;
  final int crossAxisCount;
  const LiveCardV(
      {super.key, required this.liveItem, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(liveItem.roomId);
    return InkWell(
      onLongPress: () =>
          imageSaveDialog(context, liveItem, SmartDialog.dismiss),
      onTap: () {
        Get.toNamed('/liveRoom?roomId=${liveItem.roomId}',
            arguments: {'liveItem': liveItem, 'heroTag': heroTag});
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(StyleString.imgRadius),
            child: AspectRatio(
              aspectRatio: StyleString.aspectRatio,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  double maxWidth = boxConstraints.maxWidth;
                  double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    children: [
                      Hero(
                          tag: heroTag,
                          child: NetworkImgLayer(
                            width: maxWidth,
                            height: maxHeight,
                            src: liveItem.cover,
                          )),
                      if (crossAxisCount != 1) ...[
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 200),
                              child: VideoStat(
                                liveItem: liveItem,
                              ),
                            ))
                      ]
                    ],
                  );
                },
              ),
            ),
          ),
          LiveContent(liveItem: liveItem, crossAxisCount: crossAxisCount)
        ],
      ),
    );
  }
}

class LiveContent extends StatelessWidget {
  final dynamic liveItem;
  final int crossAxisCount;
  const LiveContent(
      {super.key, required this.liveItem, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: crossAxisCount == 1 ? 0 : 1,
      child: Padding(
        padding: crossAxisCount == 1
          ? const EdgeInsets.fromLTRB(9, 9, 9, 4)
          : const EdgeInsets.fromLTRB(5, 8, 5, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              liveItem.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (crossAxisCount == 1) const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    liveItem.uname,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                if (crossAxisCount == 1) ...[
                  Text(
                    ' • ${liveItem!.areaName!}',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Text(
                    ' • ${liveItem!.watchedShow!['text_small']}人观看',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

class VideoStat extends StatelessWidget {
  final LiveItemModel liveItem;
  const VideoStat({super.key, required this.liveItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(top: 26, left: 10, right: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black54,
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            liveItem.areaName!,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          Text(
            liveItem.watchedShow!['text_small'],
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
