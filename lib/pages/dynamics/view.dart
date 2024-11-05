import 'package:bilibili/common/skeleton/dynamic_card.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/dynamics/result.dart';
import 'package:bilibili/pages/dynamics/controller.dart';
import 'package:bilibili/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:bilibili/pages/dynamics/widgets/up_panel.dart';
import 'package:bilibili/pages/mine/controller.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:bilibili/utils/main_stream.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class DynamicsPage extends StatefulWidget {
  const DynamicsPage({super.key});

  @override
  State<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends State<DynamicsPage>
    with AutomaticKeepAliveClientMixin {
  final DynamicsController _dynamicsController = Get.put(DynamicsController());
  final MineController mineController = Get.put(MineController());
  late Future _futureBuilderFuture;
  late Future _futureBuilderFutureUp;

  Box userInfoCache = GStrorage.userInfo;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _dynamicsController.queryFollowDynamic();
    _futureBuilderFutureUp = _dynamicsController.queryFollowUp();
    scrollController = _dynamicsController.scrollController;
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        EasyThrottle.throttle('queryFollowDynamic', const Duration(seconds: 1),
            () {
          _dynamicsController.queryFollowDynamic(type: 'onLoad');
        });
      }
      handleScrollEvent(scrollController);
    });

    _dynamicsController.userLogin.listen((status) {
      if (mounted) {
        _futureBuilderFuture = _dynamicsController.queryFollowDynamic();
        _futureBuilderFutureUp = _dynamicsController.queryFollowUp();
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        TextStyle(fontSize: Theme.of(context).textTheme.labelMedium!.fontSize);
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: SizedBox(
          height: 34,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    if (_dynamicsController.mid.value != -1 &&
                        _dynamicsController.upInfo.value.uname != null) {
                      return SizedBox(
                        height: 36,
                        child: AnimatedSwitcher(
                          duration: const Duration(microseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Text(
                              '${_dynamicsController.upInfo.value.uname!}的动态',
                              key: ValueKey<String>(
                                  _dynamicsController.upInfo.value.uname!),
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontSize,
                              )),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                  Obx(() => _dynamicsController.userLogin.value
                      ? Visibility(
                          visible: _dynamicsController.mid.value == -1,
                          child: Theme(
                            data: ThemeData(
                              splashColor: Colors.transparent, // 点击时的水波纹颜色设置为透明
                              highlightColor:
                                  Colors.transparent, // 点击时的背景高亮颜色设置为透明
                            ),
                            child: CustomSlidingSegmentedControl(
                              initialValue:
                                  _dynamicsController.initialValue.value,
                              children: {
                                0: Text('全部', style: textStyle),
                                1: Text('投稿', style: textStyle),
                                2: Text('番剧', style: textStyle),
                                3: Text('专栏', style: textStyle),
                              },
                              padding: 13.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              thumbDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              onValueChanged: (v) {
                                feedBack();
                                _dynamicsController.onSelectType(v);
                              },
                            ),
                          ))
                      : Text('动态',
                          style: Theme.of(context).textTheme.titleMedium)),
                ],
              )
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _dynamicsController.onRefresh();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            if (_dynamicsController.userLogin.value) ...[
              FutureBuilder(
                future: _futureBuilderFutureUp,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return const SliverToBoxAdapter(child: SizedBox());
                    }
                    Map data = snapshot.data;
                    if (data['status']) {
                      return Obx(
                          () => UpPanel(_dynamicsController.upData.value));
                    }
                    return HttpError(
                        errMsg: data['msg'],
                        fn: () {
                          setState(() {
                            _futureBuilderFutureUp =
                                _dynamicsController.queryFollowUp();
                          });
                        });
                  }
                  return const SliverToBoxAdapter(
                      child: SizedBox(
                    height: 90,
                    child: UpPanelSkeleton(),
                  ));
                },
              ),
            ],
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  Map data = snapshot.data;
                  if (data['status']) {
                    List<DynamicItemModel> list =
                        _dynamicsController.dynamicsList;
                    return Obx(() {
                      if (list.isEmpty) {
                        if (_dynamicsController.isLoadingDynamic.value) {
                          return skeleton();
                        }
                        return const NoData();
                      }
                      return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        return DynamicPanel(item: list[index]);
                      }, childCount: list.length));
                    });
                  }
                  return HttpError(
                    errMsg: data['msg'],
                    btnText: data['code'] == -101 ? '去登录' : null,
                    fn: () {
                      if (data['code'] == -101) {
                        RoutePush.loginRedirectPush();
                      } else {
                        setState(() {
                          _futureBuilderFuture =
                              _dynamicsController.queryFollowDynamic();
                          _futureBuilderFutureUp =
                              _dynamicsController.queryFollowUp();
                        });
                      }
                    },
                  );
                }
                // 骨架屏
                return skeleton();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget skeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return const DynamicCardSkeleton();
      }, childCount: 5),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
