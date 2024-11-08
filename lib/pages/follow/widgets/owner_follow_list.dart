import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/http/member.dart';
import 'package:bilibili/models/follow/result.dart';
import 'package:bilibili/models/member/tags.dart';
import 'package:bilibili/pages/follow/controller.dart';
import 'package:bilibili/pages/follow/widgets/follow_item.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerFollowList extends StatefulWidget {
  final FollowController ctr;
  final MemberTagItemModel? tagItem;
  const OwnerFollowList({super.key, required this.ctr, this.tagItem});

  @override
  State<OwnerFollowList> createState() => _OwnerFollowListState();
}

class _OwnerFollowListState extends State<OwnerFollowList> with AutomaticKeepAliveClientMixin {
  late int mid;
  late Future _futureBuilderFuture;
  final ScrollController scrollController = ScrollController();
  int pn = 1;
  int ps = 20;
  late MemberTagItemModel tagItem;
  RxList<FollowItemModel> followList = <FollowItemModel>[].obs;

  @override
  void initState() {
    super.initState();
    mid = widget.ctr.mid;
    tagItem = widget.tagItem!;
    _futureBuilderFuture = followUpGroup('init');
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            followUpGroup('onLoad');
          });
        }
      },
    );
  }

  // 获取分组下up
  Future followUpGroup(type) async {
    if (type == 'init') {
      pn = 1;
    }
    var res = await MemberHttp.followUpGroup(mid, tagItem.tagid, pn, ps);
    if (res['status']) {
      if (res['data'].isNotEmpty) {
        if (type == 'init') {
          followList.value = res['data'];
        } else {
          followList.addAll(res['data']);
        }
        pn += 1;
      }
    }
    return res;
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async => await followUpGroup('init'),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data;
            if (data['status']) {
              double bottom = MediaQuery.of(context).padding.bottom;
              return Obx(
                () => followList.isNotEmpty
                  ? ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    itemCount: followList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == followList.length) {
                        return Container(
                          height: bottom + 60,
                          padding: EdgeInsets.only(bottom: bottom),
                        );
                      }
                      return FollowItem(
                        item: followList[index],
                        ctr: widget.ctr,
                      );
                    }
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
  
  @override
  bool get wantKeepAlive => true;
}