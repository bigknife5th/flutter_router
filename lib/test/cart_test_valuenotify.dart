///
/// 购物车InheritedWidget测试（ValueListenableBuilder实现）
///
import 'package:flutter/material.dart';
import 'package:get/get.dart';

main() {
  runApp(const MyAppUseValueNotify());
}

///
/// 使用ValueNotify更新的主页
///
class MyAppUseValueNotify extends StatefulWidget {
  const MyAppUseValueNotify({Key? key}) : super(key: key);

  @override
  State<MyAppUseValueNotify> createState() => _MyAppUseValueNotifyState();
}

class _MyAppUseValueNotifyState extends State<MyAppUseValueNotify> {
  CartModel data = CartModel();

  @override
  Widget build(BuildContext context) {
    // 此处的ShareWidget是InheritedWidget类型的组建
    debugPrint("爷爷Widget build了");
    return CartView(
      data: data,
      reduce: _reduce,
      increment: _increment,
      child: MaterialApp(
        title: 'InheritedWidget的使用',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const APage(),
      ),
    );
  }

  _increment() {
    debugPrint('加法');
    data.count.value++;
  }

  _reduce() {
    debugPrint('减法');
    data.count.value--;
  }
}

///
/// 商品页
///
class APage extends StatelessWidget {
  const APage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("商品页 build了");
    var _count = CartView.of(context)!.data.count;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('商品'),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  CartView.of(context)!.increment();
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 10),
              Text(_count.toString()),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  CartView.of(context)!.reduce();
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const BPage()),
                      (route) => false);
                },
                child: const Text('去结算'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///
/// 结算页
///
class BPage extends StatelessWidget {
  const BPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("结算页 build了");
    var _count = CartView.of(context)!.data.count;
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('结算'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(_count.toString()),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const APage()),
                      (route) => false);
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// 数据
///
class CartModel {
  ValueNotifier<int> count = ValueNotifier(0);
}

///
/// 由它展示数据
///
class CartView extends InheritedWidget {
  //数据
  final CartModel data;
  //点击+号的方法
  final Function() increment;
  //点击-号的方法
  final Function() reduce;

  const CartView(
      {Key? key,
      required this.increment,
      required this.reduce,
      required this.data,
      required child})
      : super(key: key, child: child);

  // 写法1:返回组件对象
  static CartView? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: CartView);
    //return context.dependOnInheritedWidgetOfExactType<CartView>();
  }

  // // 写法2:直接返回共享数据
  // static CartModel of(BuildContext context) {
  //   final CartView? shareWidget =
  //       context.dependOnInheritedWidgetOfExactType<CartView>();
  //   return shareWidget!.data;
  // }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(CartView oldWidget) {
    return true;
    //return data != oldWidget.data;
  }
}
