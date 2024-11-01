import 'package:flutter/material.dart';


class RecommendSetting extends StatefulWidget {
  const RecommendSetting({super.key});

  @override
  State<RecommendSetting> createState() => _RecommendSettingState();
}

class _RecommendSettingState extends State<RecommendSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐设置'),
      ),
    );
  }
}