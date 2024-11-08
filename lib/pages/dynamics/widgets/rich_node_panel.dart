import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/http/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';


InlineSpan richNode(item, context) {
  final spacer = _VerticalSpaceSpan(0.0);
  try {
    TextStyle authorStyle =
        TextStyle(color: Theme.of(context).colorScheme.primary);
    List<InlineSpan> spanChilds = [];

    dynamic richTextNodes;
    if (item.modules.moduleDynamic.desc != null) {
      richTextNodes = item.modules.moduleDynamic.desc.richTextNodes;
    } else if (item.modules.moduleDynamic.major != null) {
      // 动态页面 richTextNodes 层级可能与主页动态层级不同
      richTextNodes =
          item.modules.moduleDynamic.major.opus.summary.richTextNodes;
      if (item.modules.moduleDynamic.major.opus.title != null) {
        spanChilds.add(
          TextSpan(
            text: item.modules.moduleDynamic.major.opus.title + '\n',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    if (richTextNodes == null || richTextNodes.isEmpty) {
      return spacer;
    } else {
      for (var i in richTextNodes) {
        /// fix 渲染专栏时内容会重复
        // if (item.modules.moduleDynamic.major.opus.title == null &&
        //     i.type == 'RICH_TEXT_NODE_TYPE_TEXT') {
        if (i.type == 'RICH_TEXT_NODE_TYPE_TEXT') {
          spanChilds.add(
              TextSpan(text: i.origText, style: const TextStyle(height: 1.65)));
        }
        // @用户
        if (i.type == 'RICH_TEXT_NODE_TYPE_AT') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/member?mid=${i.rid}',
                        arguments: {'face': null, 'uname': null}),
                    child: Text(
                      ' ${i.text}',
                      style: authorStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 话题
        if (i.type == 'RICH_TEXT_NODE_TYPE_TOPIC') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.origText}',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 网页链接
        if (i.type == 'RICH_TEXT_NODE_TYPE_WEB') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.link,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/webview',
                    parameters: {
                      'url': i.origText,
                      'type': 'url',
                      'pageTitle': ''
                    },
                  );
                },
                child: Text(
                  i.text,
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 投票
        if (i.type == 'RICH_TEXT_NODE_TYPE_VOTE') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  try {
                    String dynamicId = item.basic['comment_id_str'];
                    Get.toNamed(
                      '/webview',
                      parameters: {
                        'url':
                            'https://t.bilibili.com/vote/h5/index/#/result?vote_id=${i.rid}&dynamic_id=$dynamicId&isWeb=1',
                        'type': 'vote',
                        'pageTitle': '投票'
                      },
                    );
                  } catch (_) {}
                },
                child: Text(
                  '投票：${i.text}',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 表情
        if (i.type == 'RICH_TEXT_NODE_TYPE_EMOJI') {
          spanChilds.add(
            WidgetSpan(
              child: NetworkImgLayer(
                src: i.emoji.iconUrl,
                type: 'emote',
                width: i.emoji.size * 20,
                height: i.emoji.size * 20,
              ),
            ),
          );
        }
        // 抽奖
        if (i.type == 'RICH_TEXT_NODE_TYPE_LOTTERY') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.redeem_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.origText} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        /// TODO 商品
        if (i.type == 'RICH_TEXT_NODE_TYPE_GOODS') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  '${i.text} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
        // 投稿
        if (i.type == 'RICH_TEXT_NODE_TYPE_BV') {
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          spanChilds.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () async {
                  try {
                    int cid = await SearchHttp.ab2c(bvid: i.rid);
                    Get.toNamed('/video?bvid=${i.rid}&cid=$cid',
                        arguments: {'pic': null, 'heroTag': i.rid});
                  } catch (err) {
                    SmartDialog.showToast(err.toString());
                  }
                },
                child: Text(
                  '${i.text} ',
                  style: authorStyle,
                ),
              ),
            ),
          );
        }
      }
    }
    return TextSpan(
      children: spanChilds,
    );
  } catch (err) {
    print('❌rich_node_panel err: $err');
    return spacer;
  }
}


class _VerticalSpaceSpan extends WidgetSpan {
  _VerticalSpaceSpan(double height)
      : super(child: SizedBox(height: height, width: double.infinity));
}