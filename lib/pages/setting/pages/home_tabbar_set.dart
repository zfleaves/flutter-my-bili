import 'package:bilibili/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';

import '../../../models/common/tab_type.dart';

class TabbarSetPage extends StatefulWidget {
  const TabbarSetPage({super.key});

  @override
  State<TabbarSetPage> createState() => _TabbarSetPageState();
}

class _TabbarSetPageState extends State<TabbarSetPage> {
  Box setting = GStrorage.setting;
  late List defaultTabs;
  late List<String> tabbarSort;

  @override
  void initState() {
    super.initState();
    defaultTabs = tabsConfig;
    tabbarSort = setting.get(SettingBoxKey.tabbarSort,
        defaultValue: ['live', 'rcmd', 'hot', 'bangumi', 'tv']);
    // 对 tabData 进行排序
    defaultTabs.sort((a, b) {
      int indexA = tabbarSort.indexOf((a['type'] as TabType).id);
      int indexB = tabbarSort.indexOf((b['type'] as TabType).id);

      // 如果类型在 sortOrder 中不存在，则放在末尾
      if (indexA == -1) indexA = tabbarSort.length;
      if (indexB == -1) indexB = tabbarSort.length;

      return indexA.compareTo(indexB);
    });
  }
  
  void saveEdit() {
    List<String> sortedTabbar = defaultTabs
        .where((i) => tabbarSort.contains((i['type'] as TabType).id))
        .map<String>((i) => (i['type'] as TabType).id)
        .toList();
    setting.put(SettingBoxKey.tabbarSort, sortedTabbar);
    SmartDialog.showToast('保存成功，下次启动时生效');
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final tabsItem = defaultTabs.removeAt(oldIndex);
      defaultTabs.insert(newIndex, tabsItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = [
      for (int i = 0; i < defaultTabs.length; i++) ...[
        CheckboxListTile(
          key: Key(defaultTabs[i]['label']),
          value: tabbarSort.contains((defaultTabs[i]['type'] as TabType).id),
          onChanged: (bool? newValue) {
            String tabTypeId = (defaultTabs[i]['type'] as TabType).id;
            if (!newValue!) {
              tabbarSort.remove(tabTypeId);
            } else {
              tabbarSort.add(tabTypeId);
            }
            setState(() {});
          },
          title: Text(defaultTabs[i]['label']),
          secondary: const Icon(Icons.drag_indicator_rounded),
        )
      ]
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Tabbar编辑',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          TextButton(onPressed: () => saveEdit(), child: const Text('保存')),
          const SizedBox(width: 12)
        ],
      ),
      body: ReorderableListView(
        onReorder: onReorder,
        physics: const NeverScrollableScrollPhysics(),
        footer: SizedBox(
          height: MediaQuery.of(context).padding.bottom + 30,
        ),
        children: listTiles,
      ),
    );
  }
}
