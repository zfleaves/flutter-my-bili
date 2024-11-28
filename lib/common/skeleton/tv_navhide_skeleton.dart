import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/skeleton/skeleton.dart';
import 'package:flutter/material.dart';

class TvNavhideSkeleton extends StatelessWidget {
  const TvNavhideSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).colorScheme.onInverseSurface;
    return Skeleton(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(
          StyleString.safeSpace, 7, StyleString.safeSpace, 7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 111,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: bgColor),
              ),
              Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: bgColor),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            height: 240,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: bgColor),
          ),
          // GridView.count(
          //   crossAxisCount: 3,
          //   padding: EdgeInsets.zero,
          //   physics: const NeverScrollableScrollPhysics(),
          //   mainAxisSpacing: 4.0,
          //   crossAxisSpacing: 4.0,
          //   childAspectRatio: 1,
          //   children: [
          //     for (var i = 0; i < 12; i++) ...[
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Container(
          //             width: 200,
          //             height: 13,
          //             margin: const EdgeInsets.only(bottom: 12),
          //             color: Theme.of(context).colorScheme.onInverseSurface,
          //           ),
          //           Container(
          //             width: 200,
          //             height: 13,
          //             margin: const EdgeInsets.only(bottom: 5),
          //             color: Theme.of(context).colorScheme.onInverseSurface,
          //           ),
          //           Container(
          //             width: 200,
          //             height: 13,
          //             margin: const EdgeInsets.only(bottom: 5),
          //             color: Theme.of(context).colorScheme.onInverseSurface,
          //           ),
          //         ],
          //       )
          //     ]
          //   ],
          // )
        ],
      ),
    ));
  }
}
