import 'package:bilibili/common/widgets/bottom_seat.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

Box localCache = GStrorage.localCache;
late double sheetHeight;

class MoreDetail extends StatelessWidget {
  final Widget child;
  const MoreDetail({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = screenHeight * 0.75; // 屏幕高度的 3/4
    TextStyle? labelLarge = Theme.of(context).textTheme.labelLarge;
    sheetHeight = localCache.get('sheetHeight');
    return Stack(
      children: [
        // 遮罩层
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: contentHeight,
          child: Container(
          color: Colors.black,
          padding: const EdgeInsets.only(left: 14, right: 14),
          height: 2000,
          child: Column(
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  '更多内容',
                  style: TextStyle(
                    fontSize: labelLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                  child: CustomScrollView(
                slivers: [
                  child,
                  const BottomSeat(),
                ],
              ))
            ],
          ),
        ))
      ],
    );
  }
}
