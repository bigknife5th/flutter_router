void main() {
  Persion persion = Persion(10, name: '张三', height: 156);

  Persion persionJson =
      Persion.fromJson({'age': 10, 'name': '张三', 'height': 156});

  print(persion.toJson());
  print(persionJson.toJson());
}

class Persion extends Object {
  late int age;
  late String name;
  late int height;

  // Persion(int age, String name, int height) {
  //   this.age = age;
  //   this.name = name;
  //   this.height = height;
  // }

  Persion(this.age, {required this.name, required this.height});

  Persion.fromJson(Map<String, dynamic> json) {
    this.age = json['age'];
    this.name = json['name'];
    this.height = json['height'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['age'] = this.age;
    data['name'] = this.name;
    data['height'] = this.height;
    return data;
  }
}
