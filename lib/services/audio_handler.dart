import 'package:audio_service/audio_service.dart';
import 'package:bilibili/models/bangumi/info.dart';
import 'package:bilibili/models/video_detail_res.dart';
import 'package:bilibili/plugin/pl_player/index.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

Future<VideoPlayerServiceHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => VideoPlayerServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.guozhigq.pilipala.audio',
      androidNotificationChannelName: 'Audio Service Pilipala',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(seconds: 10),
      androidNotificationChannelDescription: 'Media notification channel',
      androidNotificationIcon: 'drawable/ic_notification_icon',
    ),
  );
}

class VideoPlayerServiceHandler extends BaseAudioHandler with SeekHandler {
  static final List<MediaItem> _item = [];
  Box setting = GStrorage.setting;
  bool enableBackgroundPlay = false;
  PlPlayerController player = PlPlayerController();

  VideoPlayerServiceHandler() {
    revalidateSetting();
  }

  revalidateSetting() {
    enableBackgroundPlay =
        setting.get(SettingBoxKey.enableBackgroundPlay, defaultValue: false);
  }

  @override
  Future<void> play() async {
    player.play();
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
    await player.seekTo(position);
  }

  Future<void> setMediaItem(MediaItem newMediaItem) async {
    if (!enableBackgroundPlay) return;
    mediaItem.add(newMediaItem);
  }

  Future<void> setPlaybackState(PlayerStatus status, bool isBuffering) async {
    if (!enableBackgroundPlay) return;

    final AudioProcessingState processingState;
    final playing = status == PlayerStatus.playing;
    if (status == PlayerStatus.completed) {
      processingState = AudioProcessingState.completed;
    } else if (isBuffering) {
      processingState = AudioProcessingState.buffering;
    } else {
      processingState = AudioProcessingState.ready;
    }

    playbackState.add(playbackState.value.copyWith(
      processingState:
          isBuffering ? AudioProcessingState.buffering : processingState,
      controls: [
        MediaControl.rewind
            .copyWith(androidIcon: 'drawable/ic_baseline_replay_10_24'),
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward
            .copyWith(androidIcon: 'drawable/ic_baseline_forward_10_24'),
      ],
      playing: playing,
      systemActions: const {
        MediaAction.seek,
      },
    ));
  }

  onStatusChange(PlayerStatus status, bool isBuffering) {
    if (!enableBackgroundPlay) return;

    if (_item.isEmpty) return;
    setPlaybackState(status, isBuffering);
  }

  onVideoDetailChange(dynamic data, int cid) {
    if (!enableBackgroundPlay) return;

    if (data == null) return;
    Map argMap = Get.arguments;
    final heroTag = argMap['heroTag'];

    late MediaItem? mediaItem;
    if (data is VideoDetailData) {
      if ((data.pages?.length ?? 0) > 1) {
        final current = data.pages?.firstWhere((element) => element.cid == cid);
        mediaItem = MediaItem(
          id: heroTag,
          title: current?.pagePart ?? "",
          artist: data.title ?? "",
          album: data.title ?? "",
          duration: Duration(seconds: current?.duration ?? 0),
          artUri: Uri.parse(data.pic ?? ""),
        );
      } else {
        mediaItem = MediaItem(
          id: heroTag,
          title: data.title ?? "",
          artist: data.owner?.name ?? "",
          duration: Duration(seconds: data.duration ?? 0),
          artUri: Uri.parse(data.pic ?? ""),
        );
      }
    } else if (data is BangumiInfoModel) {
      final current =
          data.episodes?.firstWhere((element) => element.cid == cid);
      mediaItem = MediaItem(
        id: heroTag,
        title: current?.longTitle ?? "",
        artist: data.title ?? "",
        duration: Duration(milliseconds: current?.duration ?? 0),
        artUri: Uri.parse(data.cover ?? ""),
      );
    }
    if (mediaItem == null) return;
    setMediaItem(mediaItem);
    _item.add(mediaItem);
  }

  onVideoDetailDispose() {
    if (!enableBackgroundPlay) return;

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    if (_item.isNotEmpty) {
      _item.removeLast();
    }
    if (_item.isNotEmpty) {
      setMediaItem(_item.last);
    }
    if (_item.isEmpty) {
      playbackState
          .add(playbackState.value.copyWith(updatePosition: Duration.zero));
    }
    stop();
  }

  clear() {
    if (!enableBackgroundPlay) return;

    mediaItem.add(null);
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    _item.clear();
    stop();
  }

  onPositionChange(Duration position) {
    if (!enableBackgroundPlay) return;

    playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
    ));
  }
}
