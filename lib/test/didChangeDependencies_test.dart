import 'package:flutter/material.dart';

class A extends StatefulWidget {
  const A({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AState();
}

class AState extends State<A> {
  bool bDependenciesShouldChange = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 15), () {
      bDependenciesShouldChange = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    /// B`父级结构中的层级`发生变化时(`Scaffold`、`Container`、`C`、`B` => `Scaffold`、`Container`、`C`、`SizedBox`、`B`)， B会执行didChangeDependencies
    return bDependenciesShouldChange
        ? Scaffold(
            body: Container(
            height: 500,
            alignment: Alignment.centerLeft,
            child: C(child: B()),
          ))
        : Scaffold(
            body: Container(
            height: 500,
            alignment: Alignment.centerLeft,
            child: C(child: SizedBox(width: 20, height: 50, child: B())),
          ));

    // /// B`父级结构中的任一节点的widget类型`发生变化时(`Container` => `Center`)， B会执行didChangeDependencies
    // return bDependenciesShouldChange
    //     ? Scaffold(body: Center(child: C(child: B())))
    //     : Scaffold(
    //         body: Container(
    //         height: 500,
    //         alignment: Alignment.centerLeft,
    //         child: C(child: B()),
    //       ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("AdidChangeDependencies");
  }
}

class B extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BState();
}

class BState extends State<B> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("B"));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("BdidChangeDependencies");
  }
}

class C extends StatefulWidget {
  final Widget child;

  const C({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CState();
}

class CState extends State<C> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("CdidChangeDependencies");
  }
}
