import 'package:bilibili/common/constants.dart';
import 'package:bilibili/pages/member_seasons/controller.dart';
import 'package:bilibili/pages/member_seasons/widgets/item.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MemberSeasonsPage extends StatefulWidget {
  const MemberSeasonsPage({super.key});

  @override
  State<MemberSeasonsPage> createState() => _MemberSeasonsPageState();
}

class _MemberSeasonsPageState extends State<MemberSeasonsPage> {
  late MemberSeasonsController _memberSeasonsController;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _memberSeasonsController = Get.put(MemberSeasonsController());
    _futureBuilderFuture =
        _memberSeasonsController.getSeasonDetail('onRefresh');
    scrollController = _memberSeasonsController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'member_archives', const Duration(milliseconds: 500), () {
            _memberSeasonsController.onLoad();
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
        centerTitle: false,
        title: Text('他的专栏', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: StyleString.safeSpace,
          right: StyleString.safeSpace,
        ),
        child: SingleChildScrollView(
          controller: _memberSeasonsController.scrollController,
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  Map data = snapshot.data as Map;
                  List list = _memberSeasonsController.seasonsList;
                  if (data['status']) {
                    return Obx(
                      () => list.isNotEmpty
                        ? LayoutBuilder(builder: (context, constraints) {
                            return GridView.builder(
                              gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: StyleString.safeSpace,
                                mainAxisSpacing: StyleString.safeSpace,
                                childAspectRatio: 0.94,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _memberSeasonsController.seasonsList.length,
                              itemBuilder: (context, i) {
                                return MemberSeasonsItem(
                                  seasonItem: _memberSeasonsController
                                      .seasonsList[i],
                                );
                              },
                            );
                        },)
                        : const SizedBox(),
                    );
                  }
                  return const SizedBox();
                }
                return const SizedBox();
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}