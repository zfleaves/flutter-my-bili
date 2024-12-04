import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Widget searchMoviePanel(BuildContext context, ctr, list) {
  TextStyle style =
      TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize);
  TextStyle? titleMedium = Theme.of(context).textTheme.titleMedium;
  TextStyle? labelMedium = Theme.of(context).textTheme.labelMedium;
  Color textColor = const Color.fromRGBO(231, 129, 166, 1);
  return ListView.builder(
    controller: ctr!.scrollController,
    addAutomaticKeepAlives: false,
    addRepaintBoundaries: false,
    itemCount: list!.length,
    itemBuilder: (context, index) {
      var i = list![index];
      String heroTag = Utils.makeHeroTag(i.seasonId);
      return InkWell(
        onTap: () {
          RoutePush.bangumiPush(i.seasonId, null, heroTag: heroTag, videoType: SearchType.media_ft);
        },
        onLongPress: () => imageSaveDialog(context, i, SmartDialog.dismiss),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              StyleString.safeSpace, 7, StyleString.safeSpace, 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: heroTag, 
                    child: NetworkImgLayer(
                      width: 111,
                      height: 148,
                      src: i.cover,
                    ),
                  ),
                  PBadge(
                    text: i.seasonTypeName,
                    top: 6.0,
                    right: 4.0,
                    bottom: null,
                    left: null,
                    type: 'vip',
                  )
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 148,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.title,
                        style: TextStyle(
                            fontWeight: titleMedium?.fontWeight,
                            fontSize: titleMedium?.fontSize,
                            color: textColor),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          if (i.badges.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: textColor),
                              ),
                              child: Text(
                                i.badges.first.text,
                                style: TextStyle(
                                    fontWeight: labelMedium?.fontWeight,
                                    fontSize: labelMedium?.fontSize,
                                    color: Colors.red),
                              ),
                            )
                          ],
                          Text.rich(TextSpan(style: labelMedium, children: [
                            TextSpan(
                              text: Utils.dateFormat(i.pubtime)
                                  .toString()
                                  .substring(0, 4),
                            ),
                            const TextSpan(
                              text: ' | ',
                            ),
                            TextSpan(
                              text: i.areas,
                            ),
                          ]))
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              i.cv.replaceAll('\n', ' '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: labelMedium,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${i.mediaScore.score}',
                              style: TextStyle(
                                fontWeight: titleMedium?.fontWeight,
                                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                                color: const Color.fromRGBO(252,127,34, 1)
                              )
                            ),
                            TextSpan(
                              text: ' 分',
                              style: TextStyle(
                                fontWeight: labelMedium?.fontWeight,
                                fontSize: labelMedium?.fontSize,
                                color: const Color.fromRGBO(252,127,34, 1)
                              )
                            ),
                            TextSpan(
                              text: '  ${i.mediaScore.userCount}人参与',
                              style: TextStyle(
                                fontWeight: labelMedium?.fontWeight,
                                fontSize: labelMedium?.fontSize,
                                color: Colors.black45
                              )
                            )
                          ]
                        )
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.fromLTRB(10, 2, 10, 2)),
                        // foregroundColor: WidgetStateProperty(),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return const Color.fromRGBO(252, 104, 154, 1);
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return Colors.white;
                        }),
                      ),
                      onPressed: () {
                        RoutePush.bangumiPush(i.seasonId, null,
                            videoType: SearchType.media_ft);
                      },
                      child: const Text('立即观看'),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                      onTap: () {},
                      child: i.isFollow == 0
                          ? Container(
                              alignment: Alignment.center,
                              height: 28,
                              width: 76,
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: textColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: textColor,
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    '追剧',
                                    style: labelMedium,
                                  )
                                ],
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              height: 28,
                              width: 76,
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      const Color.fromRGBO(228, 229, 231, 1)),
                              child: Text(
                                '已追剧',
                                style: TextStyle(
                                    fontWeight: labelMedium?.fontWeight,
                                    fontSize: labelMedium?.fontSize,
                                    color:
                                        const Color.fromRGBO(151, 151, 151, 1)),
                              )))
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
