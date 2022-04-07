/// 测试Stream和List的区别

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../tool_filemanager.dart';
//import 'package:photo_album_manager/photo_album_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PageAblum());
  }
}

class PageAblum extends StatefulWidget {
  const PageAblum({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PageAblumState();
}

class PageAblumState extends State<PageAblum> {
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPress,
            child: const Text('test'),
          ),
          ElevatedButton(
            onPressed: onPress2,
            child: const Text('test2'),
          ),
        ],
      ),
    );
  }

  void onPress() async {
    String path = '/storage/emulated/0/Pictures/Gallery/owner/小鱼儿';
    Stream<FileSystemEntity> entityList =
        Directory(path).list(recursive: false, followLinks: false);

    // await for (FileSystemEntity entity in entityList) {
    //   //文件、目录和链接都继承自FileSystemEntity
    //   //FileSystemEntity.type静态函数返回值为FileSystemEntityType
    //   //FileSystemEntityType有三个常量：
    //   //Directory、FILE、LINK、NOT_FOUND
    //   //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
    //   //debugPrint(entity.path);
    // }
    debugPrint("test1 start");
    FileSystemEntity entity = await entityList.first;
    debugPrint(entity.path);
    debugPrint("test1 end");
  }

  void onPress2() async {
    String path = '/storage/emulated/0/Pictures/Gallery/owner/小鱼儿';
    List<FileSystemEntity> entityList = await Directory(path)
        .list(recursive: false, followLinks: false)
        .toList();
    debugPrint("test2 start");
    for (FileSystemEntity entity in entityList) {
      //文件、目录和链接都继承自FileSystemEntity
      //FileSystemEntity.type静态函数返回值为FileSystemEntityType
      //FileSystemEntityType有三个常量：
      //Directory、FILE、LINK、NOT_FOUND
      //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
      //debugPrint(entity.path);
    }
    debugPrint("test2 end");
  }
}
