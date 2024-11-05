import 'package:bilibili/models/dynamics/result.dart';
import 'package:bilibili/pages/dynamics/controller.dart';
import 'package:bilibili/pages/dynamics/widgets/action_panel.dart';
import 'package:bilibili/pages/dynamics/widgets/author_panel.dart';
import 'package:bilibili/pages/dynamics/widgets/content_panel.dart';
import 'package:bilibili/pages/dynamics/widgets/forward_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicPanel extends StatelessWidget {
  final DynamicItemModel item;
  final String? source;
  DynamicPanel({super.key, required this.item, this.source});
  final DynamicsController _dynamicsController = Get.put(DynamicsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: source == 'detail'
          ? const EdgeInsets.only(bottom: 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 8,
            color: Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ),
      ),
      child: Material(
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: InkWell(
          onTap: () => _dynamicsController.pushDetail(item, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: AuthorPanel(item: item),
              ),
              if ((item.modules!.moduleDynamic!.desc != null || item.modules!.moduleDynamic!.major != null)) ...[
                Content(item: item, source: source),
              ],
              forWard(item, context, _dynamicsController, source),
              const SizedBox(height: 2),
              if (source == null) ...[
                ActionPanel(item: item),
              ]
            ],
          ),
        ),
      ),
    );
  }
}