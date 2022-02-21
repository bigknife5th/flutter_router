import 'dart:convert';

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

test2() {
  //class转json
  var phone = Phone("010", "139");
  var user = User("fish", "fish@qq.com", phone);
  String jsonString = jsonEncode(user);

  //json转class
  Map<String, dynamic> userMap = jsonDecode(gJsonStr);
  var userFromJson = User.fromJson(userMap);

  //打印calss
  print(userFromJson.name);
  print(userFromJson.email);
  print(userFromJson.phone.home);
  print(userFromJson.phone.mobile);
}
