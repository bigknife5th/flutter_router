// 测试相册页

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'file_manager.dart';
import '../../tool_filemanager.dart';

///
/// 主界面
///
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
  final BackupTaskController _controller = Get.put(BackupTaskController());
  String ffRootPath = '';

  @override
  void initState() {
    super.initState();
    checkPermission();
    getAlbumFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("照片库"),
        actions: [
          IconButton(
              onPressed: () {
                FileManager.getStorageList().then((value) {
                  getAlbumFolders();
                });
              },
              icon: const Icon(Icons.cached))
        ],
      ),
      body: Obx(() => buildListView()),
    );
  }

  buildListView() {
    return ListView.builder(
      itemCount: _controller.backupTasks.length,
      itemBuilder: (context, index) {
        return SizedBox(
          //height: 110,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_controller.backupTasks[index].path),
                const SizedBox(
                  height: 3,
                ),
                //fb(_controller.backupTasks[index]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget fb(BackupTask backTask) {
    var defaultImage = Image.asset(
      'images/picture.png',
      height: 64,
      width: 64,
    );
    var previewImages = [
      defaultImage,
      defaultImage,
      defaultImage,
      defaultImage
    ];

    //取entities
    var photos = backTask.files;
    //如果数据非空
    if (photos.isNotEmpty) {
      //读取前4张图片展示
      previewImages.clear();
      for (var i = 0; i < 4; i++) {
        //防止有些相册不到4张图而越界
        if (i >= photos.length) break;
        //取扩展名
        var ext = photos[i].path.split('/').last.split('.').last;
        //print(ext);
        if (ext == 'png' || ext == 'jpg' || ext == 'gif') {
          var image = Image.file(
            File(photos[i].path),
            width: 64.0,
            height: 64.0,
          );
          previewImages.add(image);
        }
      }

      return Row(
        children: previewImages,
      );
    }
    return Row(
      children: previewImages,
    );
  }

  Future<void> getAlbumFolders() async {
    Future<void> getSubFolderPath(FileSystemEntity entity) async {
      if (entity is Directory && !FileManager.isHideFile(entity)) {
        debugPrint('subpath:' + entity.path);

        /// 在这里add到RxList里了
        _controller.add(BackupTask(path: entity.path));

        ///
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

    _controller.backupTasks.clear();

    for (final entity in entities) {
      var baseName = FileManager.basename(entity);
      if (equalsIgnoreCase(baseName, 'dcim') ||
          equalsIgnoreCase(baseName, 'picture') ||
          equalsIgnoreCase(baseName, 'pictures') ||
          equalsIgnoreCase(baseName, 'video') ||
          equalsIgnoreCase(baseName, 'videos') ||
          equalsIgnoreCase(baseName, 'gallery')) {
        await getSubFolderPath(entity);
        // debugPrint(subEntities.toString());
      }
    }
    debugPrint("返回了");
  }
}

///
/// 控制器
///
class BackupTaskController extends GetxController {
  RxList<BackupTask> backupTasks = <BackupTask>[].obs;

  add(BackupTask task) {
    backupTasks.add(task);
  }
}

///
/// 数据结构
///
class BackupTask {
  late String path;
  List<FileSystemEntity> files = <FileSystemEntity>[];

  BackupTask({required this.path}) {
    //getEntity();
  }

  getEntity() async {
    files.clear();
    files = await FileManager.getEntitysList(path);
  }
}
