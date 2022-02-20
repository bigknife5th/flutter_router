import 'package:flutter/material.dart';

import 'localization.dart';
import 'page_main.dart';

class PageSetting extends StatefulWidget {
  @override
  _PageSettingState createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('中文'),
                onPressed: () {
                  MyAppState.setting.changeLocale(Locale('zh'));
                },
              ),
              ElevatedButton(
                child: Text('English'),
                onPressed: () {
                  MyAppState.setting.changeLocale(Locale('en'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
