import 'dart:async';

import 'package:bilibili/pages/home/index.dart';
import 'package:bilibili/pages/main/index.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

void handleScrollEvent(ScrollController scrollController) {
  StreamController<bool> mainStream =
      Get.find<MainController>().bottomBarStream;
  StreamController<bool> searchBarStream =
      Get.find<HomeController>().searchBarStream;
  EasyThrottle.throttle(
    'stream-throttler',
    const Duration(milliseconds: 300),
    () {
      try {
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          mainStream.add(true);
          searchBarStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          mainStream.add(false);
          searchBarStream.add(false);
        }
      } catch (_) {}
    },
  );
}