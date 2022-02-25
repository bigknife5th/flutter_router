import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Current path style: ${p.style}');

    print('Current process path: ${p.current}');

    print('Separators');
    for (var entry in [p.posix, p.windows, p.url]) {
      print('  ${entry.style.toString().padRight(7)}: ${entry.separator}');
    }
    return Container();
  }
}

void main() {
  runApp(MyApp());
}
