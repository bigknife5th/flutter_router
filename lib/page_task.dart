import 'package:flutter/material.dart';

import 'localization.dart';

class PageTask extends StatefulWidget {
  const PageTask({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageTaskState();
  }
}

class PageTaskState extends State<PageTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text(AppLocalizations.of(context).getString("task"))),
        body: Center(
          child: Text(AppLocalizations.of(context).getString("task")),
        ));
  }
}
