import 'dart:math';

import 'package:flutter/material.dart';

Random random = Random();

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool keepAlive;
  final String? tag;

  const KeepAliveWrapper({super.key, required this.child, this.keepAlive = true, this.tag });

  // const KeepAliveWrapper({super.key});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return  widget.child;
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.tag != widget.tag) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    // if (oldWidget.keepAlive != widget.keepAlive) {
    //   // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
    //   updateKeepAlive();
    // }
    super.didUpdateWidget(oldWidget);
  }
}
