import 'dart:io';
import 'package:flutter/material.dart';

import 'localization.dart';
import 'tool_filemanager.dart';

///
///
///
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

class BackupTask {
  //相册在手机上的路径
  late String path;
  //备份到服务器的路径
  late String backupPath;
  //手机上的文件读取到这里
  List<FileSystemEntity> files = <FileSystemEntity>[];
  //备份开关
  bool isChecked = true;

  BackupTask({required this.path}) {
    //getEntity();
  }

  getEntity() async {
    files.clear();
    files = await FileManager.getEntitysList(path);
  }
}
