import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/skeleton.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/pages/whisper/controller.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../common/widgets/network_img_layer.dart';

class WhisperPage extends StatefulWidget {
  const WhisperPage({super.key});

  @override
  State<WhisperPage> createState() => _WhisperPageState();
}

class _WhisperPageState extends State<WhisperPage> {
  final WhisperController _whisperController = Get.put(WhisperController());
  late Future _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _whisperController.querySessionList('init');
    _scrollController.addListener(_scrollListener);
  }

  Future _scrollListener() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle('my-throttler', const Duration(milliseconds: 800),
          () async {
        await _whisperController.onLoad();
        _whisperController.isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '消息',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _whisperController.unread();
          await _whisperController.onRefresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // 在这里根据父级容器的约束条件构建小部件树
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                      height: constraints.maxWidth / 4,
                      child: Obx(() => GridView.count(
                            primary: false,
                            crossAxisCount: 4,
                            padding: const EdgeInsets.all(0),
                            children: [
                              ..._whisperController.noticesList.map((element) {
                                return InkWell(
                                  onTap: () {
                                    if (['/messageAt', '/messageSystem']
                                        .contains(element['path'])) {
                                      SmartDialog.showToast('功能开发中');
                                      return;
                                    }
                                    Get.toNamed(element['path']);
                                    if (element['count'] > 0) {
                                      element['count'] = 0;
                                    }
                                    _whisperController.noticesList.refresh();
                                  },
                                  borderRadius: StyleString.mdRadius,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Badge(
                                        isLabelVisible: element['count'] > 0,
                                        label: Text(element['count'] > 99
                                            ? '99+'
                                            : element['count'].toString()),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                            element['icon'],
                                            size: 21,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(element['title'])
                                    ],
                                  ),
                                );
                              }).toList()
                            ],
                          )),
                    ),
                  );
                },
              ),
              FutureBuilder(
                  future: _futureBuilderFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map? data = snapshot.data;
                      if (data != null && data['status']) {
                        return Obx(
                            () => _whisperController.sessionList.isNotEmpty
                                ? ListView.separated(
                                    itemCount:
                                        _whisperController.sessionList.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return SessionItem(
                                        sessionItem: _whisperController.sessionList[index],
                                        changeFucCall: () => _whisperController.sessionList.refresh(),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        indent: 72,
                                        endIndent: 20,
                                        height: 6,
                                        color: Colors.grey.withOpacity(0.1),
                                      );
                                    },
                                  )
                                : const SizedBox());
                      }
                      return const SizedBox();
                    }
                    return const WhisperSkeleton();
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class SessionItem extends StatelessWidget {
  final dynamic sessionItem;
  final Function changeFucCall;
  const SessionItem(
      {super.key, required this.sessionItem, required this.changeFucCall});

  @override
  Widget build(BuildContext context) {
    final heroTag = Utils.makeHeroTag(sessionItem.accountInfo.mid);
    final content = sessionItem.lastMsg.content;
    final msgStatus = sessionItem.lastMsg.msgStatus;
    return ListTile(
      onTap: () {
        sessionItem.unreadCount = 0;
        changeFucCall.call();
        Get.toNamed(
          '/whisperDetail',
          parameters: {
            'talkerId': sessionItem.talkerId.toString(),
            'name': sessionItem.accountInfo.name,
            'face': sessionItem.accountInfo.face,
            'mid': sessionItem.accountInfo.mid.toString(),
            'heroTag': heroTag,
          },
        );
      },
      leading: Badge(
        isLabelVisible: sessionItem.unreadCount > 0,
        label: Text(sessionItem.unreadCount.toString()),
        alignment: Alignment.topRight,
        child: Hero(
          tag: heroTag,
          child: NetworkImgLayer(
            width: 45,
            height: 45,
            type: 'avatar',
            src: sessionItem.accountInfo.face,
          ),
        ),
      ),
      title: Text(sessionItem.accountInfo.name),
      subtitle: Text(
          msgStatus == 1
              ? '你撤回了一条消息'
              : getSubContent(content != null && content != ''
                  ? (content['text'] ??
                      content['content'] ??
                      content['title'] ??
                      content['reply_content'] ??
                      '不支持的消息类型')
                  : '不支持的消息类型'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Theme.of(context).colorScheme.outline)),
      trailing: Text(
        Utils.dateFormat(sessionItem.lastMsg.timestamp),
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  String getSubContent(String content) {
    if (content.startsWith('\n')) {  
      return content.substring(1); // 去除第一个字符，这里是换行符  
    }
    return content;
  }
}

// 骨架屏
class WhisperSkeleton extends StatelessWidget {
  const WhisperSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, int i) {
        return Skeleton(
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            title: Container(
              width: 100,
              height: 14,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            subtitle: Container(
              width: 80,
              height: 14,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        );
      },
    );
  }
}
