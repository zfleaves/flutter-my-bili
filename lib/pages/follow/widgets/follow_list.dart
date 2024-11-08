import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/follow/result.dart';
import 'package:bilibili/pages/follow/controller.dart';
import 'package:bilibili/pages/follow/widgets/follow_item.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowList extends StatefulWidget {
  final FollowController ctr;
  const FollowList({super.key, required this.ctr});

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  late Future _futureBuilderFuture;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = widget.ctr.queryFollowings('init');
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            widget.ctr.queryFollowings('onLoad');
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await widget.ctr.queryFollowings('init'),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data;
            if (data['status']) {
              List<FollowItemModel> list = widget.ctr.followList;
              double bottom = MediaQuery.of(context).padding.bottom;
              return Obx(
                () => list.isNotEmpty
                  ? ListView.builder(
                    controller: scrollController,
                    itemCount: list.length + 1,
                    itemBuilder: (context, index) {
                      if (index == list.length) {
                        return Container(
                          height: bottom + 60,
                          padding: EdgeInsets.only(bottom: bottom),
                          child: Center(
                            child: Obx(
                              () => Text(
                                widget.ctr.loadingText.value,
                                style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        fontSize: 13),
                              )
                            ),
                          ),
                        );
                      }
                      return FollowItem(
                        item: list[index],
                        ctr: widget.ctr,
                      );
                    },
                  )
                  : const CustomScrollView(slivers: [NoData()]),
              );
            }
            return CustomScrollView(
              slivers: [
                HttpError(
                  errMsg: data['msg'],
                  fn: () => widget.ctr.queryFollowings('init'),
                )
              ],
            );
          }
          // 骨架屏
          return const SizedBox();
        },
      ),
    );
  }
}