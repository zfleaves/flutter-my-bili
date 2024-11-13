import 'dart:async';
import 'dart:developer';

import 'package:bilibili/common/skeleton/video_reply.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/models/common/reply_type.dart';
import 'package:bilibili/models/dynamics/result.dart';
import 'package:bilibili/models/video/reply/item.dart';
import 'package:bilibili/pages/dynamics/detail/controller.dart';
import 'package:bilibili/pages/dynamics/widgets/author_panel.dart';
import 'package:bilibili/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:bilibili/pages/video/detail/reply_new/view.dart';
import 'package:bilibili/pages/video/detail/reply_reply/view.dart';
import 'package:bilibili/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/id_utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class DynamicDetailPage extends StatefulWidget {
  const DynamicDetailPage({super.key});

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends State<DynamicDetailPage>
    with TickerProviderStateMixin {
  late DynamicDetailController _dynamicDetailController;
  late AnimationController fabAnimationCtr;
  Future? _futureBuilderFuture;
  late StreamController<bool> titleStreamC; // appBar title
  late ScrollController scrollController;
  bool _visibleTitle = false;
  String? action;
  // 回复类型
  late int replyType;
  bool _isFabVisible = true;
  int oid = 0;
  int? opusId;
  bool isOpusId = false;

  @override
  void initState() {
    super.initState();
    // floor 1原创 2转发
    init();
    titleStreamC = StreamController<bool>();
    if (action == 'comment') {
      _visibleTitle = true;
      titleStreamC.add(true);
    }
    fabAnimationCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabAnimationCtr.forward();
    // 滚动事件监听
    scrollListener();
  }

  // 页面初始化
  void init() async {
    Map args = Get.arguments;
    // 楼层
    int floor = args['floor'];
    // 从action栏点击进入
    action = args.containsKey('action') ? args['action'] : null;
    // 评论类型
    int commentType = args['item'].basic!['comment_type'] ?? 11;
    replyType = (commentType == 0) ? 11 : commentType;

    if (floor == 1) {
      oid = int.parse(args['item'].basic!['comment_id_str']);
    } else {
      try {
        ModuleDynamicModel moduleDynamic = args['item'].modules.moduleDynamic;
        String majorType = moduleDynamic.major!.type!;
        if (majorType == 'MAJOR_TYPE_OPUS') {
          // 转发的动态
          String jumpUrl = moduleDynamic.major!.opus!.jumpUrl!;
          opusId = int.parse(jumpUrl.split('/').last);
          if (opusId != null) {
            isOpusId = true;
            _dynamicDetailController = Get.put(
                DynamicDetailController(oid, replyType),
                tag: opusId.toString());
            await _dynamicDetailController.reqHtmlByOpusId(opusId!);
            setState(() {});
          }
        } else {
          oid = moduleDynamic.major!.draw!.id!;
        }
      } catch (_) {}
    }
    if (!isOpusId) {
      _dynamicDetailController =
          Get.put(DynamicDetailController(oid, replyType), tag: oid.toString());
    }
    _futureBuilderFuture = _dynamicDetailController.queryReplyList();
  }

  // 查看二级评论
  void replyReply(replyItem) {
    int oid = replyItem.oid;
    int rpid = replyItem.rpid!;
    Get.to(
      () => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Text(
            '评论详情',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: VideoReplyReplyPanel(
          oid: oid,
          rpid: rpid,
          source: 'dynamic',
          replyType: ReplyType.values[replyType],
          firstFloor: replyItem,
        ),
      ),
    );
  }

  // 滑动事件监听
  void scrollListener() {
    scrollController = _dynamicDetailController.scrollController;
    scrollController.addListener(
      () {
        // 分页加载
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('replylist', const Duration(seconds: 2), () {
            _dynamicDetailController.queryReplyList(reqType: 'onLoad');
          });
        }

        // 标题
        if (scrollController.offset > 55 && !_visibleTitle) {
          _visibleTitle = true;
          titleStreamC.add(true);
        } else if (scrollController.offset <= 55 && _visibleTitle) {
          _visibleTitle = false;
          titleStreamC.add(false);
        }

        // fab按钮
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          _showFab();
        } else if (direction == ScrollDirection.reverse) {
          _hideFab();
        }
      },
    );
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      fabAnimationCtr.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      fabAnimationCtr.reverse();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    fabAnimationCtr.dispose();
    scrollController.dispose();
    titleStreamC.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleSpacing: 0,
        title: StreamBuilder(
          stream: titleStreamC.stream,
          initialData: false,
          builder: (context, AsyncSnapshot snapshot) {
            return AnimatedOpacity(
              opacity: snapshot.data ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AuthorPanel(item: _dynamicDetailController.item),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _dynamicDetailController.queryReplyList(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            if (action != 'comment') ...[
              SliverToBoxAdapter(
                child: DynamicPanel(
                  item: _dynamicDetailController.item,
                  source: 'detail',
                ),
              ),
            ],
            SliverPersistentHeader(
              delegate: _MySliverPersistentHeaderDelegate(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        width: 0.6,
                        color: Theme.of(context).dividerColor.withOpacity(0.05),
                      ),
                    ),
                  ),
                  height: 45,
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Row(
                    children: [
                      Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                            '${_dynamicDetailController.acount.value}',
                            key: ValueKey<int>(
                                _dynamicDetailController.acount.value),
                          ),
                        ),
                      ),
                      const Text('条回复'),
                      const Spacer(),
                      SizedBox(
                        height: 35,
                        child: TextButton.icon(
                          onPressed: () =>
                              _dynamicDetailController.queryBySort(),
                          icon: const Icon(Icons.sort, size: 16),
                          label: Obx(() => Text(
                                _dynamicDetailController.sortTypeLabel.value,
                                style: const TextStyle(fontSize: 13),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map data = snapshot.data as Map;
                  if (snapshot.data['status']) {
                    RxList<ReplyItemModel> replyList =
                        _dynamicDetailController.replyList;
                    return Obx(() => replyList.isEmpty &&
                            _dynamicDetailController.isLoadingMore
                        ? SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return const VideoReplySkeleton();
                            }, childCount: 8),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == replyList.length) {
                                return Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .padding
                                          .bottom),
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          100,
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        _dynamicDetailController.noMore.value,
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
                              }
                              return ReplyItem(
                                replyItem: replyList[index],
                                showReplyRow: true,
                                replyLevel: '1',
                                replyReply: (replyItem) =>
                                    replyReply(replyItem),
                                replyType: ReplyType.values[replyType],
                                addReply: (replyItem) {
                                  replyList[index].replies!.add(replyItem);
                                },
                              );
                            },
                            childCount: replyList.length + 1,
                          )));
                  }
                  // 请求错误
                  return HttpError(
                    errMsg: data['msg'],
                    fn: () => setState(() {}),
                  );
                }
                // 骨架屏
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return const VideoReplySkeleton();
                  }, childCount: 8),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: fabAnimationCtr,
            curve: Curves.easeInOut,
          ),
        ),
        child: Obx(() => _dynamicDetailController.replyReqCode.value == 12061
            ? const SizedBox()
            : FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  feedBack();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return VideoReplyNewDialog(
                        oid: _dynamicDetailController.oid ??
                            IdUtils.bv2av(Get.parameters['bvid']!),
                        root: 0,
                        parent: 0,
                        replyType: ReplyType.values[replyType],
                      );
                    },
                  ).then(
                    (value) {
                      // 完成评论，数据添加
                      if (value != null && value['data'] != null) {
                        _dynamicDetailController.replyList.insert(0, value['data']);
                        // _dynamicDetailController.replyList.add(value['data']);
                        _dynamicDetailController.acount.value++;
                        print(_dynamicDetailController.acount.value);
                      }
                    },
                  );
                },
                tooltip: '评论动态',
                child: const Icon(Icons.reply),
              )),
      ),
    );
  }
}

// SliverPersistentHeaderDelegate 用于创建一个持久的头部（header），这个头部可以随着滚动事件动态地改变其大小，但始终保持在视图中
class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent = 45;
  final double _maxExtent = 45;
  final Widget child;

  _MySliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    //shrinkOffset：child偏移值minExtent~maxExtent
    //overlapsContent：SliverPersistentHeader覆盖其他子组件返回true，否则返回false
    return child;
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
