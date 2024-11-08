import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/stat/view.dart';
import 'package:bilibili/http/search.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MemberSeasonsItem extends StatelessWidget {
  final dynamic seasonItem;
  const MemberSeasonsItem({super.key, required this.seasonItem});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(seasonItem.aid);
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          int cid =
              await SearchHttp.ab2c(aid: seasonItem.aid, bvid: seasonItem.bvid);
          Get.toNamed('/video?bvid=${seasonItem.bvid}&cid=$cid',
              arguments: {'videoItem': seasonItem, 'heroTag': heroTag});
        },
        onLongPress: () => imageSaveDialog(
          context,
          seasonItem,
          SmartDialog.dismiss,
        ),
        child: Column(
          children: [
            AspectRatio(
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
                          src: seasonItem.pic,
                          width: maxWidth,
                          height: maxHeight,
                        ),
                      ),
                      if (seasonItem.pubdate != null) ...[
                        PBadge(
                          bottom: 6,
                          right: 6,
                          type: 'gray',
                          text: Utils.timeFormat(seasonItem.duration),
                        )
                      ]
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 6, 0, 0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seasonItem.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatView(
                        view: seasonItem.view,
                        theme: 'gray',
                      ),
                      const Spacer(),
                      Text(
                        Utils.CustomStamp_str(
                            timestamp: seasonItem.pubdate, date: 'YY-MM-DD'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 6)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
