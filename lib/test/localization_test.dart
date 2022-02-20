import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    "zh": {
      "appTitle": "智能备份",
      "album": "相册",
      "servers": "服务器",
      "task": "任务",
      "setting": "设置"
    },
    "en": {
      "appTitle": "Smart Backup",
      "album": "Album",
      "servers": "Servers",
      "task": "Task",
      "setting": "Setting"
    }
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String getString(String str) {
    String? ret = _localizedValues[locale.languageCode]![str];
    ret ??= "null";
    return ret;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  //bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);
  bool isSupported(Locale locale) =>
      AppLocalizations.languages().contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(AppLocalizations.of(context).getString("appTitle")),
        title: Text(gh.getlzString(context, "appTitle")),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).getString("title")),
      ),
    );
  }
}

class LzTestApp extends StatelessWidget {
  const LzTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context).getString("title"),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', ''),
          Locale('en', ''),
        ],
        // Watch out: MaterialApp creates a Localizations widget
        // with the specified delegates. DemoLocalizations.of()
        // will only find the app's Localizations widget if its
        // context is a child of the app.
        home: DemoApp());
  }
}

// Global Helper 全局助手
class gh {
  static String getlzString(BuildContext c, String s) {
    return AppLocalizations.of(c).getString(s);
  }
}
