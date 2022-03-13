///
/// 2022.3.13
/// 使用getx，目前看来，在状态管理上的区别，他更像是把controller放到全局环境里去了（Get.put）
/// 在需要的地方Get.find()取出即可，可创多个controller，加tag指定名称
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
    debugPrint("爷爷Widget build了");
    return MaterialApp(
      home: APage(),
    );
  }
}

///
/// 商品页
///
class APage extends StatelessWidget {
  APage({Key? key}) : super(key: key);
  // final CartViewController controller;
  // controll改为getx的GetxController
  final controller = Get.put(CartViewController(), tag: "test");
  //final CartViewController controller = CartViewController(); //这样不行，不Put的话别的地方find不到会报错

  @override
  Widget build(BuildContext context) {
    debugPrint("商品页 build了");

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
              Obx(
                () {
                  return Text("${controller.data.count}");
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
                      builder: (context) => const BPage(),
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
  const BPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("结算页 build了");
    var controller = Get.find<CartViewController>(tag: "test");
    var _count = controller.data.count;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('结算'),
        ),
        body: Center(
          child: Column(
            children: [
              Text("$_count"), //这个测试里因为页面是新建的，所以每次必触发build，就没有必要用Obx了
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => APage(),
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
/// 结构定义
///
class CartModel {
  RxInt count = 0.obs;
}

///
/// 控制
///
class CartViewController extends GetxController {
  //加上extends GetxController
  //数据
  final CartModel data = CartModel();

  increment() {
    debugPrint('加法');
    data.count++;
  }

  reduce() {
    debugPrint('减法');
    data.count--;
  }
}
