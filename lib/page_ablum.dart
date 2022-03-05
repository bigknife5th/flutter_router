import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
//import 'file_manager.dart';
import 'tool_filemanager.dart';

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
            Text(
              ggText(context, "album"),
            ),
          ],
        ),
      ),
      body:
          //FileManager(FController: fileManagerControll,FBuilder: buildEntityView,),
          buildAlbumInFuture(context),
      floatingActionButton: FloatingActionButton(
        tooltip: ggText(context, 'action_add_folder'),
        onPressed: () {
          FileManager.getStorageList().then((value) {
            ffAlbumFolders.value.clear();
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
                  return widgetToBuild(); // <<== 这里干活
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

  ValueListenableBuilder<List<FileSystemEntity>> widgetToBuild() {
    return ValueListenableBuilder<List<FileSystemEntity>>(
      valueListenable: ffAlbumFolders,
      builder: (context, snapFolders, _) {
        if (ffAlbumFolders.value.isNotEmpty) {
          return Center(
            child: ListView.builder(
              itemCount: snapFolders.length,
              itemBuilder: (BuildContext context, int index) {
                FileSystemEntity entity = snapFolders[index];
                return Card(
                  child: ListTile(
                    title: Text(FileManager.basename(entity)),
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
    if (ffDirectories.isEmpty) {
      ffDirectories = await FileManager.getStorageList();
    }

    var entities = await FileManager.getEntitysList(ffDirectories.first.path);

    for (var entity in entities) {
      if (equalsIgnoreCase(FileManager.basename(entity), 'dcim') ||
          equalsIgnoreCase(FileManager.basename(entity), 'picture') ||
          equalsIgnoreCase(FileManager.basename(entity), 'pictures')) {
        var folders = await FileManager.getEntitysList(entity.path);
        for (var f in folders) {
          ffAlbumFolders.value.add(f);
        }
      }
    }
    print(ffAlbumFolders.value);
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
