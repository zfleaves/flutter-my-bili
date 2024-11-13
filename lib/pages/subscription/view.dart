import 'package:bilibili/common/skeleton/video_card_h.dart';
import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/pages/subscription/controller.dart';
import 'package:bilibili/pages/subscription/widgets/item.dart';
import 'package:bilibili/utils/route_push.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubPage extends StatefulWidget {
  const SubPage({super.key});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  final SubController _subController = Get.put(SubController());
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _subController.querySubFolder();
    scrollController = _subController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('history', const Duration(seconds: 1), () {
            _subController.onLoad();
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
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '我的订阅',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map? data = snapshot.data;
            if (data != null && data['status']) {
              if (_subController.subFolderData.value.list!.isNotEmpty) {
                return Obx(() => ListView.builder(
                      controller: scrollController,
                      itemCount:
                          _subController.subFolderData.value.list!.length,
                      itemBuilder: (context, index) {
                        return SubItem(
                            subFolderItem:
                                _subController.subFolderData.value.list![index],
                            cancelSub: _subController.cancelSub);
                      },
                    ));
              }
              return const CustomScrollView(
                physics: NeverScrollableScrollPhysics(),
                slivers: [HttpError(errMsg: '', btnText: '没有数据', fn: null)],
              );
            }
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                HttpError(
                  errMsg: data?['msg'] ?? '请求异常',
                  btnText: data?['code'] == -101 ? '去登录' : null,
                  fn: () {
                    if (data?['code'] == -101) {
                      RoutePush.loginRedirectPush();
                    } else {
                      setState(() {
                        _futureBuilderFuture = _subController.querySubFolder();
                      });
                    }
                  },
                ),
              ],
            );
          }
          // 骨架屏
          return ListView.builder(
            itemBuilder: (context, index) {
              return const VideoCardHSkeleton();
            },
            itemCount: 10,
          );
        },
      ),
    );
  }
}
