import 'package:appscheme/appscheme.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/common/reply_type.dart';
import 'package:bilibili/models/video/reply/item.dart';
import 'package:bilibili/pages/preview/view.dart';
import 'package:bilibili/pages/video/detail/controller.dart';
import 'package:bilibili/pages/video/detail/reply_new/view.dart';
import 'package:bilibili/pages/video/detail/reply/widgets/zan.dart';
import 'package:bilibili/utils/app_scheme.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/url_utils.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

Box setting = GStrorage.setting;

class ReplyItem extends StatelessWidget {
  const ReplyItem({
    this.replyItem,
    this.addReply,
    this.replyLevel,
    this.showReplyRow = true,
    this.replyReply,
    this.replyType,
    super.key,
  });
  final ReplyItemModel? replyItem;
  final Function? addReply;
  final String? replyLevel;
  final bool? showReplyRow;
  final Function? replyReply;
  final ReplyType? replyType;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        // 点击整个评论区 评论详情/回复
        onTap: () {
          feedBack();
          if (replyReply != null) {
            replyReply!(replyItem);
          }
        },
        onLongPress: () {
          feedBack();
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) {
              return MorePanel(item: replyItem);
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            width: 1,
            color:
                Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.5),
          ))),
          child: content(context),
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(replyItem!.mid);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          // HitTestBehavior.opaque 可以确保 GestureDetector 完全捕获其边界内的所有触摸事件，而不受下层组件的影响
          behavior: HitTestBehavior.opaque,
          onTap: () {
            feedBack();
            Get.toNamed('/member?mid=${replyItem!.mid}', arguments: {
              'face': replyItem!.member!.avatar!,
              'heroTag': heroTag,
              'uname': replyItem!.member!.uname!,
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              lfAvtar(context, heroTag),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        replyItem!.member!.uname!,
                        style: TextStyle(
                          color: replyItem!.member!.vip!['vipStatus'] > 0
                              ? const Color.fromARGB(255, 251, 100, 163)
                              : colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Image.asset(
                          'assets/images/lv/lv${replyItem!.member!.level}.png',
                          height: 11,
                        ),
                      ),
                      if (replyItem!.isUp!) ...[
                        const PBadge(
                          text: 'UP',
                          size: 'small',
                          stack: 'normal',
                          fs: 9,
                        ),
                      ]
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        Utils.dateFormat(replyItem!.ctime),
                        style: TextStyle(
                          fontSize: textTheme.labelSmall!.fontSize,
                          color: colorScheme.outline,
                        ),
                      ),
                      if (replyItem!.replyControl != null &&
                          replyItem!.replyControl!.location != '') ...[
                        Text(
                          ' • ${replyItem!.replyControl!.location!}',
                          style: TextStyle(
                              fontSize: textTheme.labelSmall!.fontSize,
                              color: colorScheme.outline),
                        ),
                      ]
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 45, right: 6, bottom: 4),
          child: Text.rich(
              style: const TextStyle(height: 1.75),
              maxLines:
                  replyItem!.content!.isText! && replyLevel == '1' ? 3 : 999,
              overflow: TextOverflow.ellipsis,
              TextSpan(children: [
                if (replyItem!.isTop!) ...[
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: PBadge(
                      text: 'TOP',
                      size: 'small',
                      stack: 'normal',
                      type: 'line',
                      fs: 9,
                    ),
                  ),
                ],
                buildContent(context, replyItem!, replyReply, null),
              ])),
        ),
        // 操作区域
        bottonAction(context, replyItem!.replyControl),
        // 一楼的评论
        if ((replyItem!.replyControl!.isShow! ||
                replyItem!.replies!.isNotEmpty) &&
            showReplyRow!) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 12),
            child: ReplyItemRow(
              replies: replyItem!.replies,
              replyControl: replyItem!.replyControl,
              // f_rpid: replyItem!.rpid,
              replyItem: replyItem,
              replyReply: replyReply,
            ),
          ),
        ],
      ],
    );
  }

  // 头像+ 身份角标
  Widget lfAvtar(BuildContext context, String heroTag) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: NetworkImgLayer(
            src: replyItem!.member!.avatar,
            width: 34,
            height: 34,
            type: 'avatar',
          ),
        ),
        if (replyItem!.member!.officialVerify != null &&
            replyItem!.member!.officialVerify!['type'] == 0) ...[
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: colorScheme.surface,
              ),
              child: Icon(
                Icons.offline_bolt,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
          ),
          if (replyItem!.member!.vip!['vipStatus'] > 0 &&
              replyItem!.member!.vip!['vipType'] == 2) ...[
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: colorScheme.surface,
                ),
                child: Image.asset(
                  'assets/images/big-vip.png',
                  height: 14,
                ),
              ),
            ),
          ]
        ],
      ],
    );
  }

  // 感谢、回复、复制
  Widget bottonAction(BuildContext context, replyControl) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        const SizedBox(width: 32),
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: () {
              feedBack();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (builder) {
                  return VideoReplyNewDialog(
                    oid: replyItem!.oid,
                    root: replyItem!.rpid,
                    parent: replyItem!.rpid,
                    replyType: replyType,
                    replyItem: replyItem,
                  );
                },
              ).then((value) => {
                    // 完成评论，数据添加
                    if (value != null && value['data'] != null)
                      {
                        addReply?.call(value['data'])
                        // replyControl.replies.add(value['data']),
                      }
                  });
            },
            child: Row(children: [
              Icon(Icons.reply,
                  size: 18, color: colorScheme.outline.withOpacity(0.8)),
              const SizedBox(width: 3),
              Text(
                '回复',
                style: TextStyle(
                  fontSize: textTheme.labelMedium!.fontSize,
                  color: colorScheme.outline,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 2),
        if (replyItem!.upAction!.like!) ...[
          Text(
            'up主觉得很赞',
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: textTheme.labelMedium!.fontSize),
          ),
          const SizedBox(width: 2),
        ],
        if (replyItem!.cardLabel!.isNotEmpty &&
            replyItem!.cardLabel!.contains('热评'))
          Text(
            '热评',
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: textTheme.labelMedium!.fontSize),
          ),
        const Spacer(),
        ZanButton(replyItem: replyItem, replyType: replyType),
        const SizedBox(width: 5)
      ],
    );
  }
}

