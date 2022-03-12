import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_router/page_servers_modify.dart';
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

class PageServersState extends State<PageServers>
    with AutomaticKeepAliveClientMixin {
  //

  ValueNotifier<bool> ffNeedRefreshSwitch = ValueNotifier(false);
  ConfigServerList ffConfigServer = ConfigServerList();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getServersFromFile();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              //刷新
              icon: const Icon(Icons.cached),
              onPressed: () {
                switchRefresh();
              }),
          //添加
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var modifyParam = ModifyParam(
                  cmd: 'add',
                  configServer: ConfigServer(ip: '', serverName: ''));
              var result = await Navigator.pushNamed(
                  context, "server_detail_page",
                  arguments: modifyParam);
              //ffConfigServer.servers.add(result!);
              if (result != null) {
                serverAdd(result as ConfigServer);
              }
              //setState(() {});
            },
          ),
        ],
        title: Text(AppLocalizations.of(context).getString("server")),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: ffNeedRefreshSwitch,
        builder: (context, value, _) {
          return buildServerListView();
        },
      ),
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
        trailing: _serverPopupMenuButton(context, index),
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
          _serverPopupMenuButton(context, index),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  //弹出菜单
  PopupMenuButton<String> _serverPopupMenuButton(
      BuildContext context, int index) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (String v) async {
        //点击删除按钮
        if (v == "delete") {
          serverRemoveAt(index);
          debugPrint("删除: $index");
          //setState(() {});
        }

        //点击修改按钮
        if (v == "edit") {
          //创建一个路由参数，传递是add还是edit，edit的话还要附带一个ConfigServer类
          var modifyParam = ModifyParam(
              cmd: 'edit', configServer: ffConfigServer.servers[index]);
          var result = await Navigator.pushNamed(context, 'server_detail_page',
              arguments: modifyParam);
          if (result != null) {
            serverModifyAt(index, result as ConfigServer);
          }
          //setState(() {});
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
          onPressed: getServersFromFile,
          child: const Text("读取json文件"),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text("添加server"),
        ),
        ElevatedButton(
          onPressed: saveServerConfigToFile,
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

  Future<bool> getServersFromFile() async {
    try {
      String configFilePath = await getConfigFilePath();
      final File file = File(configFilePath);
      String serverConfig = await file.readAsString();
      ffConfigServer = ConfigServerList.fromJson(json.decode(serverConfig));
      //print(ffConfigServer.toJson());
      switchRefresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  saveAndRefresh() {
    ffConfigServer.count = ffConfigServer.servers.length;
    saveServerConfigToFile();
    switchRefresh();
  }

  serverAdd(ConfigServer server) {
    ffConfigServer.servers.add(server);
    saveAndRefresh();
  }

  serverRemoveAt(int index) {
    ffConfigServer.servers.removeAt(index);
    saveAndRefresh();
  }

  serverModifyAt(int index, ConfigServer server) {
    ffConfigServer.servers[index] = server;
    saveAndRefresh();
  }

  saveServerConfigToFile() async {
    //json count字段
    ffConfigServer.count = ffConfigServer.servers.length;
    //class -> json
    String js = json.encode(ffConfigServer.toJson());
    //获取config文件路径
    String configFilePath = await getConfigFilePath();
    //保存到文件
    File file = File(configFilePath);
    file.writeAsString(js);
    debugPrint('保存服务器信息');
  }

  switchRefresh() {
    ffNeedRefreshSwitch.value = !ffNeedRefreshSwitch.value;
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
  bool useUTF8 = true;

  ConfigServer({sreverType, serverName, ip, port, user, pass, bUtf8});

  ConfigServer.fromJson(Map<String, dynamic> json)
      : serverType = json['type'],
        serverName = json['name'],
        ip = json['ip'],
        port = json['port'],
        user = json['user'],
        pass = json['pass'],
        useUTF8 = json['useUTF8'];

  Map<String, dynamic> toJson() => {
        'type': serverType,
        'name': serverName,
        'ip': ip,
        'port': port,
        'user': user,
        'pass': pass,
        'useUTF8': useUTF8,
      };
}
