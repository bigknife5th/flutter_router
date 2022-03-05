import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum SortBy { name, type, date, size }

typedef _Builder = Widget Function(
    BuildContext context, List<FileSystemEntity> entities);

// 工具
Future<List<Directory>> getStorageList() async {
  if (Platform.isAndroid) {
    try {
      List<Directory> storages = (await getExternalStorageDirectories())!;
      storages = storages.map((Directory d) {
        List<String> splitedPath = d.path.split("/");
        return Directory(splitedPath
            .sublist(0, splitedPath.indexWhere((l) => l == "Android"))
            .join("/"));
      }).toList();
      return storages;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  //其他系统
  return [];
}

Future<List<FileSystemEntity>> getEntitysList(String path) async {
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

String basename(dynamic entity, [bool showFileExtension = true]) {
  if (entity is Directory) {
    return entity.path.split('/').last;
  } else if (entity is File) {
    return (showFileExtension)
        ? entity.path.split('/').last.split('.').first
        : entity.path.split('/').last;
  } else {
    debugPrint("Unknow file type");
    return "";
  }
}

Future<bool> isRootDirectory(String path) async {
  final List<Directory> storageList = (await getStorageList());
  return (storageList.where((l) => l.path == Directory(path).path).isNotEmpty);
}

Future<void> goToParentDirectory(ValueNotifier<String> dirNotify) async {
  //if (!(await isRootDirectory())) {
  openDirectory(dirNotify, Directory(dirNotify.value).parent);
  //}
}

Future<void> goToHome(ValueNotifier<String> dirNotify) async {
  final List<Directory> storageList = (await getStorageList());
  openDirectory(dirNotify, storageList.first);
}

void openDirectory(ValueNotifier<String> dirNotify, FileSystemEntity entity) {
  if (entity is Directory) {
    dirNotify.value = entity.path;
  } else {
    throw ("Not Directory.");
  }
}
