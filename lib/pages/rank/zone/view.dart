import 'package:flutter/material.dart';


class ZonePage extends StatefulWidget {
  final int rid;
  const ZonePage({super.key, required this.rid});

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('单列布局 EdgeInsets.zero'),
    );
  }
}