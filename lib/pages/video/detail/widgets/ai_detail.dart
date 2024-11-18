import 'package:bilibili/models/video/ai.dart';
import 'package:bilibili/pages/video/detail/controller.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';



Box localCache = GStrorage.localCache;
late double sheetHeight;

class AiDetail extends StatelessWidget {
  final ModelResult? modelResult;
  const AiDetail({super.key, this.modelResult});

  @override
  Widget build(BuildContext context) {
    sheetHeight = localCache.get('sheetHeight');
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(left: 14, right: 14),
      height: sheetHeight,
      child: Column(
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
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SelectableText(
                    modelResult!.summary!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: modelResult!.outline!.length,
                    itemBuilder: (context, index) {
                      final outline = modelResult!.outline![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            outline.title!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: outline.partOutline!.length,
                            itemBuilder: (context, i) {
                              final part = outline.partOutline![i];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      try {
                                        final controller =
                                            Get.find<VideoDetailController>(
                                          tag: Get.arguments['heroTag'],
                                        );
                                        controller.plPlayerController.seekTo(
                                          Duration(
                                            seconds: Utils.duration(
                                              Utils.tampToSeektime(
                                                  part.timestamp!),
                                            ).toInt(),
                                          ),
                                        );
                                      } catch (_) {}
                                    },
                                    child: SelectableText.rich(
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: Utils.tampToSeektime(
                                                part.timestamp!),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const TextSpan(text: ' '),
                                          TextSpan(text: part.content!),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  InlineSpan buildContent(BuildContext context, content) {
    List descV2 = content.descV2;
    // type
    // 1 普通文本
    // 2 @用户
    List<TextSpan> spanChilds = List.generate(descV2.length, (index) {
      final currentDesc = descV2[index];
      switch (currentDesc.type) {
        case 1:
          List<InlineSpan> spanChildren = [];
          RegExp urlRegExp = RegExp(r'https?://\S+\b');
          Iterable<Match> matches = urlRegExp.allMatches(currentDesc.rawText);

          int previousEndIndex = 0;
          for (Match match in matches) {
            if (match.start > previousEndIndex) {
              spanChildren.add(TextSpan(
                  text: currentDesc.rawText
                      .substring(previousEndIndex, match.start)));
            }
            spanChildren.add(
              TextSpan(
                text: match.group(0),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary), // 设置颜色为蓝色
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // 处理点击事件
                    try {
                      Get.toNamed(
                        '/webview',
                        parameters: {
                          'url': match.group(0)!,
                          'type': 'url',
                          'pageTitle': match.group(0)!,
                        },
                      );
                    } catch (err) {
                      SmartDialog.showToast(err.toString());
                    }
                  },
              ),
            );
            previousEndIndex = match.end;
          }

          if (previousEndIndex < currentDesc.rawText.length) {
            spanChildren.add(TextSpan(
                text: currentDesc.rawText.substring(previousEndIndex)));
          }

          TextSpan result = TextSpan(children: spanChildren);
          return result;
        case 2:
          final colorSchemePrimary = Theme.of(context).colorScheme.primary;
          final heroTag = Utils.makeHeroTag(currentDesc.bizId);
          return TextSpan(
            text: '@${currentDesc.rawText}',
            style: TextStyle(color: colorSchemePrimary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  '/member?mid=${currentDesc.bizId}',
                  arguments: {'face': '', 'heroTag': heroTag},
                );
              },
          );
        default:
          return const TextSpan();
      }
    });
    return TextSpan(children: spanChilds);
  }
}