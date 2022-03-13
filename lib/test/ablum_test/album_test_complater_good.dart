///
/// 在刷新函数里，每添加一条path就设置一次ffNeedRefresh.value = !ffNeedRefresh.value;
/// 通知ValueListenableBuilder刷新

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../tool_filemanager.dart';

main() {
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
  State<PageAblum> createState() => _PageAblumState();
}

class _PageAblumState extends State<PageAblum> {
  List<FileSystemEntity> ffEntities = [];
  ValueNotifier<bool> ffNeedRefresh = ValueNotifier(false);
  String ffRootPath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('complater测试'),
        actions: [
          IconButton(
            onPressed: onRefreshButtonClick,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: ffNeedRefresh,
        builder: (BuildContext context, value, Widget? child) {
          return ListView.builder(
            itemCount: ffEntities.length,
            itemBuilder: (context, index) {
              return Card(
                child: Text(ffEntities[index].path),
              );
            },
          );
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void onRefreshButtonClick() async {
    var dir = Directory('/storage/emulated/0/Pictures');
    //dirContents(dir).then((value) {
    getAlbumFolders().then((value) {
      //ffEntities = value;
      //debugPrint(ffEntities.toString());
      //ffNeedRefresh.value = !ffNeedRefresh.value;
    });
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: true);
    lister.listen(
      (file) {
        files.add(file);
      },
      // should also register onError
      onDone: () {
        completer.complete(files);
        debugPrint("完成");
      },
    );
    ffNeedRefresh.value = !ffNeedRefresh.value;
    return completer.future;
  }

  Future<void> getAlbumFolders() async {
    Future<void> getSubFolderPath(FileSystemEntity entity) async {
      if (entity is Directory && !FileManager.isHideFile(entity)) {
        ffEntities.add(entity);
        ffNeedRefresh.value = !ffNeedRefresh.value;

        var subFolders = await FileManager.getEntitysList(entity.path);
        for (final sub in subFolders) {
          await getSubFolderPath(sub);
        }
      }
    }

    var storages = await FileManager.getStorageList();
    if (storages.isEmpty) {
      return;
    }

    var ffRootPath = storages.first.path;

    var entities = await Directory(ffRootPath).list().toList();
    if (entities.isEmpty) {
      return;
    }

    ffEntities.clear();

    for (final entity in entities) {
      var baseName = FileManager.basename(entity);
      if (equalsIgnoreCase(baseName, 'dcim') ||
          equalsIgnoreCase(baseName, 'picture') ||
          equalsIgnoreCase(baseName, 'pictures') ||
          equalsIgnoreCase(baseName, 'video') ||
          equalsIgnoreCase(baseName, 'videos') ||
          equalsIgnoreCase(baseName, 'gallery')) {
        await getSubFolderPath(entity);
      }
    }
  }
}
