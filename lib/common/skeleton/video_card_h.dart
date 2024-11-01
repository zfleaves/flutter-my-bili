import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/skeleton.dart';
import 'package:flutter/material.dart';

class VideoCardHSkeleton extends StatelessWidget {
  const VideoCardHSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            StyleString.safeSpace, 7, StyleString.safeSpace, 7),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            double width =
                (boxConstraints.maxWidth - StyleString.cardSpace * 6) / 2;
            return SizedBox(
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius:
                                BorderRadius.circular(StyleString.imgRadius.x),
                          ),
                        );
                      },
                    ),
                  ),
                  // VideoContent(videoItem: videoItem)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 200,
                          height: 11,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 150,
                          height: 13,
                        ),
                        const Spacer(),
                        Container(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          width: 100,
                          height: 13,
                          margin: const EdgeInsets.only(bottom: 5),
                        ),
                        Row(
                          children: [
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              width: 40,
                              height: 13,
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              width: 40,
                              height: 13,
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
