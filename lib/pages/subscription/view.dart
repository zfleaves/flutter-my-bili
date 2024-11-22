import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/models/common/sub_type.dart';
import 'package:bilibili/pages/subscription/controller.dart';
import 'package:bilibili/pages/subscription/widgets/item.dart';
import 'package:bilibili/pages/subscriptionPanel/index.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubPage extends StatefulWidget {
  const SubPage({super.key});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> with TickerProviderStateMixin {
  final SubController _subController = Get.put(SubController());
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: SubType.values.length,
      initialIndex: _subController.tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '我的订阅',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent, // 点击时的水波纹颜色设置为透明
                highlightColor: Colors.transparent, // 点击时的背景高亮颜色设置为透明
              ), 
              child: Obx(
               () => TabBar(
                controller: _tabController,
                tabs: [
                  for (var i in _subController.subTabs)
                      Tab(text: "${i['label']}")
                ],
                isScrollable: true,
                indicatorWeight: 0,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                labelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                tabAlignment: TabAlignment.start,
                onTap: (index) {
                  print( _subController.subTabs[index]);
                    // if (index == _searchResultController.tabIndex) {
                    //   Get.find<SearchPanelController>(
                    //           tag: SearchType.values[index].type +
                    //               _searchResultController.keyword!)
                    //       .animateToTop();
                    // }

                    // _searchResultController.tabIndex = index;
                },
               ) 
              )
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (var i in SubType.values) ...{
                  SubPanel(
                    subType: i,
                    mid: _subController.userInfo?.mid,
                  )
                }
              ]
            ),
          )
        ],
      ),
      // body: FutureBuilder(
      //   future: _futureBuilderFuture,
      //   builder: (BuildContext context, AsyncSnapshot snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       Map? data = snapshot.data;
      //       if (data != null && data['status']) {
      //         if (_subController.subFolderData.value.list!.isNotEmpty) {
      //           return Obx(() => ListView.builder(
      //                 controller: scrollController,
      //                 itemCount:
      //                     _subController.subFolderData.value.list!.length,
      //                 itemBuilder: (context, index) {
      //                   return SubItem(
      //                       subFolderItem:
      //                           _subController.subFolderData.value.list![index],
      //                       cancelSub: _subController.cancelSub);
      //                 },
      //               ));
      //         }
      //         return const CustomScrollView(
      //           physics: NeverScrollableScrollPhysics(),
      //           slivers: [HttpError(errMsg: '', btnText: '没有数据', fn: null)],
      //         );
      //       }
      //       return CustomScrollView(
      //         physics: const NeverScrollableScrollPhysics(),
      //         slivers: [
      //           HttpError(
      //             errMsg: data?['msg'] ?? '请求异常',
      //             btnText: data?['code'] == -101 ? '去登录' : null,
      //             fn: () {
      //               if (data?['code'] == -101) {
      //                 RoutePush.loginRedirectPush();
      //               } else {
      //                 setState(() {
      //                   _futureBuilderFuture = _subController.querySubFolder();
      //                 });
      //               }
      //             },
      //           ),
      //         ],
      //       );
      //     }
      //     // 骨架屏
      //     return ListView.builder(
      //       itemBuilder: (context, index) {
      //         return const VideoCardHSkeleton();
      //       },
      //       itemCount: 10,
      //     );
      //   },
      // ),
    );
  }
}
