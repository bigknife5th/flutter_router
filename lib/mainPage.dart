import 'package:flutter/material.dart';

class PageMain extends StatelessWidget {
  const PageMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //title: AppLocalizations.of(context).appTitle,
        home: Scaffold(
            appBar: AppBar(
      //title: Text(AppLocalizations.of(context).appTitle),
      title: const Text("Smart"),
    )));
  }
}
