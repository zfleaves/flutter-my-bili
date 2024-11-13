import 'package:bilibili/common/skeleton/video_reply.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/models/common/reply_type.dart';
import 'package:bilibili/models/video/reply/item.dart';
import 'package:bilibili/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'controller.dart';

class VideoReplyReplyPanel extends StatefulWidget {
  const VideoReplyReplyPanel({
    this.oid,
    this.rpid,
    this.closePanel,
    this.firstFloor,
    this.source,
    this.replyType,
    this.sheetHeight,
    super.key,
  });
  final int? oid;
  final int? rpid;
  final Function? closePanel;
  final ReplyItemModel? firstFloor;
  final String? source;
  final ReplyType? replyType;
  final double? sheetHeight;

  @override
  State<VideoReplyReplyPanel> createState() => _VideoReplyReplyPanelState();
}

class _VideoReplyReplyPanelState extends State<VideoReplyReplyPanel> {
  late VideoReplyReplyController _videoReplyReplyController;
  late AnimationController replyAnimationCtl;
  final Box<dynamic> localCache = GStrorage.localCache;
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    _videoReplyReplyController = Get.put(
        VideoReplyReplyController(
            widget.oid, widget.rpid.toString(), widget.replyType!),
        tag: widget.rpid.toString());
    super.initState();

    // 上拉加载更多
    scrollController = _videoReplyReplyController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(milliseconds: 200),
              () {
            _videoReplyReplyController.queryReplyList(type: 'onLoad');
          });
        }
      },
    );

    _futureBuilderFuture = _videoReplyReplyController.queryReplyList();
  }

  void replyReply(replyItem) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.source == 'videoDetail' ? widget.sheetHeight : null,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (widget.source == 'videoDetail') ...[
            AppBar(
              toolbarHeight: 45,
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Text(
                '评论详情',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _videoReplyReplyController.currentPage = 0;
                    widget.closePanel?.call;
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 14),
              ],
            ),
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                _videoReplyReplyController.currentPage = 0;
                return await _videoReplyReplyController.queryReplyList();
              },
              child: CustomScrollView(
                controller: _videoReplyReplyController.scrollController,
                slivers: [
                  if (widget.firstFloor != null) ...[
                    SliverToBoxAdapter(
                      child: ReplyItem(
                        replyItem: widget.firstFloor,
                        replyLevel: '2',
                        showReplyRow: false,
                        addReply: (replyItem) {
                          _videoReplyReplyController.replyList.add(replyItem);
                        },
                        replyType: widget.replyType,
                        replyReply: (replyItem) => replyReply(replyItem),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Divider(
                        height: 20,
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        thickness: 6,
                      ),
                    ),
                  ],
                  FutureBuilder(
                    future: _futureBuilderFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map? data = snapshot.data;
                        if (data != null && data['status']) {
                          return Obx(
                            () => SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  if (index ==
                                      _videoReplyReplyController
                                          .replyList.length) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom),
                                      height: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          100,
                                      child: Center(
                                        child: Obx(
                                          () => Text(
                                            _videoReplyReplyController
                                                .noMore.value,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ReplyItem(
                                      replyItem: _videoReplyReplyController
                                          .replyList[index],
                                      replyLevel: '2',
                                      showReplyRow: false,
                                      addReply: (replyItem) {
                                        _videoReplyReplyController.replyList
                                            .add(replyItem);
                                      },
                                      replyType: widget.replyType,
                                      replyReply: (replyItem) =>
                                          replyReply(replyItem),
                                    );
                                  }
                                },
                                childCount: _videoReplyReplyController
                                        .replyList.length +
                                    1,
                              ),
                            ),
                          );
                        }
                        // 请求错误
                        return HttpError(
                          errMsg: data?['msg'] ?? '请求错误',
                          fn: () => setState(() {}),
                        );
                      }
                      // 骨架屏
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return const VideoReplySkeleton();
                        }, childCount: 8),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
