import 'package:flutter/material.dart';

main() {
  runApp(const MyApp());
}

class InheritedTestModel {
  final int count;
  const InheritedTestModel(this.count);
}

class InheritedContext extends InheritedWidget {
  //数据
  final InheritedTestModel inheritedTestModel;

  //点击+号的方法
  final Function() increment;

  //点击-号的方法
  final Function() reduce;

  const InheritedContext({
    Key? key,
    required this.inheritedTestModel,
    required this.increment,
    required this.reduce,
    required Widget child,
  }) : super(key: key, child: child);

  static InheritedContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: InheritedContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(InheritedContext oldWidget) {
    return inheritedTestModel != oldWidget.inheritedTestModel;
  }
}

class TestWidgetA extends StatelessWidget {
  const TestWidgetA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inheritedContext = InheritedContext.of(context);

    final inheritedTestModel = inheritedContext!.inheritedTestModel;

    print('TestWidgetA 中count的值:  ${inheritedTestModel.count}');
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
      child: ElevatedButton(
          child: const Text('+'), onPressed: inheritedContext.increment),
    );
  }
}

class TestWidgetB extends StatelessWidget {
  const TestWidgetB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inheritedContext = InheritedContext.of(context);

    final inheritedTestModel = inheritedContext!.inheritedTestModel;

    print('TestWidgetB 中count的值:  ${inheritedTestModel.count}');

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
      child: Text(
        '当前count:${inheritedTestModel.count}',
        style: const TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class TestWidgetC extends StatelessWidget {
  const TestWidgetC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inheritedContext = InheritedContext.of(context);

    final inheritedTestModel = inheritedContext!.inheritedTestModel;

    print('TestWidgetC 中count的值:  ${inheritedTestModel.count}');

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
      child: ElevatedButton(
          child: const Text('-'), onPressed: inheritedContext.reduce),
    );
  }
}

class InheritedWidgetTestContainer extends StatefulWidget {
  const InheritedWidgetTestContainer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InheritedWidgetTestContainerState();
  }
}

class _InheritedWidgetTestContainerState
    extends State<InheritedWidgetTestContainer> {
  late InheritedTestModel inheritedTestModel;

  _initData() {
    inheritedTestModel = const InheritedTestModel(0);
  }

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _incrementCount() {
    setState(() {
      inheritedTestModel = InheritedTestModel(inheritedTestModel.count + 1);
    });
  }

  _reduceCount() {
    setState(() {
      inheritedTestModel = InheritedTestModel(inheritedTestModel.count - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedContext(
        inheritedTestModel: inheritedTestModel,
        increment: _incrementCount,
        reduce: _reduceCount,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('InheritedWidgetTest'),
          ),
          body: Column(
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                child: Text(
                  '我们常使用的\nTheme.of(context).textTheme\nMediaQuery.of(context).size等\n就是通过InheritedWidget实现的',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              TestWidgetA(),
              TestWidgetB(),
              TestWidgetC(),
            ],
          ),
        ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InheritedWidgetTestContainer(),
    );
  }
}
