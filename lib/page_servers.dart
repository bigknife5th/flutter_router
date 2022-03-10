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
  void initState() {
    super.initState();
    getServersFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              //刷新
              icon: const Icon(Icons.cached),
              onPressed: () {
                setState(() {});
              }),
          //添加
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              String cmd = 'add';
              var result = await Navigator.pushNamed(
                  context, "server_detail_page",
                  arguments: cmd);
              //ffConfigServer.servers.add(result!);
              if (result != null) {
                ffConfigServer.servers.add(result as ConfigServer);
              }
              setState(() {});
            },
          ),
        ],
        title: Text(AppLocalizations.of(context).getString("server")),
      ),
      body: Center(
        child: buildServerListView(),
      ),
    );
  }

  FutureBuilder<bool> buildFutureBuilder() {
    return FutureBuilder<bool>(
      future: getServersFromJson(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return buildServerListView();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error_outline);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget buildServerListView() {
    return ListView.builder(
      itemCount: ffConfigServer.servers.length,
      itemBuilder: (context, index) {
        return _standListTile(context, index);
      },
    );
  }

  Card _standListTile(BuildContext context, int index) {
    return Card(
      child: ListTile(
        title: Text(
          ffConfigServer.servers[index].serverName,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        subtitle: Text(
          ffConfigServer.servers[index].ip,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: _serverPopupMenuButton(index),
      ),
    );
  }

  Card buildMyCard(BuildContext context, int index) {
    return Card(
      child: Row(
        children: [
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                ffConfigServer.servers[index].serverName,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                ffConfigServer.servers[index].ip,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
            ],
          ),
          const Expanded(child: SizedBox()),
          _serverPopupMenuButton(index),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  PopupMenuButton<String> _serverPopupMenuButton(int index) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (String v) async {
        //点击删除按钮
        if (v == "delete") {
          ffConfigServer.servers.removeAt(index);
          print("delete: $index");
          setState(() {});
        }

        //点击修改按钮
        if (v == "edit") {
          var result = await Navigator.pushNamed(context, 'server_detail_page',
              arguments: ffConfigServer.servers[index]);
          if (result != null) {
            ffConfigServer.servers[index] = result as ConfigServer;
          }
          setState(() {});
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            child: Text("Edit"),
            value: "edit",
          ),
          const PopupMenuItem(
            child: Text("Duplicate"),
            value: "duplicate",
          ),
          const PopupMenuItem(
            child: Text("Delete"),
            value: "delete",
          ),
        ];
      },
    );
  }

  Widget buildTestColumn() {
    return Column(
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
    );
  }

  // 逻辑代码 UI无关
  Future<String> getConfigFilePath() async {
    final Directory? directory = await getExternalStorageDirectory();
    return '${directory!.path}/config/servers.json';
  }

  Future<bool> getServersFromJson() async {
    try {
      String configFilePath = await getConfigFilePath();
      final File file = File(configFilePath);
      String serverConfig = await file.readAsString();
      ffConfigServer = ConfigServerList.fromJson(json.decode(serverConfig));
      //print(ffConfigServer.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  addServer() {
    ConfigServer server =
        ConfigServer(ip: '192.168.0.139', serverName: 'cat', port: 9521);
    ffConfigServer.servers.add(server);
  }

  saveServerConfigToJson() async {
    //json count字段
    ffConfigServer.count = ffConfigServer.servers.length;
    //class -> json
    String js = json.encode(ffConfigServer.toJson());
    //获取config文件路径
    String configFilePath = await getConfigFilePath();
    //保存到文件
    File file = File(configFilePath);
    file.writeAsString(js);
    //print(js);
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
    port,
    required this.ip,
    required this.serverName,
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
