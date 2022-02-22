import 'dart:convert';

import 'dart:io';

String gJsonStr = '''
{
  "name": "Ravi Tamada",
  "email": "ravi8x@gmail.com",
  "phone": {
    "home": "08947 000000",
    "mobile": "9999999999"
  }
}
''';

main() {
  test2();
}

//方法1 简便
test1() {
  String jsonString = '{"name": "John Smith","email": "john@example.com"}';
  Map<String, dynamic> user = jsonDecode(jsonString);

  print('Howdy, ${user['name']}!');
  print('We sent the verification link to ${user['email']}.');
}

//方法2 严谨
class User {
  final String name;
  final String email;
  final Phone phone;

  User(this.name, this.email, this.phone);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        phone = Phone.fromJson(json['phone']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

class Phone {
  final String home;
  final String mobile;

  Phone(this.home, this.mobile);

  Phone.fromJson(Map<String, dynamic> json)
      : home = json['home'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() => {'home': home, 'mobile': mobile};
}

class ConfigServer {
  String type = 'ftp'; //FTP或其他，前期只写FTP
  late String name;
  late String ip;
  int port = 21;
  late String loginName;
  late String loginPassword;

  ConfigServer(
      {required this.type,
      required this.name,
      required this.ip,
      required this.port,
      required this.loginName,
      required this.loginPassword});

  ConfigServer.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        name = json['name'],
        ip = json['ip'],
        port = json['port'],
        loginName = json['loginName'],
        loginPassword = json['loginPassword'];

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'ip': ip,
        'port': port,
        'loginName': loginName,
        'loginPassword': loginPassword,
      };
}

test2() {
  //class转json
  var phone = Phone("010", "139");
  var user = User("fish", "fish@qq.com", phone);
  String jsonString = jsonEncode(user);

  //json转class
  Map<String, dynamic> jsonDynamic = jsonDecode(gJsonStr);
  var userFromJson = User.fromJson(jsonDynamic);

  //打印calss
  print(userFromJson.name);
  print(userFromJson.email);
  print(userFromJson.phone.home);
  print(userFromJson.phone.mobile);

  //以上是别人的代码总结

  //下面测试自己的
  var aServer = ConfigServer(
      type: 'ftp',
      name: 'test',
      ip: '192.168.0.139',
      port: 21,
      loginName: 'admin',
      loginPassword: 'password');

  var serverJsonString = jsonEncode(aServer);
  print(serverJsonString);

  Map<String, dynamic> serverJsonDecoded = jsonDecode(serverJsonString);
  var bServer = ConfigServer.fromJson(serverJsonDecoded);
  print(bServer);
}
