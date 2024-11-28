import 'package:bilibili/pages/tv_search/controller.dart';
import 'package:bilibili/pages/tv_search/tv_search_panel/index.dart';
import 'package:bilibili/pages/tv_search/tv_search_panel/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TvSearchPage extends StatefulWidget {
  const TvSearchPage({super.key});

  @override
  State<TvSearchPage> createState() => _TvSearchPageState();
}

class _TvSearchPageState extends State<TvSearchPage>
    with TickerProviderStateMixin {
  final TvSearchController _tvSearchController = Get.put(TvSearchController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '全部内容',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: Align(
              alignment: Alignment.center,
              child: TabBar(
                controller: _tvSearchController.tabController,
                tabs: _tvSearchController.typeList
                    .map((item) => Text(item.label))
                    .toList(),
                isScrollable: true,
                indicatorColor: const Color.fromRGBO(239, 104, 150, 1),
                labelColor: const Color.fromRGBO(244, 107, 155, 1),
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 13),
                dividerColor: const Color.fromRGBO(239, 239, 239, 1),
                tabAlignment: TabAlignment.start,
                labelPadding:
                    const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                indicatorPadding: const EdgeInsets.only(bottom: 5),
                onTap: (index) {
                  if (index == _tvSearchController.initialIndex.value) {
                    Get.find<TvSearchPanelController>(
                            tag: _tvSearchController.typeList[index].key)
                        .animateToTop();
                  }
                  _tvSearchController.initialIndex.value = index;
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: _tvSearchController.tabController,
              children: _tvSearchController.typeList
                  .map((item) => TvSearchPanelPage(
                        tvSearchModel: item,
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
