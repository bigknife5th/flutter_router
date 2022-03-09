import 'package:flutter/material.dart';
import 'package:flutter_router/page_main.dart';

import 'localization.dart';
import 'page_ablum.dart';
import 'page_servers.dart';
import 'page_setting.dart';
import 'page_task.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  List listTabs = const [PageAblum(), PageServers(), PageTask(), PageSetting()];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      backgroundColor: Colors.grey[100],
      type: BottomNavigationBarType.fixed,
      //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
      items: [
        BottomNavigationBarItem(
          label: ggText(context, "album"),
          icon: const Icon(Icons.photo_album),
        ),
        BottomNavigationBarItem(
          label: ggText(context, "servers"),
          icon: const Icon(Icons.laptop_mac),
        ),
        BottomNavigationBarItem(
          label: ggText(context, "task"),
          icon: const Icon(Icons.library_books),
        ),
        BottomNavigationBarItem(
          label: ggText(context, "setting"),
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}

class BottomNavgationInfo {
  int pageIndex = 0;
  BottomNavgationInfo(this.pageIndex);
}

class BottomNavgationInfoContext extends InheritedWidget {
  //数据
  final BottomNavgationInfo bottomNavgationInfo;

  const BottomNavgationInfoContext({
    Key? key,
    required this.bottomNavgationInfo,
    required Widget child,
  }) : super(key: key, child: child);

  static BottomNavgationInfoContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(
        aspect: BottomNavgationInfoContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(BottomNavgationInfoContext oldWidget) {
    return bottomNavgationInfo != oldWidget.bottomNavgationInfo;
  }
}
