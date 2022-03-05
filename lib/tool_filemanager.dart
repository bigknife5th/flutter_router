// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

bool equalsIgnoreCase(String string1, String string2) {
  return string1.toLowerCase() == string2.toLowerCase();
}

Future<bool> checkPermission() async {
  // 检查是否已有读写内存的权限
  bool status = await Permission.storage.isGranted;
  //判断如果还没拥有读写权限就申请获取权限
  if (!status) {
    return await Permission.storage.request().isGranted;
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PageDirs());
  }
}

enum SortBy { name, type, date, size }

typedef _Builder = Widget Function(
    BuildContext context, List<FileSystemEntity> entities);

class FileManager extends StatefulWidget {
  const FileManager(
      {Key? key, required this.FController, required this.FBuilder})
      : super(key: key);

  // M
  // final ValueNotifier<String> FPath = ValueNotifier<String>('');
  // final ValueNotifier<SortBy> FSort = ValueNotifier<SortBy>(SortBy.name);
  // final List<FileSystemEntity> FEntities = [];
  final FileManagerController FController;
  final _Builder FBuilder;

  // V
  Widget build_entity_view(List<FileSystemEntity> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        FileSystemEntity entity = list[index];
        return Card(
          child: ListTile(
            leading: (entity is File)
                ? const Icon(Icons.feed_outlined)
                : const Icon(Icons.folder),
            title: Text(FileManager.basename(entity)),
            onTap: () {
              if (entity is Directory) {
                //FController.FPathNotify.value = entity.path;
                FController.openDirectory(entity);
              }
            },
          ),
        );
      },
    );
  }

  @override
  _FileManagerState createState() => _FileManagerState();

  // 工具
  static Future<List<Directory>> getStorageList() async {
    if (Platform.isAndroid) {
      List<Directory> storages = (await getExternalStorageDirectories())!;
      storages = storages.map((Directory e) {
        final List<String> splitedPath = e.path.split("/");
        return Directory(splitedPath
            .sublist(
                0, splitedPath.indexWhere((element) => element == "Android"))
            .join("/"));
      }).toList();
      return storages;
    }

    return [];
  }

  static Future<List<FileSystemEntity>> getEntitysList(String path) async {
    if (path == '') return [];
    try {
      final List<FileSystemEntity> list = await Directory(path).list().toList();
      return list;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
    //print(list);
  }

  static String basename(dynamic entity, [bool showFileExtension = false]) {
    if (entity is Directory) {
      return entity.path.split('/').last;
    } else if (entity is File) {
      return (showFileExtension)
          ? entity.path.split('/').last
          : entity.path.split('/').last.split('.').first;
    } else {
      print("Unknow file type");
      return "";
    }
  }

  static bool isHideFile(dynamic entity) {
    return (entity.path.split('/').last.substring(0, 1) == '.');
  }
}

class _FileManagerState extends State<FileManager> {
  // C

