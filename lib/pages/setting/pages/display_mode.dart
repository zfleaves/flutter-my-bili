import 'package:flutter/material.dart';

class SetDiaplayMode extends StatefulWidget {
  const SetDiaplayMode({super.key});

  @override
  State<SetDiaplayMode> createState() => _SetDiaplayModeState();
}

class _SetDiaplayModeState extends State<SetDiaplayMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('屏幕帧率设置'),
      ),
    );
  }
}