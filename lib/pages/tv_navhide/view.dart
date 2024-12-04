import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/bottom_seat.dart';
import 'package:bilibili/common/widgets/custom_button.dart';
import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/models/tv/tv_navhide.dart';
import 'package:bilibili/pages/tv_navhide/controller.dart';
import 'package:bilibili/pages/tv_navhide/widgets/more_detail.dart';
import 'package:bilibili/pages/tv_navhide/widgets/tv_navhide_card.dart';
import 'package:bilibili/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class TvNavhidePage extends StatefulWidget {
  const TvNavhidePage({super.key});

  @override
  State<TvNavhidePage> createState() => _TvNavhidePageState();
}

class _TvNavhidePageState extends State<TvNavhidePage> {
  final TvNavhideController _tvNavhideController =
      Get.put(TvNavhideController());
  late Future _futureBuilder;
  int firstNum = 15; // 首次展示数目

  @override
  void initState() {
    super.initState();
    _futureBuilder = _tvNavhideController.queryTvNavhideList();
  }

  // 查看更多
  showMoreBottomSheet(context) {
    showBottomSheet(
      context: context,
      enableDrag: true,
      backgroundColor: const Color(0x80000000),
      builder: (BuildContext context) {
        return MoreDetail(
          child: Obx(() => contentGrid(_tvNavhideController,
              _tvNavhideController.navhideList.sublist(firstNum))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? titleLarge = Theme.of(context).textTheme.titleLarge;
    TextStyle? labelLarge = Theme.of(context).textTheme.labelLarge;
    // TextStyle? labelLarge = Theme.of(context).textTheme.;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            _tvNavhideController.appBarTitle.value,
            style: TextStyle(
                fontSize: titleLarge?.fontSize,
                fontWeight: titleLarge?.fontWeight,
                color: Colors.white),
          ),
          actions: [
            InkWell(
              onTap: () {
                Share.share(
                    'https://www.bilibili.com/bangumi/list/sl61060?navhide=1&from_spmid=666.8.subject.0');
              },
              child: const Icon(Icons.share_outlined, size: 19),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _tvNavhideController.queryTvNavhideList();
          },
          child: FutureBuilder(
            future: _futureBuilder,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const SizedBox();
                }
                Map data = snapshot.data as Map;
                if (data['status']) {
                  UpInfo upInfo = _tvNavhideController.upInfo.value;
                  print(upInfo);
                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 10),
                      ),
                      if (upInfo.mid != null) ...[
                        SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed('/member?mid=${upInfo.mid}',
                                        arguments: {
                                          'face': upInfo.avatar,
                                          'heroTag': Utils.makeHeroTag(upInfo.mid),
                                          'uname': upInfo.uname
                                        });
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 14,
                                      ),
                                      Hero(
                                        tag: Utils.makeHeroTag(upInfo.mid),
                                        child: NetworkImgLayer(
                                          width: 30,
                                          height: 30,
                                          type: 'avatar',
                                          src: upInfo.avatar,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        upInfo.uname!,
                                        style: TextStyle(
                                          fontSize: labelLarge?.fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text('发起',
                                          style: TextStyle(
                                            fontSize: labelLarge?.fontSize,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 30,
                                  child: Obx(() => TextButton(
                                        onPressed: () => _tvNavhideController
                                            .actionRelationMod(),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 0, 15, 0),
                                          foregroundColor: _tvNavhideController
                                                      .isFollowed.value ==
                                                  1
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                          backgroundColor: _tvNavhideController
                                                      .isFollowed.value ==
                                                  1
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onInverseSurface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary, // 设置按钮背景色
                                        ),
                                        child: Text(_tvNavhideController
                                            .followedMsg.value),
                                      )))
                            ],
                          ),
                        ),
                      ],
                      SliverToBoxAdapter(
                        child: Container(
                          height: 220,
                          margin: const EdgeInsets.only(top: 16, bottom: 6),
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  // image: AssetImage('assets/images/tv/navhide_top_bg.png'),
                                  image: AssetImage(
                                      'assets/images/tv/navhide_top_bg.jpeg'),
                                  fit: BoxFit.cover)),
                          // child: Image.asset('assets/images/tv/navhide_top_bg.png', fit: BoxFit.cover,),
                          // child: Image.asset('assets/images/tv/navhide_bg.svg', fit: BoxFit.cover,),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 70, bottom: 10),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: _tvNavhideController.title.value,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: titleLarge?.fontWeight,
                                        color: Colors.white),
                                  ),
                                  // const TextSpan(text: '       '),
                                  // TextSpan(
                                  //   text: _tvNavhideController.total.value,
                                  //   style: TextStyle(
                                  //       fontSize: labelLarge?.fontSize,
                                  //       fontWeight: labelLarge?.fontWeight,
                                  //       color: Colors.white38),
                                  // ),
                                ])),
                              ),
                              Text(
                                _tvNavhideController.summary.value,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: labelLarge?.fontWeight,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        sliver: Obx(() {
                          final int len = _tvNavhideController.navhideList.length > firstNum ? firstNum : _tvNavhideController.navhideList.length;
                          print(len);
                          return contentGrid(
                            _tvNavhideController,
                            _tvNavhideController.navhideList.sublist(0, len)
                          );
                        }),
                      ),
                      if (_tvNavhideController.navhideList.length > firstNum) ...[
                        SliverToBoxAdapter(
                          child: CustomButton(
                            text: '查看更多',
                            color: const Color.fromRGBO(12, 177, 241, 1),
                            cb: () {
                              showMoreBottomSheet(context);
                            },
                          ),
                        ),
                      ],
                      SliverToBoxAdapter(
                        child: Visibility(
                          visible: _tvNavhideController.id == '61060',
                          child: Container(
                            height: 26,
                            margin: const EdgeInsets.only(top: 36, bottom: 26),
                            child: Image.asset(
                                'assets/images/tv/navhide_bottom_bg.png'),
                          ),
                        ),
                      ),
                      const BottomSeat(),
                    ],
                  );
                }
                return const SizedBox();
              }
              return const SizedBox();
            },
          ),
        ));
  }

  Widget contentGrid(ctr, navhideList) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 行间距
        mainAxisSpacing: StyleString.cardSpace,
        // 列间距
        crossAxisSpacing: StyleString.cardSpace,
        // 列数
        crossAxisCount: 3,
        mainAxisExtent: Get.size.width / 3 / 0.65 +
            MediaQuery.textScalerOf(context).scale(32.0),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return navhideList!.isNotEmpty
              ? TvNavhideCardH(tVItem: navhideList[index], ctr: ctr)
              : const SizedBox();
        },
        childCount: navhideList!.isNotEmpty ? navhideList!.length : 10,
      ),
    );
  }
}
