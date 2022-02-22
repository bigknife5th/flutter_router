import 'dart:io';
import 'dart:convert'; //解码和编码JSON
import 'package:flutter/material.dart';

String BASE_BING = 'https://cn.bing.com';

void main() => runApp(MyApp());

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BingImages?>? bingImageList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bing Wallpapper')),
        body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
                itemBuilder: _renderRow,
                itemCount: bingImageList != null ? bingImageList!.length : 0)));
  }

  Widget _renderRow(BuildContext context, int index) {
    String url;
    url = bingImageList![index]!.url!;
    url = BASE_BING + url.substring(0, url.indexOf('&'));

    return ListTile(
      leading: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.fitHeight,
      ),
      title: Text(bingImageList![index]!.copyright!),
    );
  }

  Future<void> _onRefresh() async {
    print('refresh');

    var httpClient = HttpClient();
    var requset = await httpClient.getUrl(Uri.parse(
        "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=15&nc=1612409408851&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"));
    var response = await requset.close();

    if (response.statusCode == 200) {
      String responseBody = await response.transform(utf8.decoder).join();
      Map<String, dynamic> jsonDecoded = jsonDecode(responseBody);
      var bingWallpapper = BingWalpper.fromJson(jsonDecoded);
      setState(() {
        bingImageList = bingWallpapper.images;
      });
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_get() async {
  String responseBody;
  //1.创建HttpClient
  var httpClient = HttpClient();
  //2.构造Uri
  var requset = await httpClient.getUrl(Uri.parse(
      "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=10&nc=1612409408851&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"));
  //3.关闭请求，等待响应
  var response = await requset.close();
  //4.进行解码，获取数据
  if (response.statusCode == 200) {
    //拿到请求的数据
    responseBody = await response.transform(utf8.decoder).join();
    //先不解析打印数据
    //print(responseBody);
    Map<String, dynamic> JsonDecoded = jsonDecode(responseBody);
    var bingWallpapper = BingWalpper.fromJson(JsonDecoded);
    print(bingWallpapper);
  } else {
    print("error");
  }
}

// 使用 https://github.com/debuggerx01/JSONFormat4Flutter 创建的:
class BingWalpper {
  List<BingImages?>? images;
  Tooltips? tooltips;

  BingWalpper.fromParams({required this.images, this.tooltips});

  factory BingWalpper(Object jsonStr) => jsonStr is String
      ? BingWalpper.fromJson(json.decode(jsonStr))
      : BingWalpper.fromJson(jsonStr);

  static BingWalpper? parse(jsonStr) =>
      ['null', '', null].contains(jsonStr) ? null : BingWalpper(jsonStr);

  BingWalpper.fromJson(jsonRes) {
    images = jsonRes['images'] == null ? null : [];

    for (var imagesItem in images == null ? [] : jsonRes['images']) {
      images!.add(imagesItem == null ? null : BingImages.fromJson(imagesItem));
    }

    tooltips = jsonRes['tooltips'] == null
        ? null
        : Tooltips.fromJson(jsonRes['tooltips']);
  }

  @override
  String toString() {
    return '{"images": $images, "tooltips": $tooltips}';
  }

  String toJson() => toString();
}

class Tooltips {
  String? loading;
  String? next;
  String? previous;
  String? walle;
  String? walls;

  Tooltips.fromParams(
      {this.loading, this.next, this.previous, this.walle, this.walls});

  Tooltips.fromJson(jsonRes) {
    loading = jsonRes['loading'];
    next = jsonRes['next'];
    previous = jsonRes['previous'];
    walle = jsonRes['walle'];
    walls = jsonRes['walls'];
  }

  @override
  String toString() {
    return '{"loading": ${loading != null ? json.encode(loading) : 'null'}, "next": ${next != null ? json.encode(next) : 'null'}, "previous": ${previous != null ? json.encode(previous) : 'null'}, "walle": ${walle != null ? json.encode(walle) : 'null'}, "walls": ${walls != null ? json.encode(walls) : 'null'}}';
  }

  String toJson() => toString();
}

class BingImages {
  int? bot;
  int? drk;
  int? top;
  bool? wp;
  String? copyright;
  String? copyrightlink;
  String? enddate;
  String? fullstartdate;
  String? hsh;
  String? quiz;
  String? startdate;
  String? title;
  String? url;
  String? urlbase;

  BingImages.fromParams(
      {this.bot,
      this.drk,
      this.top,
      this.wp,
      this.copyright,
      this.copyrightlink,
      this.enddate,
      this.fullstartdate,
      this.hsh,
      this.quiz,
      this.startdate,
      this.title,
      this.url,
      this.urlbase});

  BingImages.fromJson(jsonRes) {
    bot = jsonRes['bot'];
    drk = jsonRes['drk'];
    top = jsonRes['top'];
    wp = jsonRes['wp'];
    copyright = jsonRes['copyright'];
    copyrightlink = jsonRes['copyrightlink'];
    enddate = jsonRes['enddate'];
    fullstartdate = jsonRes['fullstartdate'];
    hsh = jsonRes['hsh'];
    quiz = jsonRes['quiz'];
    startdate = jsonRes['startdate'];
    title = jsonRes['title'];
    url = jsonRes['url'];
    urlbase = jsonRes['urlbase'];
  }

  @override
  String toString() {
    return '{"bot": $bot, "drk": $drk, "top": $top, "wp": $wp, "copyright": ${copyright != null ? '${json.encode(copyright)}' : 'null'}, "copyrightlink": ${copyrightlink != null ? '${json.encode(copyrightlink)}' : 'null'}, "enddate": ${enddate != null ? '${json.encode(enddate)}' : 'null'}, "fullstartdate": ${fullstartdate != null ? '${json.encode(fullstartdate)}' : 'null'}, "hsh": ${hsh != null ? '${json.encode(hsh)}' : 'null'}, "quiz": ${quiz != null ? '${json.encode(quiz)}' : 'null'}, "startdate": ${startdate != null ? '${json.encode(startdate)}' : 'null'}, "title": ${title != null ? '${json.encode(title)}' : 'null'}, "url": ${url != null ? '${json.encode(url)}' : 'null'}, "urlbase": ${urlbase != null ? '${json.encode(urlbase)}' : 'null'}}';
  }

  String toJson() => toString();
}
