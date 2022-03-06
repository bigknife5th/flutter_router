//测试用GridView展示相册

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
//import 'file_manager.dart';
import '../tool_filemanager.dart';
import 'package:permission_handler/permission_handler.dart';

typedef MyCallback = Function();

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PageAlbum());
  }
}

class PageAlbum extends StatefulWidget {
  const PageAlbum({Key? key}) : super(key: key);

  @override
  State<PageAlbum> createState() => _PageAlbumState();
}

class _PageAlbumState extends State<PageAlbum> {
  List<FileSystemEntity> ffEntities = [];
  ValueNotifier<bool> ffRefreshSignal = ValueNotifier<bool>(false);

  @override
  void initState() {
    checkPermission();
    getAlbumFolders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildGridView();
  }

  GridView buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, //每行三列
        // mainAxisSpacing: 5,
        // crossAxisSpacing: 5,
        // childAspectRatio: 1.0, //显示区域宽高相等
      ),
      itemCount: ffEntities.length,
      itemBuilder: (context, index) {
        return ValueListenableBuilder(
          valueListenable: ffRefreshSignal,
          builder: (context, snapshot, _) {
            return Text(
              ffEntities[index].path,
              style: const TextStyle(fontSize: 12),
            );
          },
        );
      },
    );
  }

  getAlbumFolders() async {
    var storages = await FileManager.getStorageList();
    if (storages.isEmpty) {
      return;
    }

    ffEntities = await FileManager.getEntitysList(storages.first.path);
    if (ffEntities.isEmpty) {
      return;
    }

    print(ffEntities);
    ffRefreshSignal.value = !ffRefreshSignal.value;
  }
}
