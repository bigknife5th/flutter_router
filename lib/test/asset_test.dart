import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: SizedBox(
            height: 100,
            width: 100,
            child: Image.asset("images/picture.png") //路径要写全
            ),
      ),
    );
  }
}
