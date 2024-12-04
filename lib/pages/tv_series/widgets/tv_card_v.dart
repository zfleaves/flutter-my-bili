import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class TvCardV extends StatelessWidget {
  final dynamic tVItem;
  final int index;
  final int seasonType;
  const TvCardV({super.key, required this.tVItem, required this.index, this.seasonType = 5});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(tVItem.seasonId);

    return InkWell(
      onTap: () {
        SearchType videoType = seasonType == 5 ? SearchType.video : SearchType.media_ft;
        RoutePush.bangumiPush(tVItem.seasonId, null, heroTag: heroTag, videoType: videoType);
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
                      if (tVItem.badge != null) ...[
                        PBadge(
                          text: tVItem.badge,
                          top: 0,
                          right: 0,
                          bottom: null,
                          left: null,
                          type: tVItem.badge.contains('会员') ? 'vip' : 'owner',
                        ),
                      ],
                      if (index <= 3) ...[
                        Positioned(
                          top: 0,
                          left: 0,
                          child: SvgPicture.asset(
                            'assets/images/top/top$index.svg',
                            width: 58 * 0.7,
                            height: 42 * 0.7,
                          ),
                        )
                      ] else ...[
                        Positioned(
                          top: 0,
                          left: 0,
                          child: SvgPicture.asset(
                            'assets/images/top/top4.svg',
                            width: 58 * 0.7,
                            height: 42 * 0.7,
                            // ignore: deprecated_member_use
                            color: Theme.of(context)
                                .colorScheme
                                .outline,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 10,
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                        )
                      ]
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
              tVItem.desc,
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