class ReplyItemRow extends StatelessWidget {
  ReplyItemRow({
    super.key,
    this.replies,
    this.replyControl,
    // this.f_rpid,
    this.replyItem,
    this.replyReply,
  });
  final List? replies;
  ReplyControl? replyControl;
  // int? f_rpid;
  ReplyItemModel? replyItem;
  Function? replyReply;

  @override
  Widget build(BuildContext context) {
    final bool isShow = replyControl!.isShow!;
    final int extraRow = replyControl != null && isShow ? 1 : 0;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(left: 42, right: 4, top: 0),
      child: Material(
        color: colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        animationDuration: Duration.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replies!.isNotEmpty) ...[
              for (int i = 0; i < replies!.length; i++) ...[
                InkWell(
                  onLongPress: () {
                    feedBack();
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return MorePanel(item: replies![i]);
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      8,
                      i == 0 && (extraRow == 1 || replies!.length > 1) ? 8 : 5,
                      8,
                      6,
                    ),
                    child: Text.rich(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        TextSpan(children: [
                          TextSpan(
                            text: replies![i].member.uname + ' ',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .fontSize,
                              color: colorScheme.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                feedBack();
                                final String heroTag =
                                    Utils.makeHeroTag(replies![i].member.mid);
                                Get.toNamed(
                                    '/member?mid=${replies![i].member.mid}',
                                    arguments: {
                                      'face': replies![i].member.avatar,
                                      'heroTag': heroTag,
                                      'uname': replies![i].member.uname
                                    });
                              },
                          ),
                          if (replies![i].isUp) ...[
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: PBadge(
                                text: 'UP',
                                size: 'small',
                                stack: 'normal',
                                fs: 9,
                              ),
                            ),
                          ],
                          buildContent(
                              context, replies![i], replyReply, replyItem),
                        ])),
                  ),
                )
              ]
            ],
            if (extraRow == 1) ...[
              InkWell(
                // 一楼点击【共xx条回复】展开评论详情
                onTap: () => replyReply!(replyItem),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: textTheme.labelMedium!.fontSize,
                      ),
                      children: [
                        if (replyControl!.upReply!)
                          const TextSpan(text: 'up主等人 '),
                        TextSpan(
                          text: replyControl!.entryText!,
                          style: TextStyle(
                            color: colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// 富文本渲染
InlineSpan buildContent(
    BuildContext context, replyItem, replyReply, fReplyItem) {
  final String routePath = Get.currentRoute;
  bool isVideoPage = routePath.startsWith('/video');
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  // replyItem 当前回复内容
  // replyReply 查看二楼回复（回复详情）回调
  // fReplyItem 父级回复内容，用作二楼回复（回复详情）展示
  final content = replyItem.content;
  final List<InlineSpan> spanChilds = <InlineSpan>[];
  // 投票
  if (content.vote.isNotEmpty) {
    content.message.splitMapJoin(RegExp(r"\{vote:.*?\}"),
        onMatch: (Match match) {
      // String matchStr = match[0]!;
      spanChilds.add(
        TextSpan(
          text: '投票: ${content.vote['title']}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Get.toNamed(
                  '/webview',
                  parameters: {
                    'url': content.vote['url'],
                    'type': 'vote',
                    'pageTitle': content.vote['title'],
                  },
                ),
        ),
      );
      return '';
    }, onNonMatch: (String str) {
      return str;
    });
  }
  content.message = content.message.replaceAll(RegExp(r"\{vote:.*?\}"), ' ');
  content.message = content.message
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ');
  // 构建正则表达式
  final List<String> specialTokens = [
    ...content.emote.keys,
    ...content.topicsMeta?.keys?.map((e) => '#$e#') ?? [],
    ...content.atNameToMid.keys.map((e) => '@$e'),
  ];
  List<dynamic> jumpUrlKeysList = content.jumpUrl.keys.map((e) {
    return e.replaceAllMapped(
        RegExp(r'[?+*]'), (match) => '\\${match.group(0)}');
  }).toList();

  String patternStr = specialTokens.map(RegExp.escape).join('|');
  if (patternStr.isNotEmpty) {
    patternStr += "|";
  }
  patternStr += r'(\b(?:\d+[:：])?[0-5]?[0-9][:：][0-5]?[0-9]\b)';
  if (jumpUrlKeysList.isNotEmpty) {
    patternStr += '|${jumpUrlKeysList.join('|')}';
  }
  RegExp bv23Regex = RegExp(r'https://b23\.tv/[a-zA-Z0-9]{7}');
  final RegExp pattern = RegExp(patternStr);
  List<String> matchedStrs = [];
  void addPlainTextSpan(str) {
    spanChilds.add(
      TextSpan(
        text: str,
        // TextSpan 本身并不直接支持手势识别器
        recognizer: TapGestureRecognizer()
          ..onTap = () =>
              replyReply?.call(replyItem.root == 0 ? replyItem : fReplyItem),
      ),
    );
  }

  // 分割文本并处理每个部分
  content.message.splitMapJoin(
    pattern,
    onMatch: (Match match) {
      String matchStr = match[0]!;
      if (content.emote.containsKey(matchStr)) {
        // 处理表情
        final int size = content.emote[matchStr]['meta']['size'];
        spanChilds.add(WidgetSpan(
          child: NetworkImgLayer(
            src: content.emote[matchStr]['url'],
            type: 'emote',
            width: size * 20,
            height: size * 20,
          ),
        ));
      } else if (matchStr.startsWith("@") &&
          content.atNameToMid.containsKey(matchStr.substring(1))) {
        // 处理@用户
        final String userName = matchStr.substring(1);
        final int userId = content.atNameToMid[userName];
        spanChilds.add(
          TextSpan(
            text: matchStr,
            style: TextStyle(
              color: colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final String heroTag = Utils.makeHeroTag(userId);
                Get.toNamed(
                  '/member?mid=$userId',
                  arguments: {
                    'face': '',
                    'heroTag': heroTag,
                    'uname': userName
                  },
                );
              },
          ),
        );
      } else if (RegExp(r'^\b(?:\d+[:：])?[0-5]?[0-9][:：][0-5]?[0-9]\b$')
          .hasMatch(matchStr)) {
        matchStr = matchStr.replaceAll('：', ':');
        spanChilds.add(
          TextSpan(
            text: ' $matchStr ',
            style: isVideoPage
                ? TextStyle(
                    color: colorScheme.primary,
                  )
                : null,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // 跳转到指定位置
                if (isVideoPage) {
                  try {
                    SmartDialog.showToast('跳转至：$matchStr');
                    Get.find<VideoDetailController>(
                            tag: Get.arguments['heroTag'])
                        .plPlayerController
                        .seekTo(
                          Duration(seconds: Utils.duration(matchStr)),
                        );
                  } catch (e) {
                    SmartDialog.showToast('跳转失败: $e');
                  }
                }
              },
          ),
        );
      } else {
        String appUrlSchema = '';
        final bool enableWordRe = setting.get(SettingBoxKey.enableWordRe,
            defaultValue: false) as bool;
        if (content.jumpUrl[matchStr] != null &&
            !matchedStrs.contains(matchStr)) {
          appUrlSchema = content.jumpUrl[matchStr]['app_url_schema'];
          if (appUrlSchema.startsWith('bilibili://search') && !enableWordRe) {
            addPlainTextSpan(matchStr);
            return "";
          }
          spanChilds.addAll(
            [
              if (content.jumpUrl[matchStr]?['prefix_icon'] != null) ...[
                WidgetSpan(
                  child: Image.network(
                    content.jumpUrl[matchStr]['prefix_icon'],
                    height: 19,
                    color: colorScheme.primary,
                  ),
                )
              ],
              TextSpan(
                text: content.jumpUrl[matchStr]['title'],
                style: TextStyle(
                  color: colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final String title = content.jumpUrl[matchStr]['title'];
                    if (appUrlSchema == '') {
                      if (matchStr.startsWith('BV')) {
                        UrlUtils.matchUrlPush(
                          matchStr,
                          title,
                          '',
                        );
                      } else {
                        Uri uri = Uri.parse(matchStr.replaceAll('/?', '?'));
                        SchemeEntity scheme = SchemeEntity(
                          scheme: uri.scheme,
                          host: uri.host,
                          port: uri.port,
                          path: uri.path,
                          query: uri.queryParameters,
                          source: '',
                          dataString: matchStr,
                        );
                        BillSchame.fullPathPush(scheme);
                      }
                    } else {
                      if (appUrlSchema.startsWith('bilibili://search')) {
                        Get.toNamed('/searchResult',
                            parameters: {'keyword': title});
                      } else if (matchStr.startsWith('https://b23.tv')) {
                        final String redirectUrl =
                            await UrlUtils.parseRedirectUrl(matchStr);
                        final String pathSegment = Uri.parse(redirectUrl).path;
                        final String lastPathSegment =
                            pathSegment.split('/').last;
                        if (lastPathSegment.startsWith('BV')) {
                          UrlUtils.matchUrlPush(
                            lastPathSegment,
                            title,
                            redirectUrl,
                          );
                        } else {
                          Get.toNamed(
                            '/webview',
                            parameters: {
                              'url': redirectUrl,
                              'type': 'url',
                              'pageTitle': title
                            },
                          );
                        }
                      } else {
                        Get.toNamed(
                          '/webview',
                          parameters: {
                            'url': matchStr,
                            'type': 'url',
                            'pageTitle': title
                          },
                        );
                      }
                    }
                  },
              )
            ],
          );
          // 只显示一次
          matchedStrs.add(matchStr);
        } else if (content
                .topicsMeta[matchStr.substring(1, matchStr.length - 1)] !=
            null) {
          spanChilds.add(
            TextSpan(
              text: matchStr,
              style: TextStyle(
                color: colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final String topic =
                      matchStr.substring(1, matchStr.length - 1);
                  Get.toNamed('/searchResult', parameters: {'keyword': topic});
                },
            ),
          );
        } else {
          addPlainTextSpan(matchStr);
        }
      }
      return '';
    },
    onNonMatch: (String nonMatchStr) {
      return nonMatchStr.splitMapJoin(
        bv23Regex,
        onMatch: (Match match) {
          String matchStr = match[0]!;
          spanChilds.add(
            TextSpan(
              text: ' $matchStr ',
              style: isVideoPage
                  ? TextStyle(
                      color: colorScheme.primary,
                    )
                  : null,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(
                      '/webview',
                      parameters: {
                        'url': matchStr,
                        'type': 'url',
                        'pageTitle': matchStr
                      },
                    ),
            ),
          );
          return '';
        },
        onNonMatch: (String nonMatchOtherStr) {
          addPlainTextSpan(nonMatchOtherStr);
          return nonMatchOtherStr;
        },
      );
    },
  );

  if (content.jumpUrl.keys.isNotEmpty) {
    List<String> unmatchedItems = content.jumpUrl.keys
        .toList()
        .where((item) => !content.message.contains(item))
        .toList();
    if (unmatchedItems.isNotEmpty) {
      for (int i = 0; i < unmatchedItems.length; i++) {
        String patternStr = unmatchedItems[i];
        spanChilds.addAll(
          [
            if (content.jumpUrl[patternStr]?['prefix_icon'] != null) ...[
              WidgetSpan(
                child: Image.network(
                  content.jumpUrl[patternStr]['prefix_icon'],
                  height: 19,
                  color: colorScheme.primary,
                ),
              )
            ],
            TextSpan(
              text: content.jumpUrl[patternStr]['title'],
              style: TextStyle(
                color: colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(
                    '/webview',
                    parameters: {
                      'url': patternStr,
                      'type': 'url',
                      'pageTitle': content.jumpUrl[patternStr]['title']
                    },
                  );
                },
            )
          ],
        );
      }
    }
  }

  // 图片渲染
  if (content.pictures.isNotEmpty) {
    final List<String> picList = <String>[];
    final int len = content.pictures.length;
    spanChilds.add(const TextSpan(text: '\n'));
    if (len == 1) {
      Map pictureItem = content.pictures.first;
      picList.add(pictureItem['img_src']);
      spanChilds.add(
        WidgetSpan(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              double maxHeight = box.maxWidth * 0.6; // 设置最大高度
              // double width = (box.maxWidth / 2).truncateToDouble();
              double height = 100;
              try {
                height = ((box.maxWidth /
                        2 *
                        pictureItem['img_height'] /
                        pictureItem['img_width']))
                    .truncateToDouble();
              } catch (_) {}

              return GestureDetector(
                onTap: () {
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (BuildContext context) {
                      return ImagePreview(initialPage: 0, imgList: picList);
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 4),
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  width: box.maxWidth / 2,
                  height: height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: NetworkImgLayer(
                          src: pictureItem['img_src'],
                          width: box.maxWidth / 2,
                          height: height,
                        ),
                      ),
                      height > Get.size.height * 0.9
                          ? const PBadge(
                              text: '长图',
                              right: 8,
                              bottom: 8,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (len > 1) {
      List<Widget> list = [];
      for (var i = 0; i < len; i++) {
        picList.add(content.pictures[i]['img_src']);
        list.add(
          LayoutBuilder(
            builder: (context, BoxConstraints box) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (context) {
                      return ImagePreview(initialPage: i, imgList: picList);
                    },
                  );
                },
                child: NetworkImgLayer(
                    src: content.pictures[i]['img_src'],
                    width: box.maxWidth,
                    height: box.maxWidth,
                    origAspectRatio: content.pictures[i]['img_width'] /
                        content.pictures[i]['img_height']),
              );
            },
          ),
        );
      }
      spanChilds.add(
        WidgetSpan(
          child: LayoutBuilder(
            builder: (context, BoxConstraints box) {
              double maxWidth = box.maxWidth;
              double crossCount = len < 3 ? 2 : 3;
              double height = maxWidth /
                      crossCount *
                      (len % crossCount == 0
                          ? len ~/ crossCount
                          : len ~/ crossCount + 1) +
                  6;
              return Container(
                padding: const EdgeInsets.only(top: 6),
                height: height,
                child: GridView.count(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossCount.toInt(),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  childAspectRatio: 1,
                  children: list,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  // 笔记链接
  if (content.richText.isNotEmpty) {
    spanChilds.add(
      TextSpan(
        text: ' 笔记',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => Get.toNamed(
                '/webview',
                parameters: {
                  'url': content.richText['note']['click_url'],
                  'type': 'note',
                  'pageTitle': '笔记预览'
                },
              ),
      ),
    );
  }

  return TextSpan(children: spanChilds);
}

class MorePanel extends StatelessWidget {
  final dynamic item;
  const MorePanel({super.key, required this.item});

  Future<dynamic> menuActionHandler(String type) async {
    String message = item.content.message ?? item.content;
    switch (type) {
      case 'copyAll':
        await Clipboard.setData(ClipboardData(text: message));
        SmartDialog.showToast('已复制');
        Get.back();
        break;
      case 'copyFreedom':
        Get.back();
        showDialog(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text('自由复制'),
              content: SelectableText(message),
            );
          },
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
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
                      color: colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                ),
              ),
            ),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('copyAll'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_all_outlined, size: 19),
            title: Text('复制全部', style: textTheme.titleSmall),
          ),
          ListTile(
            onTap: () async => await menuActionHandler('copyFreedom'),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_outlined, size: 19),
            title: Text('自由复制', style: textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
