import 'package:bilibili/plugin/pl_player/models/play_status.dart';
import 'package:flutter/material.dart';

class ScrollAppBar extends StatelessWidget {
  final double scrollVal;
  final Function callback;
  final PlayerStatus playerStatus;
  const ScrollAppBar(
    this.scrollVal,
    this.callback,
    this.playerStatus,
    Key? key,
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final videoHeight = MediaQuery.sizeOf(context).width * 9 / 16;
    double scrollDistance = scrollVal;
    if (scrollVal > videoHeight - kToolbarHeight) {
      scrollDistance = videoHeight - kToolbarHeight;
    }
    return Positioned(
      top: -videoHeight + scrollDistance + kToolbarHeight + 0.5,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: scrollDistance / (videoHeight - kToolbarHeight),
        child: Container(
          height: statusBarHeight + kToolbarHeight,
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.only(top: statusBarHeight),
          child: AppBar(
            primary: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: TextButton(
              onPressed: () => callback(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  Text(
                    playerStatus == PlayerStatus.paused
                        ? '继续播放'
                        : playerStatus == PlayerStatus.completed
                            ? '重新播放'
                            : '播放中',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