  // V
  @override
  void dispose() {
    widget.FController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: FileManager.getStorageList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          widget.FController.FPathNotify.value = snapshot.data!.first.path;
          return build_body(context); // <== 页面
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text(snapshot.error.toString());
        } else {
          return const Text('Loading...');
        }
      },
    );
  }

  Widget build_body(BuildContext context) {
    return build_path_listener();
  }

  ValueListenableBuilder<String> build_path_listener() {
    return ValueListenableBuilder<String>(
      valueListenable: widget.FController.FPathNotify,
      builder: (context, snapPath, _) {
        return build_path_sort_listener(snapPath);
      },
    );
  }

  ValueListenableBuilder<SortBy> build_path_sort_listener(String snapPath) {
    return ValueListenableBuilder<SortBy>(
      valueListenable: widget.FController.FSortNotify,
      builder: (context, snapSortBy, _) {
        return build_entity(snapPath);
      },
    );
  }

  FutureBuilder<List<FileSystemEntity>> build_entity(String snapPath) {
    return FutureBuilder(
      future: FileManager.getEntitysList(snapPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return widget.FBuilder(context, snapshot.data!);
          } else if (snapshot.hasError) {
            return const Icon(Icons.error);
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class FileManagerController {
  final ValueNotifier<String> FPathNotify = ValueNotifier<String>('');
  final ValueNotifier<String> FTitleNotify = ValueNotifier<String>('');
  final ValueNotifier<SortBy> FSortNotify = ValueNotifier<SortBy>(SortBy.name);

  void dispose() {
    FPathNotify.dispose();
    FTitleNotify.dispose();
    FSortNotify.dispose();
  }

  Future<bool> isRootDirectory() async {
    final List<Directory> storageList = (await FileManager.getStorageList());
    return (storageList
        .where((element) => element.path == Directory(FPathNotify.value).path)
        .isNotEmpty);
  }

  Future<void> goToParentDirectory() async {
    //if (!(await isRootDirectory())) {
    openDirectory(Directory(FPathNotify.value).parent);
    //}
  }

  Future<void> goToHome() async {
    final List<Directory> storageList = (await FileManager.getStorageList());
    openDirectory(storageList.first);
  }

  void openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      FPathNotify.value = entity.path;
    } else {
      throw ("Not Directory.");
    }
  }
}

class PageDirs extends StatefulWidget {
  const PageDirs({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageDirsState();
}

class _PageDirsState extends State<PageDirs> {
  FileManagerController FController = FileManagerController();
  ScrollController FScrollController = ScrollController();

  //基础视图
  Widget buildEntityView(
      BuildContext context, List<FileSystemEntity> entities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //地址栏
        ValueListenableBuilder<String>(
          valueListenable: FController.FPathNotify,
          builder: buildFloderNavigator,
        ),
        //Listview
        Expanded(
          child: ListView.builder(
            itemCount: entities.length,
            itemBuilder: (BuildContext context, int index) {
              FileSystemEntity entity = entities[index];
              return Card(
                child: ListTile(
                  leading: (entity is File)
                      ? const Icon(Icons.feed_outlined)
                      : const Icon(Icons.folder),
                  title: Text(FileManager.basename(entity)),
                  onTap: () {
                    if (entity is Directory) {
                      FController.openDirectory(entity);
                      if (FScrollController.hasClients) {
                        FScrollController.animateTo(
                            FScrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await FController.goToParentDirectory();
                }),
            const SizedBox(width: 10),
            IconButton(
                icon: const Icon(Icons.house),
                onPressed: () async {
                  await FController.goToHome();
                }),
          ]),
        ),
        body: FileManager(FController: FController, FBuilder: buildEntityView),
      ),
      onWillPop: () async {
        FController.FPathNotify.value =
            Directory(FController.FPathNotify.value).parent.path;
        return false;
      },
    );
  }

  // TextSpan(
  //   text: splitedPath[i],
  //   style: TextStyle(fontSize: 20, backgroundColor: Colors.blue[50]),
  //   semanticsLabel: splitedPath[i],
  //   recognizer: TapGestureRecognizer()
  //     ..onTap = () {
  //       debugPrint(splitedPath[i]);
  //     },
  // ),
  Widget buildFloderNavigator(context, snapPath, _) {
    List<String> splitedPath = snapPath.split("/");
    List<String> realPathList = [];
    for (var i = 0; i < splitedPath.length; i++) {
      var realpath = splitedPath
          .sublist(0, splitedPath.indexWhere((k) => k == splitedPath[i]) + 1)
          .join("/");
      realPathList.add(realpath);
      //debugPrint(splitedPath[i] + ' $i = $realpath');
    }
    //print(textList);

    var result = SizedBox(
      height: 30,
      child: ListView.builder(
        controller: FScrollController,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: splitedPath.length,
        itemBuilder: (BuildContext context, int index) {
          if (splitedPath[index] != '') {
            return Row(
              children: [
                GestureDetector(
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    // shape: const RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    // ),
                    child: Text(
                      splitedPath[index],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        //backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ),
                  onTap: () {
                    debugPrint('click ' + realPathList[index]);
                    FController.FPathNotify.value = realPathList[index];
                  },
                ),
                const Text(' / ',
                    style: TextStyle(fontWeight: FontWeight.normal)),
              ],
            );
          } else {
            return const Text('');
          }
        },
      ),
    );

    //FScrollController.jumpTo(FScrollController.position.maxScrollExtent);
    if (FScrollController.hasClients) {
      FScrollController.animateTo(FScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    return result;
  }
}
