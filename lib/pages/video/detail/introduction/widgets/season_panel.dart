import 'package:bilibili/common/pages_bottom_sheet.dart';
import 'package:bilibili/models/common/video_episode_type.dart';
import 'package:bilibili/models/video_detail_res.dart';
import 'package:bilibili/pages/video/detail/controller.dart';
import 'package:bilibili/pages/video/detail/introduction/controller.dart';
import 'package:bilibili/utils/id_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeasonPanel extends StatefulWidget {
  final UgcSeason ugcSeason;
  final int? cid;
  final double? sheetHeight;
  final Function? changeFuc;
  final VideoIntroController videoIntroCtr;
  const SeasonPanel(
      {super.key,
      required this.ugcSeason,
      this.cid,
      this.sheetHeight,
      this.changeFuc,
      required this.videoIntroCtr});

  @override
  State<SeasonPanel> createState() => _SeasonPanelState();
}

class _SeasonPanelState extends State<SeasonPanel> {
  late List<EpisodeItem> episodes;
  late int cid;
  late RxInt currentIndex = (-1).obs;
  final String heroTag = Get.arguments['heroTag'];
  late VideoDetailController _videoDetailController;
  late PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    cid = widget.cid!;
    _videoDetailController = Get.find<VideoDetailController>(tag: heroTag);

    /// 根据 cid 找到对应集，找到对应 episodes
    /// 有多个episodes时，只显示其中一个
    /// TODO 同时显示多个合集
    final List<SectionItem> sections = widget.ugcSeason.sections!;
    for (int i = 0; i < sections.length; i++) {
      final List<EpisodeItem> episodesList = sections[i].episodes!;
      for (int j = 0; j < episodesList.length; j++) {
        if (episodesList[j].cid == cid) {
          episodes = episodesList;
          continue;
        }
      }
    }

    /// 取对应 season_id 的 episodes
    currentIndex.value = episodes.indexWhere((EpisodeItem e) => e.cid == cid);
    _videoDetailController.cid.listen((int p0) {
      cid = p0;
      currentIndex.value = episodes.indexWhere((EpisodeItem e) => e.cid == cid);
    });
  }

  void changeFucCall(item, int i) async {
    widget.changeFuc?.call(
      IdUtils.av2bv(item.aid),
      item.cid,
      item.aid,
      item.cover,
    );
    currentIndex.value = i;
    _bottomSheetController?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        left: 2,
        right: 2,
        bottom: 2,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            widget.videoIntroCtr.bottomSheetController =
                _bottomSheetController = EpisodeBottomSheet(
              currentCid: cid,
              episodes: episodes,
              changeFucCall: changeFucCall,
              sheetHeight: widget.sheetHeight,
              dataType: VideoEpidoesType.videoEpisode,
              context: context,
            ).show(context);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '合集：${widget.ugcSeason.title!}',
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 15),
                Image.asset(
                  'assets/images/live.gif',
                  color: Theme.of(context).colorScheme.primary,
                  height: 12,
                ),
                const SizedBox(width: 10),
                Obx(() => Text(
                      '${currentIndex.value + 1}/${episodes.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                    )),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 13,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
