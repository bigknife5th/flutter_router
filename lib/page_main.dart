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

  @override
  void initState() {
    super.initState();
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
        return AppLocalizations.of(context).getString("appTitle");
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
      home: const Scaffold(
        body: PageAblum(),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
}
