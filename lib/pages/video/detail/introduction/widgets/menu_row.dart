import 'package:bilibili/utils/feed_back.dart';
import 'package:flutter/material.dart';



class ActionRowLineItem extends StatelessWidget {
  const ActionRowLineItem({
    super.key,
    this.selectStatus,
    this.onTap,
    this.text,
    this.loadingStatus = false,
  });
  final bool? selectStatus;
  final Function? onTap;
  final bool? loadingStatus;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selectStatus!
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          feedBack();
          onTap!();
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 5.5, 13, 4.5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            border: Border.all(
              color: selectStatus!
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: loadingStatus! ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  text!,
                  style: TextStyle(
                      fontSize: 13,
                      color: selectStatus!
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}