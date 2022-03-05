import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
//import 'file_manager.dart';
import '../tool_filemanager.dart';

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
  FileManagerController fileManagerControll = FileManagerController();
  List<Directory> ffDirectories = [];
  List<FileSystemEntity> ffEntities = [];
  ValueNotifier<List<FileSystemEntity>> ffAlbumFolders =
      ValueNotifier<List<FileSystemEntity>>([]);
  ValueNotifier<bool> ffRefreshSignal = ValueNotifier<bool>(false);

  List<BackupTask> ffTasks = [];

  final ffRootPath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await fileManagerControll.goToParentDirectory();
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.house),
              onPressed: () async {
                await fileManagerControll.goToHome();
              },
            ),
            const SizedBox(width: 10),
            const Text("album"),
          ],
        ),
      ),
      body:
          //FileManager(FController: fileManagerControll,FBuilder: buildEntityView,),
          //buildAlbumInFuture(context),
          buildOnRefresh(context),
      floatingActionButton: FloatingActionButton(
        tooltip: ('action_add_folder'),
        onPressed: () {
          FileManager.getStorageList().then((value) {
            refreshAlbumFolders();
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
            return FutureBuilder<List<FileSystemEntity>?>(
              future: FileManager.getEntitysList(snapStorage.data!.first.path),
              builder: (BuildContext context, AsyncSnapshot snapEntities) {
                if (snapEntities.hasData) {
                  return buildOnRefresh(context); // <<== 这里干活
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
          return Center(
            child: ListView.builder(
              itemCount: ffTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(ffTasks[index].parent),
                    //subtitle: Text(ffTasks[index].files.first.path),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void refreshAlbumFolders() async {
    ffAlbumFolders.value.clear();
    ffTasks.clear();

    if (ffDirectories.isEmpty) {
      ffDirectories = await FileManager.getStorageList();
    }

    var entities = await FileManager.getEntitysList(ffDirectories.first.path);

    for (var entity in entities) {
      if (equalsIgnoreCase(FileManager.basename(entity), 'dcim') ||
          equalsIgnoreCase(FileManager.basename(entity), 'picture') ||
          equalsIgnoreCase(FileManager.basename(entity), 'pictures')) {
        var folders = await FileManager.getEntitysList(entity.path);
        for (var folder in folders) {
          // print(folder.path.split('/').last.substring(0, 1));
          if (folder is Directory && !FileManager.isHideFile(folder)) {
            var filesLocal = await FileManager.getEntitysList(folder.path);
            ffTasks.add(BackupTask(files: filesLocal, parent: folder.path));
          }
        }
      }
    }
    ffRefreshSignal.value = !ffRefreshSignal.value;
    //print(ffTasks);
  }

  //基础视图
  Widget buildEntityView(
      BuildContext context, List<FileSystemEntity> entities) {
    List<FileSystemEntity> albumEntities = [];
    for (var entity in entities) {
      if (equalsIgnoreCase(FileManager.basename(entity), 'dcim') ||
          equalsIgnoreCase(FileManager.basename(entity), 'picture') ||
          equalsIgnoreCase(FileManager.basename(entity), 'pictures')) {
        albumEntities.add(entity);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //Listview
        Expanded(
          child: ListView.builder(
            itemCount: albumEntities.length,
            itemBuilder: (BuildContext context, int index) {
              FileSystemEntity entity = albumEntities[index];
              String baseName = FileManager.basename(entity);
              return Card(
                child: ListTile(
                  title: Text(FileManager.basename(entity)),
                  onTap: () => fileManagerControll.openDirectory(entity),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BackupTask {
  late String parent;
  late List<FileSystemEntity> files;

  BackupTask({required this.files, required this.parent});
}
