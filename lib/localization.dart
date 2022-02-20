import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

//Localization String 本地语言文件
const lzString = <String, Map<String, String>>{
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

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String getString(String str) {
    //print(locale.languageCode + " " + str);
    String? ret = lzString[locale.languageCode]![str];
    ret ??= "null";
    return ret;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);
  //bool isSupported(Locale locale) => AppLocalizations.languages().contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
