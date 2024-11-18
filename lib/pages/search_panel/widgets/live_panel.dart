import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

Widget searchLivePanel(BuildContext context, ctr, list) {
  return Padding(
    padding: const EdgeInsets.only(
        left: StyleString.safeSpace, right: StyleString.safeSpace),
    child: GridView.builder(
      primary: false,
      controller: ctr!.scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: StyleString.cardSpace + 2,
          mainAxisSpacing: StyleString.cardSpace + 3,
          mainAxisExtent:
              MediaQuery.sizeOf(context).width / 2 / StyleString.aspectRatio +
                  MediaQuery.textScalerOf(context).scale(66.0)),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return LiveItem(liveItem: list![index]);
      },
    ),
  );
}

class LiveItem extends StatelessWidget {
  final dynamic liveItem;
  const LiveItem({super.key, required this.liveItem});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(liveItem.roomid);
    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          Get.toNamed('/liveRoom?roomid=${liveItem.roomid}',
              arguments: {'liveItem': liveItem, 'heroTag': heroTag});
        },
        onLongPress: () => imageSaveDialog(
          context,
          liveItem,
          SmartDialog.dismiss,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(StyleString.imgRadius),
              child: AspectRatio(
                aspectRatio: StyleString.aspectRatio,
                child: LayoutBuilder(builder: (context, boxConstraints) {
                  double maxWidth = boxConstraints.maxWidth;
                  double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    children: [
                      Hero(
                        tag: heroTag,
                        child: NetworkImgLayer(
                          src: liveItem.cover,
                          type: 'emote',
                          width: maxWidth,
                          height: maxHeight,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 200),
                          child: LiveStat(
                            online: liveItem.online,
                            cateName: liveItem.cateName,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            LiveContent(liveItem: liveItem)
          ],
        ),
      ),
    );
  }
}

class LiveContent extends StatelessWidget {
  final dynamic liveItem;
  const LiveContent({super.key, this.liveItem});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 8, 9, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  for (var i in liveItem.titleList) ...[
                    TextSpan(
                      text: i['text'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: i['type'] == 'em'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                liveItem.uname,
                maxLines: 1,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveStat extends StatelessWidget {
  final int? online;
  final String? cateName;
  const LiveStat({super.key, required this.online, this.cateName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(top: 22, left: 8, right: 8),
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
            cateName!,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          Text(
            '围观:${online.toString()}',
            style: const TextStyle(fontSize: 11, color: Colors.white),
          )
        ],
      ),
    );
  }
}
