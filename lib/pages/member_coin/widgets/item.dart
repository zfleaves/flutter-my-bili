import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/stat/view.dart';
import 'package:bilibili/http/search.dart';
import 'package:bilibili/models/member/coin.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MemberCoinsItem extends StatelessWidget {
  final MemberCoinsDataModel coinItem;
  const MemberCoinsItem({super.key, required this.coinItem});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(coinItem.aid);
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          int cid =
              await SearchHttp.ab2c(aid: coinItem.aid, bvid: coinItem.bvid);
          Get.toNamed('/video?bvid=${coinItem.bvid}&cid=$cid',
              arguments: {'videoItem': coinItem, 'heroTag': heroTag});
        },
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: StyleString.aspectRatio,
              child: LayoutBuilder(builder: (context, boxConstraints) {
                double maxWidth = boxConstraints.maxWidth;
                double maxHeight = boxConstraints.maxHeight;
                return Stack(
                  children: [
                    NetworkImgLayer(
                      src: coinItem.pic,
                      width: maxWidth,
                      height: maxHeight,
                    ),
                    if (coinItem.duration != null) ...[
                      PBadge(
                        bottom: 6,
                        right: 6,
                        type: 'gray',
                        text: Utils.timeFormat(coinItem.duration),
                      )
                    ]
                  ],
                );
              })
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 6, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinItem.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatView(
                        view: coinItem.view,
                        theme: 'gray',
                      ),
                      const Spacer(),
                      Text(
                        Utils.CustomStamp_str(
                            timestamp: coinItem.pubdate, date: 'MM-DD'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 6)
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}