import 'package:flutter/material.dart';

import 'localization.dart';
import 'page_main.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({Key? key}) : super(key: key);

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
                child: const Text('中文'),
                onPressed: () {
                  MyAppState.setting.changeLocale(const Locale('zh'));
                },
              ),
              ElevatedButton(
                child: const Text('English'),
                onPressed: () {
                  MyAppState.setting.changeLocale(const Locale('en'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
