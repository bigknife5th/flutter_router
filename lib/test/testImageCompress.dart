import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TestApp());
  }
}

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  State<TestApp> createState() => TestAppState();
}

class TestAppState extends State<TestApp> {
  ValueNotifier<Image> ffImage = ValueNotifier<Image>(Image.asset(
    'images/picture.png',
    height: 128,
    width: 128,
  ));

  @override
  Widget build(BuildContext context) {
    var path =
        '/storage/emulated/0/Pictures/灰白/pexels-alexander-kozlov-11148698.jpg';
    File file = File(path);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(
            file,
            width: 128,
            height: 128,
          ),
          ElevatedButton(
            onPressed: () async {
              ffImage.value = await testCompressAndGetFile(path);
            },
            child: const Text('test'),
          ),
          ElevatedButton(
            onPressed: () async {
              List<Directory>? androidDir =
                  await getExternalStorageDirectories();
              String androidPath = androidDir![0].path;
              print(androidDir);
            },
            child: const Text('获取Storage'),
          ),
          ValueListenableBuilder<Image>(
            valueListenable: ffImage,
            builder: (context, snapdata, _) {
              return snapdata;
            },
          )
        ],
      ),
    );
  }

  ///
  ///
  ///
  ///
  Future<Image> testCompressAndGetFile(String path) async {
    // //String path = '/storage/emulated/0/Pictures/Gallery/owner/小鱼儿';
    // List<FileSystemEntity> entityList = await Directory(path)
    //     .list(recursive: false, followLinks: false)
    //     .toList();
    var result = await FlutterImageCompress.compressWithFile(path,
        minWidth: 128, minHeight: 128, quality: 30);
    if (result != null) {
      Image image = Image.memory(
        result,
        height: 128,
        width: 128,
      );
      File f = File(path);
      print('${f.lengthSync()} 压缩：' + result.length.toString());
      return image;
    }
    return Image.asset(
      'images/picture.png',
      height: 128,
      width: 128,
    );
  }
}
