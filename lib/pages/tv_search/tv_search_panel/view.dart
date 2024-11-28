import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/models/tv/tv_search_type.dart';
import 'package:bilibili/pages/tv_search/tv_search_panel/index.dart';
import 'package:bilibili/pages/tv_search/tv_search_panel/widgets/tv_search_card_h.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvSearchPanelPage extends StatefulWidget {
  final TvSearchModel tvSearchModel;
  const TvSearchPanelPage({super.key, required this.tvSearchModel});

  @override
  State<TvSearchPanelPage> createState() => _TvSearchPanelPageState();
}

class _TvSearchPanelPageState extends State<TvSearchPanelPage>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;
  late TvSearchPanelController _tvPanelController;
  late Future _futureBuilderFuture;
  late TvSearchModel tvSearchModel;
  final GlobalKey _elementKey = GlobalKey();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    tvSearchModel = widget.tvSearchModel;
    _tvPanelController = Get.put(TvSearchPanelController(st: tvSearchModel.st),
        tag: tvSearchModel.key);
    scrollController = _tvPanelController.scrollController;
    scrollController.addListener(() async {
      EasyThrottle.throttle('tvSearchPanel-visibilty', const Duration(seconds: 1), () {
        _checkIfElementIsVisible();
      });
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        EasyThrottle.throttle('tvSearchPanel', const Duration(seconds: 1), () {
          _tvPanelController.queryTvSearchList(type: 'onLoad');
        });
      }
    });
    _tvPanelController.initParams(tvSearchModel);
    _futureBuilderFuture = _tvPanelController.queryTvSearchList();
  }

  void _checkIfElementIsVisible() {
    final RenderBox? elementBox = _elementKey.currentContext?.findRenderObject() as RenderBox?;
    if (elementBox == null) {
      setState(() {
        _isVisible = false;
      });
      return;
    }
 
    final elementPosition = elementBox.localToGlobal(Offset.zero);
    final viewportOffset = scrollController.offset;
    final viewportSize = MediaQuery.of(context).size;
 
    // Calculate the bounds of the element in the viewport coordinates
    final elementTop = elementPosition.dy - viewportOffset;
    final elementBottom = elementTop + elementBox.size.height;
    const viewportTop = 0.0;
    final viewportBottom = viewportSize.height;
 
    // Check if the element is completely outside the viewport
    final isVisible = !(elementBottom <= viewportTop || elementTop >= viewportBottom);
    setState(() {
      _isVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        await _tvPanelController.onRefresh();
      },
      child: CustomScrollView(
        controller: _tvPanelController.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              key: _elementKey,
              children: [
                Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: ListView.builder(
                      itemCount: tvSearchModel.orderList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        OrderItem item = tvSearchModel.orderList[index];
                        return Obx(() => Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: CustomChip(
                                  onTap: () {
                                    _tvPanelController.order.value = item.order;
                                    _tvPanelController.sort.value = item.sort;
                                    // _tvPanelController.queryTvSearchList(type: 'onRefresh');
                                  },
                                  label: item.label,
                                  selected: item.order ==
                                          _tvPanelController.order.value &&
                                      item.sort ==
                                          _tvPanelController.sort.value),
                            ));
                      },
                    )),
                if (tvSearchModel.areaList != null) ...[
                  Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: ListView.builder(
                        itemCount: tvSearchModel.areaList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          AreaItem item = tvSearchModel.areaList![index];
                          return Obx(() => Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: CustomChip(
                                    onTap: () {
                                      _tvPanelController.area.value = item.area;
                                      _tvPanelController.queryTvSearchList(
                                          type: 'onRefresh');
                                    },
                                    label: item.label,
                                    selected: _tvPanelController.area.value ==
                                        item.area),
                              ));
                        },
                      )),
                ],
                Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: ListView.builder(
                      itemCount: tvSearchModel.styleList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        StyleItem item = tvSearchModel.styleList[index];
                        return Obx(() => Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: CustomChip(
                                  onTap: () {
                                    _tvPanelController.styleId.value =
                                        item.styleId;
                                    _tvPanelController.queryTvSearchList(
                                        type: 'onRefresh');
                                  },
                                  label: item.label,
                                  selected: _tvPanelController.styleId.value ==
                                      item.styleId),
                            ));
                      },
                    )),
                if (tvSearchModel.productList != null) ...[
                  Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: ListView.builder(
                        itemCount: tvSearchModel.productList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          ProducedItem item = tvSearchModel.productList![index];
                          return Obx(() => Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: CustomChip(
                                    onTap: () {
                                      _tvPanelController.producerId.value =
                                          item.producerId;
                                      _tvPanelController.queryTvSearchList(
                                          type: 'onRefresh');
                                    },
                                    label: item.label,
                                    selected:
                                        _tvPanelController.producerId.value ==
                                            item.producerId),
                              ));
                        },
                      )),
                ],
                if (tvSearchModel.yearList != null) ...[
                  Container(
                      height: 40,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: ListView.builder(
                        itemCount: tvSearchModel.yearList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          YearListItem item = tvSearchModel.yearList![index];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: CustomChip(
                                onTap: () {
                                  setState(() {
                                    _tvPanelController.releaseDate =
                                        item.releaseDate;
                                  });
                                  _tvPanelController.queryTvSearchList(
                                      type: 'onRefresh');
                                },
                                label: item.label,
                                selected: _tvPanelController.releaseDate ==
                                    item.releaseDate),
                          );
                        },
                      )),
                ],
                Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: ListView.builder(
                      itemCount: tvSearchModel.payTypeList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        PayTypeItem item = tvSearchModel.payTypeList[index];
                        return Obx(() => Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: CustomChip(
                                  onTap: () {
                                    _tvPanelController.seasonStatus.value =
                                        item.seasonStatus;
                                    _tvPanelController.queryTvSearchList(
                                        type: 'onRefresh');
                                  },
                                  label: item.label,
                                  selected:
                                      _tvPanelController.seasonStatus.value ==
                                          item.seasonStatus),
                            ));
                      },
                    )),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
                top: StyleString.safeSpace, bottom: 10, left: 16, right: 16),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return Obx(() {
                      return contentGrid(
                          _tvPanelController, _tvPanelController.list);
                    });
                  }
                  return HttpError(
                    errMsg: data['msg'],
                    fn: () {
                      _futureBuilderFuture =
                          _tvPanelController.queryTvSearchList();
                    },
                  );
                }
                return contentGrid(_tvPanelController, []);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
            ),
          ),
        ],
      ),
    );
  }

  Widget contentGrid(ctr, tvList) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 行间距
        mainAxisSpacing: StyleString.cardSpace - 2,
        // 列间距
        crossAxisSpacing: StyleString.cardSpace,
        // 列数
        crossAxisCount: 3,
        mainAxisExtent: Get.size.width / 3 / 0.65 +
            MediaQuery.textScalerOf(context).scale(32.0),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return tvList!.isNotEmpty
              ? TvSearchCardH(tVItem: tvList[index])
              : const SizedBox();
        },
        childCount: tvList!.isNotEmpty ? tvList!.length : 10,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomChip extends StatelessWidget {
  final Function onTap;
  final String label;
  final bool selected;
  const CustomChip(
      {super.key,
      required this.onTap,
      required this.label,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    Color secondaryContainer = Colors.white;
    Color onPrimary = const Color.fromRGBO(240, 103, 150, 1);
    final TextStyle chipTextStyle = selected
        ? TextStyle(fontSize: 16, color: onPrimary)
        : TextStyle(fontSize: 16, color: colorTheme.onSecondaryContainer);
    const VisualDensity visualDensity =
        VisualDensity(horizontal: -4.0, vertical: -2.0);
    return InputChip(
      side: BorderSide.none,
      backgroundColor: selected ? Colors.red : secondaryContainer,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected) ||
            states.contains(WidgetState.hovered)) {
          return const Color.fromRGBO(255, 235, 242, 1);
        }
        return Colors.transparent;
      }),
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
      label: Text(label, style: chipTextStyle),
      onPressed: () => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      selected: selected,
      showCheckmark: false,
      visualDensity: visualDensity,
    );
  }
}
