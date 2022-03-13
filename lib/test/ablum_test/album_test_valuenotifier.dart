// 测试相册页

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
  //pub.dev的file_manager扩展用到的controller
  FileManagerController fileManagerControll = FileManagerController();

  //全局的Storage列表
  List<Directory> ffStorages = [];

  //全局的文件列表
  List<FileSystemEntity> ffEntities = [];

  //全局的相册列表
  ValueNotifier<List<FileSystemEntity>> ffAlbumFolders =
      ValueNotifier<List<FileSystemEntity>>([]);

  //备份任务的列表
  List<BackupTask> ffTasks = [];

  //刷新UI的信号
  ValueNotifier<bool> ffRefreshSignal = ValueNotifier<bool>(false);

  //另一种信号方式
  ValueNotifier<int> ffTaskCount = ValueNotifier<int>(0);

  String ffRootPath = '';

  @override
  void initState() {
    checkPermission();
    //refreshAlbumFolders();
    //getAlbumFolders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("照片库"),
      ),
      body: //buildAlbumInFuture(context),
          buildOnRefresh(context),
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

  Widget buildAlbumInFuture(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: FileManager.getStorageList(),
      builder: (BuildContext context, AsyncSnapshot snapStorage) {
        if (snapStorage.connectionState == ConnectionState.done) {
          if (snapStorage.hasData) {
            return FutureBuilder(
              future: getAlbumFolders(),
              builder: (BuildContext context, AsyncSnapshot snapEntities) {
                if (snapEntities.hasData) {
                  //创建主列表
                  return buildOnRefresh(context);
                } else if (snapEntities.hasError) {
                  return const Icon(Icons.error_outline);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else if (snapStorage.hasError) {
            return const Icon(Icons.error);
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  ValueListenableBuilder<bool> buildOnRefresh(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ffRefreshSignal,
      builder: (context, snapFolders, _) {
        if (ffTasks.isNotEmpty) {
          //return Center(child: buildListView());
          return buildGridView();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  ListView buildListView() {
    return ListView.builder(
      shrinkWrap: false,
      itemCount: ffTasks.length,
      itemBuilder: (BuildContext context, int index) {
        //主要UI
        return buildFileView(index);
      },
    );
  }

  GridView buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, //每行三列
        childAspectRatio: 3 / 1,
        // mainAxisSpacing: 5,
        // crossAxisSpacing: 5,
        // childAspectRatio: 1.0, //显示区域宽高相等
      ),
      itemCount: ffTasks.length,
      itemBuilder: (context, index) {
        return ValueListenableBuilder<bool>(
          valueListenable: ffRefreshSignal,
          builder: (context, snapshot, _) {
            return buildFileView(index);
          },
        );
      },
    );
  }

  Widget buildFileView(int index) {
    var album = ffTasks[index];
    Image defaultImage = Image.asset(
      'images/picture.png',
      height: 64,
      width: 64,
    );
    List<Widget> previewImages = [defaultImage];
    Row resultRow = Row(
      children: previewImages,
    );
    //默认返回一个横排Row，包含4个64x64的默认图片

    FutureBuilder fb = FutureBuilder<List<FileSystemEntity>?>(
      future: album.getEntity(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                previewImages.add(
                  Image.file(
                    File(photos[i].path),
                    width: 64.0,
                    height: 64.0,
                  ),
                );
              }
            }
            //print("预览图长度：${previewImages.length}");
            return Row(
              children: previewImages,
            );
            return Image.asset('images/picture.png');
          }
        } else if (snapshot.hasError) {
          return Row(children: const [Icon(Icons.error_outline)]);
        } else {
          return Row();
        }
        return Row();
      },
    );

    return SizedBox(
      height: 100,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(album.parent),
            fb,
          ],
        ),
      ),
    );
  }

  Future<void> getSubFolderPath(FileSystemEntity entity) async {
    if (entity is Directory && !FileManager.isHideFile(entity)) {
      print('subpath:' + entity.path);
      ffTasks.add(BackupTask(parent: entity.path));
      ffTaskCount.value = ffTasks.length;
      var subFolders = await FileManager.getEntitysList(entity.path);
      for (var sub in subFolders) {
        await getSubFolderPath(sub);
      }
    }
  }

  Future<void> getAlbumFolders() async {
    var storages = await FileManager.getStorageList();
    if (storages.isEmpty) {
      return;
    }

    ffRootPath = storages.first.path;

    ffEntities = await FileManager.getEntitysList(storages.first.path);
    if (ffEntities.isEmpty) {
      return;
    }

    ffTasks.clear();

    for (var entity in ffEntities) {
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
    print("返回了");
    ffRefreshSignal.value = !ffRefreshSignal.value;
  }

  void refreshAlbumFolders() async {
    ffAlbumFolders.value.clear();
    ffTasks.clear();

    if (ffStorages.isEmpty) {
      ffStorages = await FileManager.getStorageList();
    }

    var entities = await FileManager.getEntitysList(ffStorages.first.path);

    for (var entity in entities) {
      var baseName = FileManager.basename(entity);
      if (equalsIgnoreCase(baseName, 'dcim') ||
          equalsIgnoreCase(baseName, 'picture') ||
          equalsIgnoreCase(baseName, 'pictures') ||
          equalsIgnoreCase(baseName, 'video') ||
          equalsIgnoreCase(baseName, 'videos') ||
          equalsIgnoreCase(baseName, 'gallery')) {
        var folders = await FileManager.getEntitysList(entity.path);
        for (var folder in folders) {
          // print(folder.path.split('/').last.substring(0, 1));
          if (folder is Directory && !FileManager.isHideFile(folder)) {
            //var filesLocal = await FileManager.getEntitysList(folder.path);
            ffTasks.add(BackupTask(parent: folder.path));
          }
        }
      }
    }
    ffRefreshSignal.value = !ffRefreshSignal.value;
    //print(ffTasks);
  }
}

class BackupTask {
  late String parent;
  List<FileSystemEntity> files = [];

  BackupTask({required this.parent});

  Future<List<FileSystemEntity>> getEntity() async {
    files.clear();
    files = await FileManager.getEntitysList(parent);
    return files;
  }
}
