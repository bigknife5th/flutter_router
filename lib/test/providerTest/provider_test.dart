import 'package:flutter/material.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Container());
  }
}

//测试用的结构体，其实就是个全局变量
class TestData {
  int data = 0;
  TestData(data);
}

//TestData作为全局变量的包装
class TestProvider extends InheritedWidget {
  //数据
  final TestProvider testData;

  //点击+号的方法
  final Function() increment;

  //点击-号的方法
  final Function() reduce;

  const TestProvider({
    Key? key,
    required this.testData,
    required this.increment,
    required this.reduce,
    required Widget child,
  }) : super(key: key, child: child);

  static TestProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: TestProvider);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(TestProvider oldWidget) {
    return testData != oldWidget.testData;
  }
}

//把provider的数据放在这个类里，把操作方法放到另一个类里，改变数据，看第一个类会不会刷新
class UIFirst extends StatefulWidget {
  const UIFirst({Key? key}) : super(key: key);

  @override
  State<UIFirst> createState() => _UIFirstState();
}

class _UIFirstState extends State<UIFirst> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//第二个UI，把+按钮放里面
class UISecond extends StatefulWidget {
  const UISecond({Key? key}) : super(key: key);

  @override
  State<UISecond> createState() => _UISecondState();
}

class _UISecondState extends State<UISecond> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: const Text("+"));
  }
}
