import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/pages/member_search/controller.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key});

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage>
    with SingleTickerProviderStateMixin {
  final MemberSearchController _memberSearchCtr =
      Get.put(MemberSearchController());
  late ScrollController scrollController;
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _memberSearchCtr.searchArchives();
    scrollController = _memberSearchCtr.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('history', const Duration(seconds: 1), () {
            _memberSearchCtr.onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [
          IconButton(
              onPressed: () => _memberSearchCtr.submit(),
              icon: const Icon(CupertinoIcons.search, size: 22)),
          const SizedBox(width: 10)
        ],
        title: Obx(() => TextField(
              autofocus: true,
              focusNode: _memberSearchCtr.searchFocusNode,
              controller: _memberSearchCtr.controller.value,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _memberSearchCtr.onChange(value),
              decoration: InputDecoration(
                hintText: _memberSearchCtr.hintText,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 22,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () => _memberSearchCtr.onClear(),
                ),
              ),
              onSubmitted: (String value) => _memberSearchCtr.submit(),
            )),
      ),
      body: Obx(
        () => Column(
          children: _memberSearchCtr.loadingStatus.value == 'init'
              ? [
                  Expanded(
                    child: Center(
                      child: Text('搜索「${_memberSearchCtr.uname.value}」的动态、视频'),
                    ),
                  ),
                ]
              : [
                  Expanded(
                    child: FutureBuilder(
                      future: _memberSearchCtr.searchArchives(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map data = snapshot.data as Map;
                          if (data['status']) {
                            return Obx(
                              () => _memberSearchCtr.archiveList.isNotEmpty
                                  ? ListView.builder(
                                      controller: scrollController,
                                      itemCount:
                                          _memberSearchCtr.archiveList.length +
                                              1,
                                      itemBuilder: (context, index) {
                                        if (index ==
                                            _memberSearchCtr
                                                .archiveList.length) {
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .padding
                                                    .bottom +
                                                60,
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .padding
                                                    .bottom),
                                            child: Center(
                                              child: Obx(
                                                () => Text(
                                                  _memberSearchCtr
                                                      .loadingText.value,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return VideoCardH(
                                              videoItem: _memberSearchCtr
                                                  .archiveList[index]);
                                        }
                                      },
                                    )
                                  : _memberSearchCtr.loadingStatus.value ==
                                          'loading'
                                      ? ListView.builder(
                                          itemCount: 10,
                                          itemBuilder: (context, index) {
                                            return const VideoCardHSkeleton();
                                          },
                                        )
                                      : const CustomScrollView(
                                          slivers: <Widget>[
                                            NoData(),
                                          ],
                                        ),
                            );
                          } else {
                            return CustomScrollView(
                              slivers: <Widget>[
                                HttpError(
                                  errMsg: data['msg'],
                                  fn: () => setState(() {}),
                                )
                              ],
                            );
                          }
                        } else {
                          // 骨架屏
                          return ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return const VideoCardHSkeleton();
                            },
                          );
                        }
                      },
                    ),
                    //   ],
                    // ),
                  ),
                ],
        ),
      ),
    );
  }
}
