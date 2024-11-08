import 'package:bilibili/common/widgets/http_error.dart';
import 'package:bilibili/common/widgets/no_data.dart';
import 'package:bilibili/models/fans/result.dart';
import 'package:bilibili/pages/fan/controller.dart';
import 'package:bilibili/pages/fan/widgets/fan_item.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FansPage extends StatefulWidget {
  const FansPage({super.key});

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  late String mid;
  late FansController _fansController;
  Future? _futureBuilderFuture;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mid = Get.parameters['mid']!;
    // tag: mid：这是一个命名参数，tag用于给放入容器的对象指定一个唯一的标识符
    _fansController = Get.put(FansController(), tag: mid);
    _futureBuilderFuture = _fansController.queryFans('init');
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('follow', const Duration(seconds: 1), () {
            _fansController.queryFans('onLoad');
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
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _fansController.isOwner.value ? '我的粉丝' : '${_fansController.name}的粉丝',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _fansController.queryFans('init'),
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              if (data['status']) {
                List<FansItemModel> list = _fansController.fansList;
                double bottom = MediaQuery.of(context).padding.bottom;
                return Obx(
                  () => list.isNotEmpty
                      ? ListView.builder(
                          controller: scrollController,
                          itemCount: list.length + 1,
                          itemBuilder: (context, index) {
                            if (index == list.length) {
                              return Container(
                                height: bottom,
                                padding: EdgeInsets.only(bottom: bottom + 60),
                                child: Center(
                                  child: Obx(
                                    () => Text(
                                      _fansController.loadingText.value,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return fanItem(item: list[index]);
                          },
                        )
                      : const CustomScrollView(
                          slivers: [NoData()],
                        ),
                );
              }
              return CustomScrollView(
                slivers: [
                  HttpError(
                    errMsg: data['msg'],
                    fn: () => _fansController.queryFans('init'),
                  )
                ],
              );
            }
            // 骨架屏
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
