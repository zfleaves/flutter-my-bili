import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/models/common/search_type.dart';
import 'package:bilibili/pages/search/widgets/search_text.dart';
import 'package:bilibili/pages/search_panel/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class SearchVideoPanel extends StatelessWidget {
  final SearchPanelController? ctr;
  final List? list;
  SearchVideoPanel({super.key, this.ctr, this.list});

  final VideoPanelController controller = Get.put(VideoPanelController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36),
          child: list!.isNotEmpty
              ? ListView.builder(
                  controller: ctr!.scrollController,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemCount: list!.length,
                  itemBuilder: (context, index) {
                    var i = list![index];
                    return Padding(
                      padding: index == 0
                          ? const EdgeInsets.only(top: 2)
                          : EdgeInsets.zero,
                      child: VideoCardH(
                        videoItem: i,
                        showPubdate: true,
                        source: 'search',
                      ),
                    );
                  },
                )
              : CustomScrollView(
                  slivers: [
                    HttpError(
                      errMsg: '没有数据',
                      isShowBtn: false,
                      fn: () => {},
                    )
                  ],
                ),
        ),
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
                          for (var i in controller.filterList) ...[
                            CustomFilterChip(
                              label: i['label'],
                              type: i['type'],
                              selectedType: controller.selectedType.value,
                              callFn: (bool selected) async {
                                controller.selectedType.value = i['type'];
                                ctr!.order.value =
                                    i['type'].toString().split('.').last;
                                SmartDialog.showLoading(msg: 'loading');
                                await ctr!.onRefresh();
                                SmartDialog.dismiss();
                              },
                            ),
                          ]
                        ],
                      )),
                ),
              ),
              const VerticalDivider(indent: 7, endIndent: 8),
              const SizedBox(width: 3),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () => controller.onShowFilterSheet(ctr),
                  icon: Icon(
                    Icons.filter_list_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  final String? label;
  final ArchiveFilterType? type;
  final ArchiveFilterType? selectedType;
  final Function? callFn;
  const CustomFilterChip(
      {super.key, this.label, this.type, this.selectedType, this.callFn});

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
            color: type == selectedType
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline),
        selected: type == selectedType,
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

class VideoPanelController extends GetxController {
  RxList<Map> filterList = [{}].obs;
  Rx<ArchiveFilterType> selectedType = ArchiveFilterType.values.first.obs;
  List<Map<String, dynamic>> timeFiltersList = [
    {'label': '全部时长', 'value': 0},
    {'label': '0-10分钟', 'value': 1},
    {'label': '10-30分钟', 'value': 2},
    {'label': '30-60分钟', 'value': 3},
    {'label': '60分钟+', 'value': 4},
  ];

  List<Map<String, dynamic>> partFiltersList = [
    {'label': '全部', 'value': -1},
    {'label': '动画', 'value': 1},
    {'label': '番剧', 'value': 13},
    {'label': '国创', 'value': 167},
    {'label': '音乐', 'value': 3},
    {'label': '舞蹈', 'value': 129},
    {'label': '游戏', 'value': 4},
    {'label': '知识', 'value': 36},
    {'label': '科技', 'value': 188},
    {'label': '运动', 'value': 234},
    {'label': '汽车', 'value': 223},
    {'label': '生活', 'value': 160},
    {'label': '美食', 'value': 211},
    {'label': '动物', 'value': 217},
    {'label': '鬼畜', 'value': 119},
    {'label': '时尚', 'value': 155},
    {'label': '资讯', 'value': 202},
    {'label': '娱乐', 'value': 5},
    {'label': '影视', 'value': 181},
    {'label': '记录', 'value': 177},
    {'label': '电影', 'value': 23},
    {'label': '电视', 'value': 11},
  ];

  RxInt currentTimeFilterval = 0.obs;
  RxInt currentPartFilterval = (-1).obs;

  @override
  void onInit() {
    List<Map<String, dynamic>> list = ArchiveFilterType.values
        .map((type) => {
              'label': type.description,
              'type': type,
            })
        .toList();
    filterList.value = list;
    super.onInit();
  }

  onShowFilterDialog(searchPanelCtr) {
    SmartDialog.show(
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;
        return AlertDialog(
          title: const Text('时长筛选'),
          contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 20),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i in timeFiltersList) ...[
                  RadioListTile(
                    value: i['value'],
                    autofocus: true,
                    title: Text(i['label'], style: textStyle),
                    groupValue: currentTimeFilterval.value,
                    onChanged: (value) async {
                      currentTimeFilterval.value = value!;
                      setState(() {});
                      SmartDialog.dismiss();
                      SmartDialog.showToast("「${i['label']}」的筛选结果");
                      SearchPanelController ctr =
                          Get.find<SearchPanelController>(
                              tag: 'video${searchPanelCtr.keyword!}');
                      ctr.duration.value = i['value'];
                      SmartDialog.showLoading(msg: 'loading');
                      await ctr.onRefresh();
                      SmartDialog.dismiss();
                    },
                  ),
                ],
              ],
            );
          }),
        );
      },
    );
  }

  onShowFilterSheet(searchPanelCtr) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Container(
              color: Theme.of(Get.context!).colorScheme.surface,
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text('内容时长'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      bottom: 14,
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      direction: Axis.horizontal,
                      textDirection: TextDirection.ltr,
                      children: [
                        for (var i in timeFiltersList)
                          Obx(
                            () => SearchText(
                              searchText: i['label'],
                              searchTextIdx: i['value'],
                              isSelect:
                                  currentTimeFilterval.value == i['value'],
                              onSelect: (value) async {
                                currentTimeFilterval.value = i['value'];
                                setState(() {});
                                SmartDialog.showToast("「${i['label']}」的筛选结果");
                                SearchPanelController ctr =
                                    Get.find<SearchPanelController>(
                                        tag: 'video${searchPanelCtr.keyword!}');
                                ctr.duration.value = i['value'];
                                Get.back();
                                SmartDialog.showLoading(msg: '获取中');
                                await ctr.onRefresh();
                                SmartDialog.dismiss();
                              },
                              onLongSelect: (value) => {},
                            ),
                          )
                      ],
                    ),
                  ),
                  const ListTile(
                    title: Text('内容分区'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      direction: Axis.horizontal,
                      textDirection: TextDirection.ltr,
                      children: [
                        for (var i in partFiltersList)
                          SearchText(
                            searchText: i['label'],
                            searchTextIdx: i['value'],
                            isSelect: currentPartFilterval.value == i['value'],
                            onSelect: (value) async {
                              currentPartFilterval.value = i['value'];
                              setState(() {});
                              SmartDialog.showToast("「${i['label']}」的筛选结果");
                              SearchPanelController ctr =
                                  Get.find<SearchPanelController>(
                                      tag: 'video${searchPanelCtr.keyword!}');
                              ctr.tids.value = i['value'];
                              Get.back();
                              SmartDialog.showLoading(msg: '获取中');
                              await ctr.onRefresh();
                              SmartDialog.dismiss();
                            },
                            onLongSelect: (value) => {},
                          )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
