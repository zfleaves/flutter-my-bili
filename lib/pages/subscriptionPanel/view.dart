import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/common/sub_type.dart';
import 'package:bilibili/pages/subscriptionPanel/index.dart';
import 'package:bilibili/pages/subscriptionPanel/widgets/item.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SubPanel extends StatefulWidget {
  final SubType? subType;
  final int? mid;
  const SubPanel({super.key, this.subType, this.mid});

  @override
  State<SubPanel> createState() => _SubPanelState();
}

class _SubPanelState extends State<SubPanel>
    with AutomaticKeepAliveClientMixin {
  late SubPanelController _subPanelController;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _subPanelController = Get.put(
      SubPanelController(subType: widget.subType, mid: widget.mid),
      tag: widget.subType!.id,
    );
    scrollController = _subPanelController.scrollController;
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        EasyThrottle.throttle('subPanel', const Duration(seconds: 1), () {
          _subPanelController.onSearch(type: 'onLoad');
        });
      }
    });
    _futureBuilderFuture = _subPanelController.onSearch();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        onRefresh: () async {
          await _subPanelController.onRefresh();
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 36,
              padding: const EdgeInsets.only(left: 8, top: 0, right: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() => Wrap(
                            children: [
                              for (var i
                                  in _subPanelController.subFilterTabs) ...[
                                CustomFilterChip(
                                  label: i['label'],
                                  id: i['id'],
                                  followStatus: i['followStatus'],
                                  selectedType:
                                      _subPanelController.selectedType.value,
                                  callFn: (bool selected) async {
                                    _subPanelController.selectedType.value =
                                        i['followStatus'];
                                    SmartDialog.showLoading(msg: 'loading');
                                    _subPanelController.animateToTop();
                                    await _subPanelController.onRefresh();
                                    SmartDialog.dismiss();
                                  },
                                ),
                              ]
                            ],
                          )),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  FutureBuilder(
                    future: _futureBuilderFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null) {
                          return const SliverToBoxAdapter(child: SizedBox());
                        }
                        Map data = snapshot.data;
                        if (data['status']) {
                          return Obx(
                            () => _subPanelController.resultList.isNotEmpty
                                ? SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      return SubPanelItem(
                                          videoItem: _subPanelController
                                              .resultList[index],
                                          ctr: _subPanelController,
                                          subType: widget.subType!);
                                    },
                                        childCount: _subPanelController
                                            .resultList.length),
                                  )
                                : const NoData(),
                          );
                        }
                        return HttpError(
                          errMsg: data['msg'] ?? '请求异常',
                          btnText: data['code'] == -101 ? '去登录' : null,
                          fn: () {
                            if (data['code'] == -101) {
                              RoutePush.loginRedirectPush();
                            } else {
                              setState(() {
                                _futureBuilderFuture =
                                    _subPanelController.onSearch();
                              });
                            }
                          },
                        );
                      }
                      // 骨架屏
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const VideoCardHSkeleton();
                        }, childCount: 10),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).padding.bottom,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomFilterChip extends StatelessWidget {
  final String? label;
  final String? id;
  final int? followStatus;
  final int? selectedType;
  final Function? callFn;
  const CustomFilterChip(
      {super.key,
      this.label,
      this.followStatus,
      this.selectedType,
      this.callFn,
      this.id});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: FilterChip(
        padding: const EdgeInsets.only(left: 11, right: 11),
        labelPadding: EdgeInsets.zero,
        label: Text(
          label!,
          style: const TextStyle(fontSize: 13),
        ),
        labelStyle: TextStyle(
            color: followStatus == selectedType
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline),
        selected: followStatus == selectedType,
        showCheckmark: false,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedColor: Colors.transparent,
        // backgroundColor:
        //     Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        side: BorderSide.none,
        onSelected: (bool selected) => callFn!(selected),
      ),
    );
  }
}
