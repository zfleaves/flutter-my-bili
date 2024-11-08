import 'package:bilibili/pages/follow/controller.dart';
import 'package:bilibili/pages/follow/widgets/follow_list.dart';
import 'package:bilibili/pages/follow/widgets/owner_follow_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late String mid;
  late FollowController _followController;
  final ScrollController scrollController = ScrollController();
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    mid = Get.parameters['mid']!;
    _followController = Get.put(FollowController(), tag: mid);
    _futureBuilderFuture = _followController.followUpTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          _followController.isOwner.value
              ? '我的关注'
              : '${_followController.name}的关注',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/followSearch?mid=$mid'),
            icon: const Icon(Icons.search_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () => Get.toNamed('/blackListPage'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 19),
                    SizedBox(width: 10),
                    Text('黑名单管理'),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      body: Obx(
        () => !_followController.isOwner.value
          ? FollowList(ctr: _followController)
          : FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data;
                if (data['status']) {
                  return Column(
                    children: [
                      TabBar(
                        controller: _followController.tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          for (var i in data['data']) ...[
                            Tab(text: i.name),
                          ]
                        ]),
                      Expanded(
                        child: TabBarView(
                          controller: _followController.tabController,
                          children: [
                            for (var i = 0; i < _followController.tabController.length; i++) ...[
                              OwnerFollowList(
                                ctr: _followController,
                                tagItem: _followController.followTags[i],
                              )
                            ]
                          ]
                        ),
                      )
                    ],
                  );
                }
                return const SizedBox();
              }
              return const SizedBox();
            },
          ),
      ),
    );
  }
}