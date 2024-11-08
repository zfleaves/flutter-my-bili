import 'package:bilibili/models/video/reply/emote.dart';
import 'package:bilibili/pages/emote/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmotePanel extends StatefulWidget {
  final Function onChoose;
  const EmotePanel({super.key, required this.onChoose});

  @override
  State<EmotePanel> createState() => _EmotePanelState();
}

class _EmotePanelState extends State<EmotePanel>
    with AutomaticKeepAliveClientMixin {
  final EmotePanelController _emotePanelController =
      Get.put(EmotePanelController());
  late Future _futureBuilderFuture;

  @override
  void initState() {
    _futureBuilderFuture = _emotePanelController.getEmote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map data = snapshot.data as Map;
          if (data['status']) {
            List<PackageItem> emotePackage = _emotePanelController.emotePackage;
            return Column(
              children: [
                Expanded(
                    child: TabBarView(
                  controller: _emotePanelController.tabController,
                  children: emotePackage.map((e) {
                    int size = e.emote!.first.meta!.size!;
                    int type = e.type!;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: size == 1 ? 40 : 60,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: e.emote!.length,
                          itemBuilder: (context, index) {
                            return Material(
                              color: Colors.transparent,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: InkWell(
                                onTap: () {
                                  widget.onChoose(e, e.emote![index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: type == 4
                                      ? Text(
                                          e.emote![index].text!,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                        )
                                      : Image.network(
                                          e.emote![index].url!,
                                          width: size * 38,
                                          height: size * 38,
                                        ),
                                ),
                              ),
                            );
                          }),
                    );
                  }).toList(),
                ))
              ],
            );
          }
          return Center(child: Text(data['msg']));
        }
        return const Center(child: Text('加载中...'));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
