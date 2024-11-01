import 'package:flutter/material.dart';

class BangumiIntroPanel extends StatefulWidget {
  const BangumiIntroPanel({super.key});

  @override
  State<BangumiIntroPanel> createState() => _BangumiIntroPanelState();
}

class _BangumiIntroPanelState extends State<BangumiIntroPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('番剧'),
    );
  }
}