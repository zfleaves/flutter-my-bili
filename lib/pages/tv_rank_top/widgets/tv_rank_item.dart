import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/stat/collect.dart';
import 'package:bilibili/common/widgets/stat/view.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class TvRankItem extends StatelessWidget {
  final dynamic tvRankItem;
  final int index;
  const TvRankItem({super.key, required this.tvRankItem, required this.index});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(tvRankItem.seasonId);
    return InkWell(
      onTap: () {
        RoutePush.bangumiPush(tvRankItem.seasonId, null, heroTag: heroTag);
      },
      onLongPress: () =>
          imageSaveDialog(context, tvRankItem, SmartDialog.dismiss),
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
                  // width: 200,
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
                                          src: (tvRankItem.cover != ''
                                              ? tvRankItem.cover
                                              : ''),
                                          width: maxWidth,
                                          height: maxHeight,
                                        ),
                                      ),
                                      if (tvRankItem.badge != null) ...[
                                        PBadge(
                                          text: tvRankItem.badge,
                                          top: 2,
                                          right: 2,
                                          bottom: null,
                                          left: null,
                                          type: tvRankItem.badge!.contains('会员')
                                              ? 'vip'
                                              : 'owner',
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
                                                fontSize: 16),
                                          ),
                                        )
                                      ]
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      TvRankContent(tvRankItem: tvRankItem)
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

class TvRankContent extends StatelessWidget {
  final dynamic tvRankItem;
  const TvRankContent({super.key, required this.tvRankItem});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tvRankItem.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            if (tvRankItem.rating != null) ...[
              const SizedBox(height: 2),
              Text(
                tvRankItem.rating,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            if (tvRankItem.newEp['index_show'] != null) ...[
              Text(
                tvRankItem.newEp['index_show'],
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StatView(theme: 'white', view: tvRankItem.stat['view']),
                const SizedBox(
                  width: 10,
                ),
                CollectView(theme: 'white', view: tvRankItem.stat['follow']),
              ],
            )
          ],
        ),
      ),
    );
  }
}
