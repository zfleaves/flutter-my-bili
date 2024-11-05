import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/bangumi/list.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// 视频卡片 - 垂直布局
class BangumiCardV extends StatelessWidget {
  final BangumiListItemModel bangumiItem;
  const BangumiCardV({super.key, required this.bangumiItem});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(bangumiItem.mediaId);
    return InkWell(
      onTap: () {
        RoutePush.bangumiPush(bangumiItem.seasonId, null, heroTag: heroTag);
      },
      onLongPress: () =>
          imageSaveDialog(context, bangumiItem, SmartDialog.dismiss),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(
              StyleString.imgRadius,
            ),
            child: AspectRatio(
              aspectRatio: 0.70,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  final double maxWidth = boxConstraints.maxWidth;
                  final double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    children: [
                      Hero(
                          tag: heroTag,
                          child: NetworkImgLayer(
                            width: maxWidth,
                            height: maxHeight,
                            src: bangumiItem.cover,
                          )),
                      if (bangumiItem.badge != null) ...[
                        PBadge(
                            text: bangumiItem.badge,
                            top: 6,
                            right: 6,
                            bottom: null,
                            left: null),
                      ],
                      if (bangumiItem.order != null) ...[
                        PBadge(
                          text: bangumiItem.order,
                          top: null,
                          right: null,
                          bottom: 6,
                          left: 6,
                          type: 'gray',
                        ),
                      ]
                    ],
                  );
                },
              ),
            ),
          ),
          BangumiContent(bangumiItem: bangumiItem),
        ],
      ),
    );
  }
}

class BangumiContent extends StatelessWidget {
  final BangumiListItemModel bangumiItem;
  const BangumiContent({super.key, required this.bangumiItem});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        // 多列
        padding: const EdgeInsets.fromLTRB(4, 5, 0, 3),
        // 单列
        // padding: const EdgeInsets.fromLTRB(14, 10, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${bangumiItem.title}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(height: 1),
            if (bangumiItem.indexShow != null) ...[
              Text(
                '${bangumiItem.indexShow}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            if (bangumiItem.progress != null) ...[
              Text(
                '${bangumiItem.progress}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
