// 测试 当页面切换时，原页面状态是否被保存
// ven 2022.2.20

import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Page1();
}

class _Page1 extends State<Page1> with AutomaticKeepAliveClientMixin {
  int _counter = 0;

  @override
  bool get wantKeepAlive => true; // 是否需要缓存

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("页面状态测试页1")),
        body: Center(
          child: Text(_counter.toString()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Page2();
}

class _Page2 extends State<Page2> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("页面状态测试页2")),
        body: Center(
          child: Text(_counter.toString()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Page3();
}

class _Page3 extends State<Page3> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("页面状态测试页3")),
        body: Center(
          child: Text(_counter.toString()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Page4();
}

class _Page4 extends State<Page4> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("页面状态测试页4")),
        body: Center(
          child: Text(_counter.toString()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}

// 主界面
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int _selectedIndex = 0;
  late PageController _controller;

  final List<Widget> chiledList = const [Page1(), Page2(), Page3(), Page4()];

  final List<BottomNavigationBarItem> _listItem =
      const <BottomNavigationBarItem>[
    BottomNavigationBarItem(label: "album", icon: Icon(Icons.photo_album)),
    BottomNavigationBarItem(label: "servers", icon: Icon(Icons.laptop_mac)),
    BottomNavigationBarItem(label: "task", icon: Icon(Icons.library_books)),
    BottomNavigationBarItem(label: "setting", icon: Icon(Icons.settings)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  void _onTapUsePageView(int index) {
    _controller.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  void _pageChange(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _controller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            //body: chiledList[_selectedIndex],
            body: PageView(
                physics: const NeverScrollableScrollPhysics(), //viewPage禁止左右滑动
                //onPageChanged: _pageChange,
                controller: _controller,
                //itemBuilder: (context, index) => chiledList[index]),
                children: const [Page1(), Page2(), Page3(), Page4()]),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onTapUsePageView,
              selectedItemColor: Colors.blue,
              backgroundColor: Colors.grey[100],
              type: BottomNavigationBarType.fixed,
              //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
              items: _listItem,
            )));
  }
}

void main() => runApp(const MyApp());
