import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import "package:convert/convert.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FTPConnect ffFtpConnect = FTPConnect("192.168.0.139",
      user: "shawn", pass: "Fasmot311", debug: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                print("test");
                await _uploadWithRetry();
              },
              child: const Text('test'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("test");
                await test();
              },
              child: const Text('test2'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadWithRetry() async {
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

  Future<void> test() async {
    try {
      File fileToUpload = File("/sdcard/Pictures/壁纸/bizhi (1).jpg");
      print('Uploading ...');
      await ffFtpConnect.connect();
      String remoteName = '/downloads/1.png';
      bool exist = await ffFtpConnect.existFile(remoteName);
      if (!exist) {
        bool res = await ffFtpConnect.uploadFileWithRetry(fileToUpload,
            pRetryCount: 2, pRemoteName: '/downloads/1.png');
        print('file uploaded: ' + (res ? 'SUCCESSFULLY' : 'FAILED'));
      }
      await ffFtpConnect.disconnect();
    } catch (e) {
      print('Downloading FAILED: ${e.toString()}');
    }
  }

  Future<void> test2() async {
    try {
      await ffFtpConnect.connect();
      await ffFtpConnect.socket.sendCommand("OPTS UTF8 ON");
      await ffFtpConnect.changeDirectory('downloads/中文目录');
      String currentPath = await ffFtpConnect.currentDirectory();
      print(currentPath);
    } catch (e) {
      print('Downloading FAILED: ${e.toString()}');
    } finally {
      await ffFtpConnect.disconnect();
    }
  }
}
