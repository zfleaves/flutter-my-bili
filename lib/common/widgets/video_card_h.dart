import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/common/widgets/stat/danmu.dart';
import 'package:bilibili/common/widgets/stat/view.dart';
import 'package:bilibili/http/search.dart';
import 'package:bilibili/http/user.dart';
import 'package:bilibili/http/video.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/utils/constants.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/image_save.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/url_utils.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class VideoCardH extends StatelessWidget {
  final videoItem;
  final Function()? onPressedFn;
  // normal 推荐, later 稍后再看, search 搜索
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;
  final bool showCharge;
  const VideoCardH({
    super.key,
    required this.videoItem,
    this.onPressedFn,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
    this.showCharge = false,
  });

  Widget build(BuildContext context) {
    final int aid = videoItem.aid;
    final String bvid = videoItem.bvid;
    String type = 'video';
    try {
      type = videoItem.type;
    } catch (_) {}
    final String heroTag = Utils.makeHeroTag(aid);
    return InkWell(
      onTap: () async {
        try {
          if (type == 'ketang') {
            SmartDialog.showToast('课堂视频暂不支持播放');
            return;
          }
          if (showCharge && videoItem?.typeid == 33) {
            final String redirectUrl = await UrlUtils.parseRedirectUrl(
                '${HttpString.baseUrl}/video/$bvid/');
            final String lastPathSegment = redirectUrl.split('/').last;
            if (lastPathSegment.contains('ss')) {
              RoutePush.bangumiPush(
                  Utils.matchNum(lastPathSegment).first, null, videoType: SearchType.video);
            }
            if (lastPathSegment.contains('ep')) {
              RoutePush.bangumiPush(
                  null, Utils.matchNum(lastPathSegment).first, videoType: SearchType.video);
            }
            return;
          }
          final int cid =
              videoItem.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
          Get.toNamed('/video?bvid=$bvid&cid=$cid',
              arguments: {'videoItem': videoItem, 'heroTag': heroTag});
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
      },
      onLongPress: () =>
          imageSaveDialog(context, videoItem, SmartDialog.dismiss),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 5, StyleString.safeSpace, 5),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
          final double width = (boxConstraints.maxWidth -
                  StyleString.cardSpace *
                      6 /
                      MediaQuery.textScalerOf(context).scale(1.0)) /
              2;
          return Container(
            constraints: const BoxConstraints(minHeight: 88),
            height: width / StyleString.aspectRatio,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: StyleString.aspectRatio,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints boxConstraints) {
                    final double maxWidth = boxConstraints.maxWidth;
                    final double maxHeight = boxConstraints.maxHeight;
                    return Stack(
                      children: [
                        Hero(
                            tag: heroTag,
                            child: NetworkImgLayer(
                              width: maxWidth,
                              height: maxHeight,
                              src: videoItem.pic as String,
                            )),
                        if (videoItem.duration != 0)
                          PBadge(
                            text: Utils.timeFormat(videoItem.duration!),
                            right: 6.0,
                            bottom: 6.0,
                            type: 'gray',
                          ),
                        if (type != 'video')
                          PBadge(
                            text: type,
                            left: 6.0,
                            bottom: 6.0,
                            type: 'primary',
                          ),
                        if (showCharge && videoItem?.isChargingSrc)
                          const PBadge(
                            text: '充电专属',
                            right: 6.0,
                            top: 6.0,
                            type: 'primary',
                          ),
                      ],
                    );
                  }),
                ),
                VideoContent(
                  videoItem: videoItem,
                  source: source,
                  showOwner: showOwner,
                  showView: showView,
                  showDanmaku: showDanmaku,
                  showPubdate: showPubdate,
                  onPressedFn: onPressedFn,
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  final videoItem;
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;
  final Function()? onPressedFn;

  const VideoContent({
    super.key,
    required this.videoItem,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
    this.onPressedFn,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (source == 'normal' || source == 'later') ...[
              Text(
                videoItem.title as String,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              RichText(
                maxLines: 2,
                text: TextSpan(
                  children: [
                    for (final i in videoItem.titleList) ...[
                      TextSpan(
                        text: i['text'] as String,
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
            ],
            const Spacer(),
            if (showPubdate)
              Text(
                Utils.dateFormat(videoItem.pubdate!),
                style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.outline),
              ),
            if (showOwner)
              Row(
                children: [
                  Text(
                    videoItem.owner.name as String,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                if (showView) ...[
                  StatView(
                    theme: 'gray',
                    view: videoItem.stat.view as int,
                  ),
                  const SizedBox(width: 8),
                ],
                if (showDanmaku) ...[
                  StatDanMu(
                    theme: 'gray',
                    danmu: videoItem.stat.danmaku as int,
                  ),
                ],
                const Spacer(),
                if (source == 'normal') ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        feedBack();
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          builder: (context) {
                            return MorePanel(videoItem: videoItem);
                          },
                        );
                      }, 
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.outline,
                        size: 14,
                      ),
                    ),
                  )
                ],
                if (source == 'later') ...[
                  IconButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () => onPressedFn?.call(),
                    icon: Icon(
                      Icons.clear_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 18,
                    ),
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}


class MorePanel extends StatelessWidget {
  final dynamic videoItem;
  const MorePanel({super.key, required this.videoItem});

  Future<dynamic> menuActionHandler(String type) async {
    switch (type) {
      case 'block':
        blockUser();
        break;
      case 'watchLater':
        var res = await UserHttp.toViewLater(bvid: videoItem.bvid as String);
        SmartDialog.showToast(res['msg']);
        Get.back();
        break;
      default:
    }
  }

  void blockUser() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text('确定拉黑:${videoItem.owner.name}(${videoItem.owner.mid})?'
              '\n\n注：被拉黑的Up可以在隐私设置-黑名单管理中解除'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                var res = await VideoHttp.relationMod(
                  mid: videoItem.owner.mid,
                  act: 5,
                  reSrc: 11,
                );
                SmartDialog.dismiss();
                SmartDialog.showToast(res['msg'] ?? '成功');
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 35,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('block'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text(
              '拉黑up主 「${videoItem.owner.name}」',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('watchLater'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.watch_later_outlined, size: 19),
            title:
                Text('添加至稍后再看', style: Theme.of(context).textTheme.titleSmall),
          ),
          ListTile(
            onTap: () =>
                imageSaveDialog(context, videoItem, SmartDialog.dismiss),
            minLeadingWidth: 0,
            leading: const Icon(Icons.photo_outlined, size: 19),
            title:
                Text('查看视频封面', style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}