import 'package:flutter/material.dart';

class BottomSeat extends StatelessWidget {
  final bool isCustomScroll;
  final double bottomHeight;
  const BottomSeat(
      {super.key, this.isCustomScroll = true, this.bottomHeight = 10});

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom;
    Widget seat = Container(
      height: bottom + bottomHeight,
      padding: EdgeInsets.only(bottom: bottom),
    );

    if (isCustomScroll) {
      return SliverToBoxAdapter(
        child: seat,
      );
    }
    return seat;
  }
}
