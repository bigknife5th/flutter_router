import 'dart:io';

import 'package:flutter/material.dart';
import 'localization.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class PageServers extends StatefulWidget {
  const PageServers({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageServersState();
  }
}

class PageServersState extends State<PageServers> {
  ConfigServerList ffConfigServer = ConfigServerList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).getString("server"))),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: getServersFromJson,
              child: const Text("读取json文件"),
            ),
            ElevatedButton(
              onPressed: addServer,
              child: const Text("添加server"),
            ),
            ElevatedButton(
              onPressed: saveServerConfigToJson,
              child: const Text("保存到文件"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getConfigFilePath() async {
    final Directory? directory = await getExternalStorageDirectory();
    return '${directory!.path}/config/servers.json';
  }

  getServersFromJson() async {
    String configFilePath = await getConfigFilePath();
    final File file = File(configFilePath);
    String serverConfig = await file.readAsString();
    ffConfigServer = ConfigServerList.fromJson(json.decode(serverConfig));
    print(ffConfigServer.toJson());
  }

  addServer() {
    ConfigServer server = ConfigServer(ip: '192.168.0.139');
    ffConfigServer.servers.add(server);
  }

  saveServerConfigToJson() async {
    ffConfigServer.count = ffConfigServer.servers.length;
    String js = json.encode(ffConfigServer.toJson());
    String configFilePath = await getConfigFilePath();
    File file = File(configFilePath);
    file.writeAsString(js);
    print(js);
  }
}

class ConfigServerList {
  int count = 0;
  List<ConfigServer> servers = [];

  ConfigServerList();

  ConfigServerList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        servers = (json['servers'] as List)
            .map((m) => ConfigServer.fromJson(m))
            .toList();

  Map<String, dynamic> toJson() => {
        'count': count,
        'servers': servers,
      };
}

class ConfigServer {
  String serverType = 'ftp'; //FTP或其他，前期只写FTP
  String serverName = '';
  String ip = '';
  int port = 21;
  String user = 'anonymous';
  String pass = '';
  bool bUtf8 = true;

  ConfigServer({
    sreverType,
    serverName,
    port,
    required this.ip,
  });

  ConfigServer.fromJson(Map<String, dynamic> json)
      : serverType = json['type'],
        serverName = json['name'],
        ip = json['ip'],
        port = json['port'],
        user = json['user'],
        pass = json['pass'],
        bUtf8 = json['useUTF8'];

  Map<String, dynamic> toJson() => {
        'type': serverType,
        'name': serverName,
        'ip': ip,
        'port': port,
        'user': user,
        'pass': pass,
        'useUTF8': bUtf8,
      };
}
