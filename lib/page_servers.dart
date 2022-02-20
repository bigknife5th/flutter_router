import 'package:flutter/material.dart';

import 'localization.dart';

class PageServers extends StatefulWidget {
  const PageServers({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageServersState();
  }
}

class PageServersState extends State<PageServers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context).getString("server"))),
        body: Center(
          child: Text(AppLocalizations.of(context).getString("server")),
        ));
  }
}
