import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TvCardFeed extends StatelessWidget {
  final dynamic tVItem;
  const TvCardFeed({super.key, required this.tVItem });

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(tVItem.seasonId);

    return InkWell(
      onTap: () {
        RoutePush.bangumiPush(tVItem.seasonId, null, heroTag: heroTag);
      },
      onLongPress: () => imageSaveDialog(context, tVItem, SmartDialog.dismiss),
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
                            src: tVItem.cover,
                          )),
                      if (tVItem.rating != null) ...[
                        PBadge(
                          text: tVItem.rating,
                          bottom: 2,
                          right: 2,
                          top: null,
                          left: null,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          TvCardContent(tVItem: tVItem,)
        ],
      ),
    );
  }
}

class TvCardContent extends StatelessWidget {
  final dynamic tVItem;
  const TvCardContent({super.key, required this.tVItem});

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
                    '${tVItem.title}',
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
            Text(
              tVItem.subTitle,
              maxLines: 1,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
