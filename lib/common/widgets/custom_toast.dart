import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Box<dynamic> setting = GStrorage.setting;


class CustomToast extends StatelessWidget {
  final String msg;
  const CustomToast({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final double toastOpacity = setting.get(SettingBoxKey.defaultToastOp, defaultValue: 1.0) as double;
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(toastOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        msg,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }
}