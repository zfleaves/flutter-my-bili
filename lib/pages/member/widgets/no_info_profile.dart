import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/live/item.dart';
import 'package:bilibili/models/member/info.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class NoInfoProfilePanel extends StatelessWidget {
  final dynamic ctr;
  final bool loadingStatus;
  const NoInfoProfilePanel({super.key, this.ctr, this.loadingStatus = false,});

  @override
  Widget build(BuildContext context) {
    MemberInfoModel memberInfo = ctr.memberInfo.value;
    return Builder(
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).padding.top - 20),
          child: Row(
            children: [
              Hero(
                  tag: ctr.heroTag!,
                  child: Stack(
                    children: [
                      NetworkImgLayer(
                        width: 90,
                        height: 90,
                        type: 'avatar',
                        src: ctr.face.value,
                      ),
                    ],
                  )),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/follow?mid=${ctr.mid}&name=${ctr.uname.value}');
                          },
                          child: Column(
                            children: [
                              Text(
                                !loadingStatus
                                    ? ctr.userStat!['following'].toString()
                                    : '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '关注',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                '/fan?mid=${ctr.mid}&name=${ctr.uname.value}');
                          },
                          child: Column(
                            children: [
                              Text(
                                  !loadingStatus
                                      ? ctr.userStat!['follower'] != null
                                          ? Utils.numFormat(
                                              ctr.userStat!['follower'],
                                            )
                                          : '-'
                                      : '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '粉丝',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .fontSize),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                                !loadingStatus
                                    ? ctr.userStat!['likes'] != null
                                        ? Utils.numFormat(
                                            ctr.userStat!['likes'],
                                          )
                                        : '-'
                                    : '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                              '获赞',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .fontSize),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (ctr.ownerMid != ctr.mid && ctr.ownerMid != -1) ...[
                    Row(
                      children: [
                        Obx(() => Expanded(
                              child: TextButton(
                                onPressed: () => loadingStatus
                                    ? null
                                    : ctr.actionRelationMod(),
                                style: TextButton.styleFrom(
                                  foregroundColor: ctr.attribute.value == -1
                                      ? Colors.transparent
                                      : ctr.attribute.value != 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .outline
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                  backgroundColor: ctr.attribute.value != 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface
                                      : Theme.of(context)
                                          .colorScheme
                                          .primary, // 设置按钮背景色
                                ),
                                child: Obx(() => Text(ctr.attributeText.value)),
                              ),
                            )),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(
                                '/whisperDetail',
                                parameters: {
                                  'name': ctr.uname.value!,
                                  'face': ctr.face.value!,
                                  'mid': ctr.mid.toString(),
                                  'heroTag': ctr.heroTag!,
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                            child: const Text('发消息'),
                          ),
                        )
                      ],
                    )
                  ],
                  if (ctr.ownerMid == ctr.mid && ctr.ownerMid != -1) ...[
                    TextButton(
                      onPressed: () {
                        SmartDialog.showToast('功能开发中 💪');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 80, right: 80),
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('编辑资料'),
                    )
                  ],
                  if (ctr.ownerMid == -1) ...[
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 80, right: 80),
                        foregroundColor: Theme.of(context).colorScheme.outline,
                        backgroundColor:
                            Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      child: const Text('未登录'),
                    )
                  ]
                ],
              ))
            ],
          ),
        );
      },
    );
  }
}
