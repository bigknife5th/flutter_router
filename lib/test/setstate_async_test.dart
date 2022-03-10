import 'package:flutter/material.dart';

main() => runApp(const TestWidget());

class TestWidget extends StatefulWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TestWidgetState();
  }
}

class _TestWidgetState extends State<TestWidget> {
  int number = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(number.toString()),
            ElevatedButton(
              onPressed: () async {
                //可以在setState之外使用await setState本身不能async
                await test();
                setState(() {});
              },
              child: const Text("test"),
            )
          ],
        ),
      ),
    );
  }

  Future<int> test() async {
    await Future.delayed(const Duration(seconds: 1), () {
      number++;
      print(number);
    });
    return number;
  }
}
