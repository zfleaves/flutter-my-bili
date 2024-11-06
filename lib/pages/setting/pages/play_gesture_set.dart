import 'package:bilibili/models/common/gesture_mode.dart';
import 'package:bilibili/pages/setting/widgets/select_dialog.dart';
import 'package:bilibili/pages/setting/widgets/switch_item.dart';
import 'package:bilibili/utils/global_data.dart';
import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PlayGesturePage extends StatefulWidget {
  const PlayGesturePage({super.key});

  @override
  State<PlayGesturePage> createState() => _PlayGesturePageState();
}

class _PlayGesturePageState extends State<PlayGesturePage> {
  Box setting = GStrorage.setting;
  late int fullScreenGestureMode;

  @override
  void initState() {
    super.initState();
    fullScreenGestureMode = setting.get(SettingBoxKey.fullScreenGestureMode,
        defaultValue: FullScreenGestureMode.values.last.index);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '手势设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            title: Text('全屏手势', style: titleStyle),
            subtitle: Text(
              '通过手势快速进入全屏',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: '全屏手势',
                      value: FullScreenGestureMode
                          .values[fullScreenGestureMode].values,
                      values: FullScreenGestureMode.values.map((e) {
                        return {'title': e.labels, 'value': e.values};
                      }).toList());
                },
              );
              if (result != null) {
                GlobalData().fullScreenGestureMode = FullScreenGestureMode
                    .values
                    .firstWhere((element) => element.values == result);
                fullScreenGestureMode =
                    GlobalData().fullScreenGestureMode.index;
                setting.put(
                    SettingBoxKey.fullScreenGestureMode, fullScreenGestureMode);
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: '双击快退/快进',
            subTitle: '左侧双击快退，右侧双击快进',
            setKey: SettingBoxKey.enableQuickDouble,
            defaultVal: true,
          ),
        ],
      ),
    );
  }
}
