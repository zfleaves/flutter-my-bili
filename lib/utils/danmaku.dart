import 'package:flutter/material.dart';
import 'package:ns_danmaku/models/danmaku_item.dart';

class DmUtils {
  static Color decimalToColor(int decimalColor) {
    // 16777215 表示白色
    int red = (decimalColor >> 16) & 0xFF;
    int green = (decimalColor >> 8) & 0xFF;
    int blue = decimalColor & 0xFF;

    return Color.fromARGB(255, red, green, blue);
  }

  static DanmakuItemType getPosition(int mode) {
    DanmakuItemType type = DanmakuItemType.scroll;
    if (mode >= 1 && mode <= 3) {
      type = DanmakuItemType.scroll;
    } else if (mode == 4) {
      type = DanmakuItemType.bottom;
    } else if (mode == 5) {
      type = DanmakuItemType.top;
    }
    return type;
  }
}
