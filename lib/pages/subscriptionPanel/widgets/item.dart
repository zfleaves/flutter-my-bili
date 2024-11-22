import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/common/sub_type.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SubPanelItem extends StatelessWidget {
  final SubType subType;
  final dynamic videoItem;
  final dynamic ctr;
  final Function? onChoose;
  final Function? onUpdateMultiple;
  const SubPanelItem(
      {super.key,
      required this.videoItem,
      this.ctr,
      this.onChoose,
      this.onUpdateMultiple,
      required this.subType});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(videoItem.mediaId);
    return InkWell(
      onTap: () {
        RoutePush.bangumiPush(videoItem.seasonId, null, heroTag: heroTag);
      },
      onLongPress: () =>
          imageSaveDialog(context, videoItem, SmartDialog.dismiss),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                StyleString.safeSpace, 5, StyleString.safeSpace, 5),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                double width =
                    (boxConstraints.maxWidth - StyleString.cardSpace * 6);
                return SizedBox(
                  width: boxConstraints.maxWidth,
                  // color: Colors.red,
                  height: width / (StyleString.aspectRatio) * 0.8,
                  // child: Text('${boxConstraints.maxWidth}'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: boxConstraints.maxWidth * 0.35,
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 12 / 16,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double maxWidth = constraints.maxWidth;
                                  double maxHeight = constraints.maxHeight;
                                  return Stack(
                                    children: [
                                      Hero(
                                        tag: heroTag,
                                        child: NetworkImgLayer(
                                          src: (videoItem.cover != ''
                                              ? videoItem.cover
                                              : ''),
                                          width: maxWidth,
                                          height: maxHeight,
                                        ),
                                      ),
                                      if (videoItem.badge != null) ...[
                                        PBadge(
                                          text: videoItem.badge,
                                          top: 0,
                                          right: 0,
                                          bottom: null,
                                          left: null,
                                          type: videoItem.badge.contains('会员') ? 'vip' : 'owner',
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      VideoContent(
                        videoItem: videoItem,
                        ctr: ctr,
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  final dynamic videoItem;
  final dynamic ctr;
  const VideoContent({super.key, required this.videoItem, this.ctr});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 6, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                videoItem.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                videoItem.summary,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.outline),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: videoItem.seasonTypeName,
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      fontWeight: FontWeight.w200),
                ),
                TextSpan(
                  text: '  |  ',
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      fontWeight: FontWeight.w200),
                ),
                TextSpan(
                  text: videoItem.areas!.isNotEmpty
                      ? videoItem.areas!.first['name']
                      : '',
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      fontWeight: FontWeight.w200),
                ),
              ])),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: videoItem.progress,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                    ),
                    TextSpan(
                      text: '  |  ',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelMedium!.fontSize,
                          fontWeight: FontWeight.w200),
                    ),
                    TextSpan(
                      text: videoItem.newEp['index_show'],
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                    ),
                  ])),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      tooltip: '功能菜单',
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.outline,
                        size: 14,
                      ),
                      position: PopupMenuPosition.under,
                      onSelected: (String type) {},
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                          ...buildBottomControl(videoItem, ctr)
                        // PopupMenuItem<String>(
                        //   onTap: () => {},
                        //   value: 'pause',
                        //   height: 35,
                        //   child: const Text('删除记录',
                        //       style: TextStyle(fontSize: 13)),
                        // ),
                      ],
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }

  // 动态构建底部控制条
  List<PopupMenuItem<String>> buildBottomControl(videoItem, ctr) {
    List<PopupMenuItem<String>> list = SubFilterType.values.sublist(1)
        .map((v) => PopupMenuItem<String>(
          onTap: () => {
            ctr.handleOperate(videoItem, v.followStatus, '标记为${v.label}')
          },
          value: v.id,
          height: 35,
          enabled: v.followStatus != videoItem.followStatus,
          child: Text('标记为${v.label}',
          style: const TextStyle(fontSize: 13)),
        ))
        .toList();
    list.add(
      PopupMenuItem<String>(
          onTap: () => {
            ctr.handleOperate(videoItem, -1, '取消${ctr.subType == SubType.video ? '追剧' : '追番'}')
          },
          value: 'cancel',
          height: 35,
          child: Text('取消${ctr.subType == SubType.video ? '追剧' : '追番'}',
          style: const TextStyle(fontSize: 13)),
        )
    );
    return list;
  }
}
