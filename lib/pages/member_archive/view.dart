import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/video_card_h.dart';
import 'package:bilibili/pages/member_archive/controller.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberArchivePage extends StatefulWidget {
  const MemberArchivePage({super.key});

  @override
  State<MemberArchivePage> createState() => _MemberArchivePageState();
}

class _MemberArchivePageState extends State<MemberArchivePage> {
  late MemberArchiveController _memberArchivesController;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    final String heroTag = Utils.makeHeroTag(mid);
    _memberArchivesController =
        Get.put(MemberArchiveController(), tag: heroTag);
    _futureBuilderFuture = _memberArchivesController.getMemberArchive('init');
    scrollController = _memberArchivesController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'member_archives', const Duration(milliseconds: 500), () {
            _memberArchivesController.onLoad();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text('他的投稿', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          Obx(
            () => TextButton.icon(
              icon: const Icon(Icons.sort, size: 20),
              onPressed: _memberArchivesController.toggleSort,
              label: Text(_memberArchivesController.currentOrder['label']!),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        controller: _memberArchivesController.scrollController,
        slivers: [
          FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map data = snapshot.data as Map;
                if (snapshot.data != null && data['status']) {
                  List list = _memberArchivesController.archivesList;
                  return Obx(
                    () => list.isNotEmpty
                        ? SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return VideoCardH(
                                videoItem: list[index],
                                showOwner: false,
                                showPubdate: true,
                                showCharge: true,
                              );
                            }, childCount: list.length),
                          )
                        : const SliverToBoxAdapter(),
                  );
                }
                return HttpError(
                  errMsg: snapshot.data['msg'],
                  fn: () {},
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
        ],
      ),
    );
  }
}
