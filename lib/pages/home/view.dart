import 'dart:async';

import 'package:bilibili/common/widgets/network_img_layer.dart';
import 'package:bilibili/pages/home/controller.dart';
import 'package:bilibili/pages/mine/view.dart';
import 'package:bilibili/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  List videoList = [];
  late Stream<bool> stream;

  @override
  void initState() {
    super.initState();
    stream = _homeController.searchBarStream.stream;
  }

  showUserBottomSheet() {
    feedBack();
    showModalBottomSheet(
      context: context, 
      builder: (_) => const SizedBox(
        height: 450,
        child: MinePage(),
      ),
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    // 设置状态栏图标的亮度
    if (_homeController.enableGradientBg) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarBrightness: currentBrightness == Brightness.light
              ? Brightness.dark
              : Brightness.light));
    }

    // extendBody: true
    // 当 extendBody 设置为 true 时，Scaffold 的 body 部分会延伸到 AppBar 的下方
    //（如果 AppBar 是透明的或者有透明的部分，那么 body 的内容就会在这些透明部分下方显示）
    //。这通常用于创建沉浸式体验，让用户感觉内容更加融入整个屏幕。

    // extendBodyBehindAppBar: true
    // extendBodyBehindAppBar 属性允许 Scaffold 的 body 部分延伸到 AppBar 的背后，
    //即使 AppBar 不是完全透明的。这通常与具有模糊背景或渐变色背景的 AppBar 一起使用，
    //以创建一种视觉上的连续性，让用户感觉 AppBar 和 body 是无缝连接的。
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _homeController.enableGradientBg
          ? null
          : AppBar(
              toolbarHeight: 0,
              elevation: 0,
            ),
      body: Stack(
        children: [
          if (_homeController.enableGradientBg) ...[
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.9),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            Theme.of(context).colorScheme.surface
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0, 0.0034, 0.34])),
                ),
              ),
            )
          ],
          Column(
            children: [
              CustomAppBar(
                stream: _homeController.hideSearchBar
                    ? stream
                    : StreamController<bool>.broadcast().stream,
                ctr: _homeController,
                callback: showUserBottomSheet,
              ),
              if (_homeController.tabs.length > 1) ...[
                if (_homeController.enableGradientBg) ...[
                  const CustomTabs(),
                ] else ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: Align(
                      alignment: Alignment.center,
                      child: TabBar(
                        controller: _homeController.tabController,
                        tabs: [
                          for (var i in _homeController.tabs)
                            Tab(text: i['label'])
                        ],
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        enableFeedback: true,
                        splashBorderRadius: BorderRadius.circular(10),
                        tabAlignment: TabAlignment.center,
                        onTap: (value) {
                          feedBack();
                          if (_homeController.initialIndex.value == value) {
                            _homeController.tabsCtrList[value]().animateToTop();
                          }
                          _homeController.initialIndex.value = value;
                        },
                      ),
                    ),
                  )
                ]
              ] else ...[
                const SizedBox(height: 6),
              ],
              Expanded(
                child: TabBarView(
                  controller: _homeController.tabController,
                  children: _homeController.tabsPageList
                )
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;
  final HomeController? ctr;
  final Function? callback;
  const CustomAppBar(
      {super.key,
      this.height = kToolbarHeight,
      this.stream,
      this.ctr,
      this.callback});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream!.distinct(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          bool flag = snapshot.data ?? true;
          final RxBool isUserLoggedIn = ctr!.userLogin;
          final double top = MediaQuery.of(context).padding.top;
          return AnimatedOpacity(
            opacity: flag ? 1 : 0,
            // opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 500),
              height: flag ? top + 52 : top,
              // height: top + 52,
              padding: EdgeInsets.fromLTRB(14, top + 6, 14, 0),
              child: UserInfoWidget(
                top: top,
                ctr: ctr,
                userLogin: isUserLoggedIn,
                userFace: ctr?.userFace.value,
                callback: () => callback!(),
              ),
            ),
          );
        });
  }
}

class UserInfoWidget extends StatelessWidget {
  final double top;
  final RxBool userLogin;
  final String? userFace;
  final VoidCallback? callback;
  final HomeController? ctr;
  const UserInfoWidget(
      {super.key,
      required this.top,
      required this.userLogin,
      this.userFace,
      this.callback,
      this.ctr});

  Widget buildLoggedInWidget(context) {
    return Stack(
      children: [
        NetworkImgLayer(
          type: 'avatar',
          width: 34,
          height: 34,
          src: userFace,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => callback?.call(),
              splashColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SearchBar(
          ctr: ctr,
        ),
        if (userLogin.value) ...[
          const SizedBox(width: 4),
          ClipRect(
            child: IconButton(
              onPressed: () => Get.toNamed('/whisper'),
              icon: const Icon(Icons.notifications_none),
            ),
          )
        ],
        const SizedBox(width: 8),
        Obx(
          () => userLogin.value
              ? buildLoggedInWidget(context)
              : DefaultUser(callback: () => callback!()),
        ),
      ],
    );
  }
}

class DefaultUser extends StatelessWidget {
  const DefaultUser({super.key, this.callback});
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.onInverseSurface;
          }),
        ),
        onPressed: () => callback?.call(),
        icon: Icon(
          Icons.person_rounded,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final HomeController? ctr;
  const SearchBar({super.key, this.ctr});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        width: 250,
        height: 44,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: colorScheme.onSecondaryContainer.withOpacity(0.05),
          child: InkWell(
            splashColor: colorScheme.primaryContainer.withOpacity(0.3),
            onTap: () => Get.toNamed('/search',
                parameters: {'hintText': ctr!.defaultSearch.value}),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_outlined,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                        ctr!.defaultSearch.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTabs extends StatefulWidget {
  const CustomTabs({super.key});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  final HomeController _homeController = Get.put(HomeController());

  void onTap(int index) {
    feedBack();
    if (_homeController.initialIndex.value == index) {
      _homeController.tabsCtrList[index]().animateToTop();
    }
    _homeController.initialIndex.value = index;
    _homeController.tabController.index = index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4),
      child: Obx(() => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          String label = _homeController.tabs[index]['label'];
          return Obx(() => CustomChip(
            onTap: () => onTap(index),
            label: label, 
            selected: index == _homeController.initialIndex.value
          ));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 10,);
        },
        itemCount: _homeController.tabs.length
      )),
    );
  }
}


class CustomChip extends StatelessWidget {
  final Function onTap;
  final String label;
  final bool selected;
  const CustomChip({super.key, required this.onTap, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    print(onTap);
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    final Color secondaryContainer = colorTheme.secondaryContainer;
    final Color onPrimary = colorTheme.onPrimary;
    final Color primary = colorTheme.primary;
    final TextStyle chipTextStyle = selected
        ? TextStyle(fontSize: 13, color: onPrimary)
        : TextStyle(fontSize: 13, color: colorTheme.onSecondaryContainer);
    const VisualDensity visualDensity =
        VisualDensity(horizontal: -4.0, vertical: -2.0);
    return InputChip(
      side: BorderSide.none,
      backgroundColor: secondaryContainer,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected) ||
            states.contains(WidgetState.hovered)) {
          return primary;
        }
        return colorTheme.secondaryContainer;
      }),
      padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
      label: Text(label, style: chipTextStyle),
      onPressed: () => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      selected: selected,
      showCheckmark: false,
      visualDensity: visualDensity,
    );
  }
}
