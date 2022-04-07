///
/// 相册读取Stream版

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../tool_filemanager.dart';
import 'package:permission_handler/permission_handler.dart';

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
  State<StatefulWidget> createState() => PageAblumState();
}

class PageAblumState extends State<PageAblum> {
  //全局的相册列表
  StreamController<List<BackupTask>> ffAlbumReadController =
      StreamController<List<BackupTask>>.broadcast();
  //另一个订阅
  late StreamSubscription _streamSubscription;
  //备份任务的列表
  List<BackupTask> ffTasks = [];
  //根目录
  String ffRootPath = '';

  @override
  void initState() {
    super.initState();
    //检查权限
    checkPermission();
    //读取所有相册
    //getAlbumFolders();
    //订阅steam变化
    // _streamSubscription = ffAlbumReadController.stream.listen((event) {
    //   //print("添加了 ${event.path}");
    //   ffTasks.add(event);
    // });
  }

  @override
  void dispose() {
    ffAlbumReadController.close();
    super.dispose();
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
      body: StreamBuilder<List<BackupTask>>(
        stream: ffAlbumReadController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //ffTasks.add(snapshot.data!);
            return buildByStreamChild(ffTasks);
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: ('action_add_folder'),
        onPressed: () {
          FileManager.getStorageList().then((value) {
            //refreshAlbumFolders();
            getAlbumFolders();
          });
        },
        elevation: 7.0,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget fb(BackupTask backTask) {
    var defaultImage = Image.asset(
      'images/picture.png',
      height: 64,
      width: 64,
    );
    var previewImages = [defaultImage];
    var resultRow = Row(
      children: previewImages,
    );
    //var _controller = StreamController<List<FileSystemEntity>>.broadcast();
    //var _entities = backTask.getEntity();

    //backTask.getEntity();
    return StreamBuilder<List<FileSystemEntity>?>(
      initialData: const [],
      stream: backTask.streamController.stream,
      builder: (context, snapshot) {
        //如果future返回了数据
        var photos = snapshot.data!;
        //如果数据非空
        if (photos.isNotEmpty) {
          //读取前4张图片展示
          previewImages.clear();
          for (var i = 0; i < 4; i++) {
            if (i >= photos.length) break;
            var ext = photos[i].path.split('/').last.split('.').last;
            //print(ext);
            if (ext == 'png' || ext == 'jpg' || ext == 'gif') {
              Image image = Image.file(
                File(photos[i].path),
                width: 64.0,
                height: 64.0,
              );
              previewImages.add(image);
            }
          }
          //print("预览图长度：${previewImages.length}");
          return Row(
            children: previewImages,
          );
          return Image.asset('images/picture.png');
        }
        return Row();
      },
    );
  }

  Widget buildFileView(List<BackupTask> albums, int index) {
    var album = albums[index];
    var displayName = albums[index].path.split('/').sublist(4).join('/');

    return CheckboxListTile(
      title: Text(displayName),
      value: true,
      onChanged: (bool? value) {
        value = !value!;
      },
    );
  }

  Widget buildByStreamChild(List<BackupTask> snapEntities) {
    return ListView.builder(
      itemCount: snapEntities.length,
      itemExtent: 120.0,
      itemBuilder: (BuildContext context, int index) {
        return buildFileView(snapEntities, index);
      },
    );
  }

  Future<void> getSubFolderPath(FileSystemEntity entity) async {
    if (entity is Directory && !FileManager.isHideFile(entity)) {
      print('subpath:' + entity.path);
      ffTasks.add(BackupTask(path: entity.path));
      //ffTasks.last.getEntity();
      //ffTaskCount.value = ffTasks.length;
      var subFolders = await FileManager.getEntitysList(entity.path);
      for (final sub in subFolders) {
        await getSubFolderPath(sub);
      }
    }
  }

  ///
  /// 递归读取相册
  ///
  Future<void> getAlbumFolders() async {
    Future<void> getSubFolderPath(FileSystemEntity entity) async {
      if (entity is Directory && !FileManager.isHideFile(entity)) {
        // 在这里add到RxList里了
        ffTasks.add(BackupTask(path: entity.path));
        var subFolders = await FileManager.getEntitysList(entity.path);
        for (final sub in subFolders) {
          await getSubFolderPath(sub);
        }
      }
    }

    //获取根目录
    var storages = await FileManager.getStorageList();
    if (storages.isEmpty) {
      return;
    }
    ffRootPath = storages.first.path;

    //读取根目录的所有文件夹
    var entities = await Directory(ffRootPath).list().toList();
    if (entities.isEmpty) {
      return;
    }

    //初始化动作
    ffTasks.clear();

    //
    for (final entity in entities) {
      var baseName = FileManager.basename(entity);
      if (equalsIgnoreCase(baseName, 'dcim') ||
          equalsIgnoreCase(baseName, 'picture') ||
          equalsIgnoreCase(baseName, 'pictures') ||
          equalsIgnoreCase(baseName, 'video') ||
          equalsIgnoreCase(baseName, 'videos') ||
          equalsIgnoreCase(baseName, 'gallery')) {
        //递归获取
        await getSubFolderPath(entity);
        // var subEntities =
        //     await Directory(entity.path).list(recursive: true).toList();
        // for (var m in subEntities) {
        //   if (m is Directory) {
        //     var task = BackupTask(path: m.path);
        //     debugPrint(task.path);
        //     ffTasks.add(task);
        //   }
      }
    }

    ffAlbumReadController.add(ffTasks);
    debugPrint("返回了");
  }
}

class BackupTask {
  //相册路径
  late String path;
  //路径下的所有文件
  List<FileSystemEntity> files = [];
  //读取文件用到的controller
  var streamController = StreamController<List<FileSystemEntity>>.broadcast();

  //构造函数
  BackupTask({required this.path});

  //读取路径下的所有文件
  Future<void> getEntity() async {
    files.clear();
    files = await FileManager.getEntitysList(path);
    streamController.add(files);
  }
}

class AlbumViewController {}
