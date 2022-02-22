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

class ConfigServer {
  String type = 'ftp'; //FTP或其他，前期只写FTP
  late String name;
  late String ip;
  int port = 21;
  late String loginName;
  late String loginPassword;

  ConfigServer(
      {required this.type,
      required this.name,
      required this.ip,
      required this.port,
      required this.loginName,
      required this.loginPassword});

  ConfigServer.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        name = json['name'],
        ip = json['ip'],
        port = json['port'],
        loginName = json['loginName'],
        loginPassword = json['loginPassword'];

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'ip': ip,
        'port': port,
        'loginName': loginName,
        'loginPassword': loginPassword,
      };
}
