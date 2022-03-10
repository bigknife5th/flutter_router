import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
import 'page_servers.dart';

class PageServerModify extends StatefulWidget {
  const PageServerModify({Key? key}) : super(key: key);

  @override
  State<PageServerModify> createState() => _PageServerModifyState();
}

class _PageServerModifyState extends State<PageServerModify> {
  // final ValueNotifier<String> _selectedValue = ValueNotifier<String>('FTP');
  String _selectedValue = 'FTP';
  final ConfigServer _configServer = ConfigServer(ip: '', serverName: '');
  // late ModifyParam modifyParam;
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _serverNameController = TextEditingController();
  final TextEditingController _iPController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    if ()
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> sortItems = [];
    sortItems.add(const DropdownMenuItem(value: 'FTP', child: Text('FTP')));
    sortItems.add(const DropdownMenuItem(value: 'TODO', child: Text('TODO')));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ggText(context, 'Server Detail'),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Combobox
              DropdownButton<String>(
                hint: Text(ggText(context, 'Server Type')),
                isExpanded: true,
                items: sortItems,
                value: _selectedValue,
                onChanged: (v) {
                  setState(() {
                    _selectedValue = v!;
                  });
                },
              ),
              _buildBaseForm(_selectedValue),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //确认按钮
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(80, 20)),
                    ),
                    onPressed: () {
                      comfirm();
                      Navigator.pop(context, _configServer);
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  //取消按钮
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(80, 20)),
                    ),
                    onPressed: () {
                      print('Cancel');
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubForm(String formName) {
    switch (formName) {
      case "FTP":
        {
          return _buildFtpForm();
        }
      case "TODO":
        {
          return _buildWebdavForm();
        }
      default:
        {
          return _buildFtpForm();
        }
    }
  }

  Widget _buildBaseForm(String formName) {
    return Column(
      children: [
        //服务器名
        TextField(
          controller: _serverNameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: ggText(context, 'Server Name'),
          ),
        ),
        //服务器IP
        TextField(
          controller: _iPController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: ggText(context, 'IP Address'),
          ),
        ),
        //端口
        TextField(
          controller: _portController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: ggText(context, 'Port'),
          ),
        ),
        //用户名
        TextField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: ggText(context, 'Login Name'),
          ),
        ),
        //密码
        TextField(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: ggText(context, 'Login Password'),
          ),
        ),
        _buildSubForm(formName),
      ],
    );
  }

  Widget _buildFtpForm() {
    _configServer.serverType = 'ftp';
    return Column(children: [
      const SizedBox(
        height: 10,
      ),
      ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(170, 20)),
        ),
        onPressed: () {
          print('test');
        },
        child: const Text('Test'),
      ),
    ]);
  }

  Widget _buildWebdavForm() {
    _configServer.serverType = 'todo';
    return const Text("todo...");
  }

  void comfirm() {
    //服务器名
    _configServer.serverName = _serverNameController.text.isNotEmpty
        ? _serverNameController.text
        : _iPController.text;
    //服务器IP
    _configServer.ip = _iPController.text;
    //服务器port
    try {
      _configServer.port = int.parse(_portController.text);
    } catch (e) {}

    //用户名
    _configServer.user = _usernameController.text;
    //密码
    _configServer.pass = _passwordController.text;
    print(_configServer);
  }
}

class ModifyParam {
  late String cmd;
  late ConfigServer configServer;

  ModifyParam({required this.cmd, required this.configServer});
}
