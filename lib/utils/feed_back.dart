import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'storage.dart';

Box<dynamic> setting = GStrorage.setting;
void feedBack() {
  // 设置中是否开启
  final bool enable =
      setting.get(SettingBoxKey.feedBackEnable, defaultValue: false) as bool;
  if (enable) {
    // HapticFeedback.lightImpact() 是一个调用触觉反馈的函数，当满足某些条件时（在这个例子中是当反馈功能启用时），它会触发一个轻微的触觉反馈。
    HapticFeedback.lightImpact();
  }
}
