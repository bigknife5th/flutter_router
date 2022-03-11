import 'package:flutter/material.dart';
import 'package:flutter_router/localization.dart';
import 'page_servers.dart';

class PageServerModify extends StatefulWidget {
  const PageServerModify({Key? key}) : super(key: key);

  @override
  State<PageServerModify> createState() => _PageServerModifyState();
}

class _PageServerModifyState extends State<PageServerModify> {
  //ValueNotifier<String> _selectedValue = ValueNotifier<String>('FTP');
  ValueNotifier<bool> ffNeedRefresh = ValueNotifier(false);
  String _selectedValue = 'FTP';
  final ConfigServer _configServer = ConfigServer();
  // late ModifyParam modifyParam;
  final TextEditingController _serverNameController = TextEditingController();
  final TextEditingController _iPController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late ModifyParam? ffModifyParam;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    _getRouteParam(context);
    List<DropdownMenuItem<String>> sortItems = [];
    sortItems.add(const DropdownMenuItem(value: 'FTP', child: Text('FTP')));
    sortItems.add(const DropdownMenuItem(value: 'TODO', child: Text('TODO')));
    return ValueListenableBuilder<bool>(
      valueListenable: ffNeedRefresh,
      builder: (context, snapdata, _) {
        return _buildScaffold(context, sortItems);
      },
    );
  }

  Scaffold _buildScaffold(
      BuildContext context, List<DropdownMenuItem<String>> sortItems) {
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
                  debugPrint('onChange');
                  if (v != null) {
                    _selectedValue = v;
                    ffNeedRefresh.value = !ffNeedRefresh.value;
                  }
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
                      debugPrint('Cancel');
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

  Widget myTextInput({controller, labelText, icon, keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      //padding: const EdgeInsets.only(left: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          //prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildBaseForm(String formName) {
    return Column(
      children: [
        //服务器名
        myTextInput(
            controller: _serverNameController,
            labelText: ggText(context, 'Server Name'),
            icon: Icons.settings),
        //服务器IP
        myTextInput(
          controller: _iPController,
          keyboardType: TextInputType.text,
          labelText: ggText(context, 'Server Address'),
        ),
        //端口
        myTextInput(
          controller: _portController,
          keyboardType: TextInputType.number,
          labelText: ggText(context, 'Port'),
        ),
        //用户名
        myTextInput(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          labelText: ggText(context, 'Login Name'),
        ),
        //密码
        myTextInput(
          controller: _passwordController,
          keyboardType: TextInputType.text,
          labelText: ggText(context, 'Login Password'),
        ),
        _buildSubForm(formName)
      ],
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
          debugPrint('test');
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
    } catch (e) {
      debugPrint(e.toString());
    }

    //用户名
    _configServer.user = _usernameController.text;
    //密码
    _configServer.pass = _passwordController.text;
  }

  _getRouteParam(BuildContext context) {
    if (ModalRoute.of(context) != null) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        ffModifyParam =
            (ModalRoute.of(context)?.settings.arguments as ModifyParam);
        var temp = ffModifyParam!.configServer;
        _selectedValue = temp.serverType.toUpperCase();
        _serverNameController.text = temp.serverName;
        _iPController.text = temp.ip;
        _portController.text = temp.port.toString();
        _usernameController.text = temp.user;
        _passwordController.text = temp.pass;
      } else {
        ffModifyParam = null;
      }
    }
  }

  navgateToModify(String cmd, {required ConfigServer configServer}) {
    if (cmd == 'edit') {
      ModifyParam modifyParam =
          ModifyParam(cmd: cmd, configServer: configServer);
      return;
    }
    if (cmd == 'add') {
      ConfigServer nullConfigServer = ConfigServer();
      ModifyParam modifyParam =
          ModifyParam(cmd: cmd, configServer: nullConfigServer);
      return;
    }
  }
}

class ModifyParam {
  late String cmd;
  late ConfigServer configServer;

  ModifyParam({required this.cmd, required this.configServer});
}
