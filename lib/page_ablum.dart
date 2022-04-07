import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
import 'package:get/get.dart';
//import 'file_manager.dart';
import 'tool_filemanager.dart';
import 'page_task.dart';
import 'package:ftpconnect/ftpconnect.dart';

class PageAblum extends StatefulWidget {
  const PageAblum({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PageAblumState();
}

class PageAblumState extends State<PageAblum> {
  //相册监听器
  ValueNotifier<List<BackupTask>> ffAblumsNotify =
      ValueNotifier<List<BackupTask>>([]);

  //相册监听器Stream
  StreamController<List<BackupTask>> ffAlbumSteamController =
      StreamController<List<BackupTask>>.broadcast();

  @override
  void initState() {
    super.initState();
    getAlbumFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ggText(context, "album")),
        actions: [
          IconButton(
              onPressed: () async {
                await getAlbumFolders();
              },
              icon: const Icon(Icons.cached))
        ],
      ),
      //body: buildValueListenableBuilder(),
      body: buildStreamBuilder(),
    );
  }

  StreamBuilder<List<BackupTask>> buildStreamBuilder() {
    return StreamBuilder<List<BackupTask>>(
      stream: ffAlbumSteamController.stream,
      builder: (context, snapData) {
        if (snapData.hasData) {
          return buildListViewAlbums(snapData.data!);
        }
        if (snapData.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  ValueListenableBuilder<List<BackupTask>> buildValueListenableBuilder() {
    return ValueListenableBuilder<List<BackupTask>>(
      valueListenable: ffAblumsNotify,
      builder: (contex, snapData, _) {
        return buildListViewAlbums(snapData);
      },
    );
  }

  Widget buildListViewAlbums(List<BackupTask> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (c, i) {
        String displayName = tasks[i].path.split('/').sublist(4).join('/');
        return CheckboxListTile(
            title: Text(displayName),
            value: tasks[i].isChecked,
            onChanged: (value) {
              setState(() {
                tasks[i].isChecked = value!;
              });
            });
      },
    );
  }

  Future<void> getAlbumFolders() async {
    List<BackupTask> localTasks = [];

    Future<void> getSubFolderPath(FileSystemEntity entity) async {
      if (entity is Directory && !FileManager.isHideFile(entity)) {
        var task = BackupTask(path: entity.path);
        ffAblumsNotify.value.add(task);
        localTasks.add(task);
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

    //读取根目录的所有文件夹
    var entities = await Directory(storages.first.path).list().toList();
    if (entities.isEmpty) {
      return;
    }

    //初始化动作

    ffAblumsNotify.value.clear();

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
      }
    }
    ffAlbumSteamController.add(localTasks);
  }
}

///
class BackupTaskController extends GetxController {
  RxList<BackupTask> backupTasks = <BackupTask>[].obs;
  final FTPConnect ffFtpConnect = FTPConnect("192.168.0.139",
      user: "bigknife", pass: "Abc123456", debug: true);

  add(BackupTask task) {
    backupTasks.add(task);
  }

  Future<void> _uploadWithRetry(File fileToUpload, String remoteName) async {
    try {
      File fileToUpload = File(
          "/sdcard/DCIM/NewFolder/Sifu Screenshot 2022.02.10 - 15.30.18.93.png");
      print('Uploading ...');
      await ffFtpConnect.connect();
      await ffFtpConnect.socket.sendCommand("OPTS UTF8 ON");

      //await ffFtpConnect.changeDirectory('downloads');
      bool res = await ffFtpConnect.uploadFileWithRetry(fileToUpload,
          pRetryCount: 2, pRemoteName: '/downloads/1.png');
      print('file uploaded: ' + (res ? 'SUCCESSFULLY' : 'FAILED'));
      await ffFtpConnect.disconnect();
    } catch (e) {
      print('Downloading FAILED: ${e.toString()}');
    }
  }

  ///
  /// 测试上传
  ///
  updateToServer(index) {
    _updateToServer(task: backupTasks[index]);
  }

  _updateToServer({required BackupTask task}) async {
    try {
      task.getEntity();
      await ffFtpConnect.connect();
      await ffFtpConnect.socket.sendCommand("OPTS UTF8 ON");
      await ffFtpConnect.changeDirectory('/downloads/my_ftp_app/');

      for (var flle in task.files) {
        var baseName = FileManager.basename(flle);
        if (await ffFtpConnect.existFile(baseName)) {
          debugPrint('远端文件已存在');
          continue;
        }
        if (flle is File == false) {
          debugPrint('不是File');
          continue;
        }
        debugPrint('开始上传$baseName');
        File fileToUpload = flle as File;
        bool res = await ffFtpConnect
            .uploadFileWithRetry(fileToUpload, pRetryCount: 2, onProgress:
                (double progressInPercent, int totalReceived, int fileSize) {
          debugPrint("$progressInPercent");
        });
        debugPrint('file uploaded: ' + (res ? 'SUCCESSFULLY' : 'FAILED'));
      }
      debugPrint('上传完毕');
    } catch (e) {
      debugPrint('Downloading FAILED: ${e.toString()}');
    } finally {
      await ffFtpConnect.disconnect();
    }
  }
}

class AlbumViewControll {}
