///
/// 现在把controller理解为一个全局变量，build不同widget（自己的）时传入controller
///
import 'package:flutter/material.dart';

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
    var controller = CartViewController(data: data);
    debugPrint("爷爷Widget build了");
    return MaterialApp(
      title: 'InheritedWidget的使用',
      home: APage(
        controller: controller,
      ),
    );
  }
}

///
/// 商品页
///
class APage extends StatelessWidget {
  const APage({Key? key, required this.controller}) : super(key: key);
  final CartViewController controller;

  @override
  Widget build(BuildContext context) {
    debugPrint("商品页 build了");
    var _count = controller.data.count;

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
                  controller.increment();
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 10),
              //Text(_count.value.toString()),
              ValueListenableBuilder(
                valueListenable: _count,
                builder: (context, value, _) {
                  return Text(_count.value.toString());
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  controller.reduce();
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BPage(
                        controller: controller,
                      ),
                    ),
                    (route) => false,
                  );
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
  const BPage({Key? key, required this.controller}) : super(key: key);
  final CartViewController controller;

  @override
  Widget build(BuildContext context) {
    debugPrint("结算页 build了");
    var _count = controller.data.count;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('结算'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(_count.value.toString()),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => APage(
                        controller: controller,
                      ),
                    ),
                    (route) => false,
                  );
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
/// 由它控制数据，其他widget监听到数据改变后刷新，不会全局build
///
class CartViewController {
  //数据
  final CartModel data;

  const CartViewController({required this.data});

  increment() {
    debugPrint('加法');
    data.count.value++;
  }

  reduce() {
    debugPrint('减法');
    data.count.value--;
  }
}
