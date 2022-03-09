import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization.dart';
import 'page_main.dart';
import 'bottombar.dart';
import 'page_ablum.dart';
import 'page_servers.dart';
import 'page_setting.dart';
import 'page_task.dart';

class _AppSetting {
  late Null Function(Locale locale) changeLocale;
  Locale _locale = const Locale("zh");
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static _AppSetting setting = _AppSetting();
  late AppLocalizations ffLocal;
  List<Widget> ffPageList = const [
    PageAblum(),
    PageServers(),
    PageTask(),
    PageSetting()
  ];
  int ffSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    //ffLocal = AppLocalizations.of(context);
    setting.changeLocale = (Locale locale) {
      setState(() {
        setting._locale = locale;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context).getString("app_title");
      },

      // 以下都不用管，新系统代码或复制来的固定代码
      //
      //
      localeResolutionCallback: (locale, supportedLocales) {
        var result = supportedLocales
            .where((element) => element.languageCode == locale?.languageCode);
        if (result.isNotEmpty) {
          print("====locale find");
          return locale;
        }
        return const Locale("zh");
      },
      locale: setting._locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      //
      //
      //以上都不用管，新系统代码或复制来的固定代码

      //自己代码开始
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text(ggText(context, "app_title")),
        // ),
        body: ffPageList[ffSelectedIndex],
        bottomNavigationBar: buildBottomBar(context),
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: ffSelectedIndex,
      onTap: changePage,
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

  void changePage(int index) {
    if (index != ffSelectedIndex) {
      setState(() {
        ffSelectedIndex = index;
      });
    }
  }
}
