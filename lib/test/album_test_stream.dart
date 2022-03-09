// 测试相册页

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
//import 'file_manager.dart';
import '../tool_filemanager.dart';
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
  StreamController<List<BackupTask>> ffAlbumFolders =
      StreamController<List<BackupTask>>.broadcast();

  //备份任务的列表
  List<BackupTask> ffTasks = [];

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
      ),
      body: //buildAlbumInFuture(context),
          buildByStream(context),
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

  Widget buildFileView(int index) {
    var album = ffTasks[index];
    //默认返回一个横排Row，包含4个64x64的默认图片

    return SizedBox(
      height: 120,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(album.path),
            fb(album),
          ],
        ),
      ),
    );
  }

  Widget buildByStream(BuildContext context) {
    return StreamBuilder<List<BackupTask>>(
      initialData: const [],
      stream: ffAlbumFolders.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildByStreamChild(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget buildByStreamChild(List<BackupTask> snapEntities) {
    return ListView.builder(
      itemCount: snapEntities.length,
      itemBuilder: (BuildContext context, int index) {
        return buildFileView(index);
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

  Future<void> getAlbumFolders() async {
    // var test = Directory('/storage/emulated/0/DCIM/').listSync(recursive: true);
    // print(test.length);

    var storages = await FileManager.getStorageList();
    if (storages.isEmpty) {
      return;
    }

    ffRootPath = storages.first.path;

    var entities = await Directory(ffRootPath).list().toList();
    if (entities.isEmpty) {
      return;
    }

    //ffEntities.add(entities);
    //ffEntities.add([]);
    ffTasks.clear();

    for (final entity in entities) {
      var baseName = FileManager.basename(entity);
      if (equalsIgnoreCase(baseName, 'dcim') ||
          equalsIgnoreCase(baseName, 'picture') ||
          equalsIgnoreCase(baseName, 'pictures') ||
          equalsIgnoreCase(baseName, 'video') ||
          equalsIgnoreCase(baseName, 'videos') ||
          equalsIgnoreCase(baseName, 'gallery')) {
        //await getSubFolderPath(entity);
        var subEntities =
            await Directory(entity.path).list(recursive: true).toList();
        print(subEntities);
      }
    }
    print("返回了");
    ffAlbumFolders.add(ffTasks);
    //ffRefreshSignal.value = !ffRefreshSignal.value;
  }
}

class BackupTask {
  late String path;
  List<FileSystemEntity> files = [];
  var streamController = StreamController<List<FileSystemEntity>>.broadcast();

  BackupTask({required this.path});

  Future<void> getEntity() async {
    files.clear();
    files = await FileManager.getEntitysList(path);
    streamController.add(files);
  }
}
