import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final Map<String, Map<String, String>> _localizedValues = {
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

  String get appTitle {
    return _localizedValues[locale.languageCode]!["appTitle"]!;
  }

  String get album {
    return _localizedValues[locale.languageCode]!["album"]!;
  }

  String get servers {
    return _localizedValues[locale.languageCode]!["servers"]!;
  }

  String get task {
    return _localizedValues[locale.languageCode]!["task"]!;
  }

  String get setting {
    return _localizedValues[locale.languageCode]!["setting"]!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
