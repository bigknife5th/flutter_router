import 'dart:io';

import 'package:flutter/material.dart';
import '../file_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<FileSystemEntity> ffEntities = [];
  List<Directory> ffDirectories = [];

  @override
  void initState() {
    //refreshAlbumFolders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: ffEntities.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(ffEntities[index].path);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await refreshAlbumFolders();
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> refreshAlbumFolders() async {
    if (ffEntities.isNotEmpty) {
      ffEntities.clear();
    }
    if (ffDirectories.isEmpty) {
      ffDirectories = await getStorageList();
    }
    ffEntities = await getEntitysList(ffDirectories.first.path);
    //setState(() {});
    print(ffEntities);
  }
}
