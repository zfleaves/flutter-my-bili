import 'package:bilibili/common/constants.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActionItem extends StatelessWidget {
  final dynamic icon;
  final Icon? selectIcon;
  final Function? onTap;
  final Function? onLongPress;
  final String? text;
  final bool selectStatus;
  const ActionItem(
      {super.key,
      this.icon,
      this.selectIcon,
      this.onTap,
      this.onLongPress,
      this.text,
      this.selectStatus = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        feedBack();
        onTap!();
      },
      onLongPress: () => {
        if (onLongPress != null) {onLongPress!()}
      },
      borderRadius: StyleString.mdRadius,
      child: SizedBox(
        width: (Get.size.width - 24) / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: icon is Icon
                    ? Icon(
                        selectStatus
                            ? selectIcon!.icon ?? icon!.icon
                            : icon!.icon,
                        color: selectStatus
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      )
                    : Image.asset(
                        key: ValueKey<bool>(selectStatus),
                        'assets/images/coin.png',
                        width: const IconThemeData.fallback().size,
                        color: selectStatus
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      )),
            const SizedBox(height: 6),
            Text(
              text ?? '',
              style: TextStyle(
                color:
                    selectStatus ? Theme.of(context).colorScheme.primary : null,
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
