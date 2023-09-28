import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_user.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final formatDMY = DateFormat('MMMM, yyyy');
  Future<List<MUserInfo>>? oAryUsers;
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  List<bool> _obscureText = [];
  String txtSearch = "";

  @override
  void initState() {
    super.initState();

    getValidateAccount().whenComplete(() {
      if (oAccount == null || oAccount!.code == '' || oAccount!.token == '') {
        Navigator.pushNamed(context, '/login');
      }

      oAryUsers = fetchDataUserList();
    });
  }

  void refreshData() {
    setState(() {
      oAryUsers = fetchDataUserList();
    });
  }

  Future getValidateAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      oAccount = MAccount(
        code: prefs.getString('code') ?? '',
        name: prefs.getString('name') ?? '',
        surn: prefs.getString('surn') ?? '',
        shortName: prefs.getString('shortName') ?? '',
        fullName: prefs.getString('fullName') ?? '',
        tName: prefs.getString('tName') ?? '',
        tSurn: prefs.getString('tSurn') ?? '',
        joinDate: DateTime.parse(
            prefs.getString('joinDate') ?? DateTime.now().toString()),
        tFullName: prefs.getString('tFullName') ?? '',
        posit: prefs.getString('posit') ?? '',
        token: prefs.getString('token') ?? '',
        role: prefs.getString('role') ?? '',
        logInDate: DateTime.parse(
            prefs.getString('logInDate)') ?? DateTime.now().toString()),
      );
    });
  }

  Future<List<MUserInfo>> fetchDataUserList() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/userlist'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{'empCode': txtSearch}));

    if (response.statusCode == 200) {
      _obscureText = [];

      // on success, parse the JSON in the response body
      final parser = GetUserResultsParser(response.body);
      Future<List<MUserInfo>> data = parser.parseInBackground();

      // Future<List<MSlipInfo>> data = compute(parseSlipList, response.body);

      data.then(
        (value) {
          for (var i = 0; i < value.length; i++) {
            _obscureText.add(true);
          }
        },
      );

      data.then((value) => value.sort(
            (a, b) => b.empCode.compareTo(a.empCode),
          ));
      return data;
      //return compute((message) => parseSlipList(response.body), response.body);
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      throw ('failed to load data');
    } else {
      throw ('failed to load data user');
    }
  }

  Future updateUser(String paramEmpCode) async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/updateuser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'empCode': paramEmpCode,
          'UpdateBy': oAccount!.code,
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() => txtSearch = paramEmpCode);
      refreshData();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Expanded(child: Text('ไม่สามารถแก้ไขข้อมูล $paramEmpCode ได้')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  Future createUser(String paramEmpCode) async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/genuser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'empCode': paramEmpCode,
          'UpdateBy': oAccount!.code,
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() => txtSearch = paramEmpCode);
      refreshData();
    }
  }

  // List<MSlipInfo> parseSlipList(String responseBody) {
  //   final jsonData = jsonDecode(responseBody);
  //   //final resultsJson = jsonData['results'] as List<dynamic>;
  //   final resultsJson = jsonData as List<dynamic>;
  //   return resultsJson.map((json) => MSlipInfo.fromJson(json)).toList();
  // }

  // List<MUserInfo> parseSlipList(String responseBody) {
  //   final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  //   return parsed.map<MUserInfo>((json) => MUserInfo.fromJson(json)).toList();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle txtBold = const TextStyle(
        color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12);
    TextStyle txtSecret = const TextStyle(
        color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12);

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('จัดการรายชื่อเข้าใช้งาน (User Control)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(100, 5, 100, 5),
              child: TextFormField(
                maxLength: 5,
                decoration: const InputDecoration(
                  counterText: '',
                  label: Text('ค้นหา'),
                  hintText: 'รหัสพนักงาน',
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    txtSearch = value;

                    refreshData();
                  });
                },
              ),
            ),
            const Divider(
              thickness: 1,
              color: Colors.black,
            ),
            Expanded(
              child: FutureBuilder<List<MUserInfo>>(
                future: oAryUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return (snapshot.data!.isNotEmpty)
                        ? ListView.separated(
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Wrap(children: [
                                  Text(
                                      '${snapshot.data![index].empCode}:${snapshot.data![index].empFullName} [${snapshot.data![index].empPosit}]',
                                      style: txtBold),
                                ]),
                                subtitle: Wrap(children: [
                                  Row(
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 15),
                                          child: const Text('รหัสผ่าน ')),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 3,
                                            bottom: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                        ),
                                        child: (_obscureText[index])
                                            ? Text(
                                                '******',
                                                style: txtSecret,
                                              )
                                            : Text(
                                                snapshot.data![index].password,
                                                style: txtSecret,
                                              ),
                                      ),
                                      IconButton(
                                        onPressed: () => setState(() {
                                          _obscureText[index] =
                                              !_obscureText[index];
                                        }),
                                        icon: (_obscureText[index])
                                            ? const Icon(
                                                FontAwesomeIcons.eyeSlash,
                                                color: Colors.blue,
                                              )
                                            : const Icon(FontAwesomeIcons.eye,
                                                color: Colors.redAccent),
                                      )
                                    ],
                                  ),
                                ]),
                                trailing: OutlinedButton(
                                    onPressed: () async {
                                      updateUser(snapshot.data![index].empCode);
                                    },
                                    child: Text(snapshot.data![index].status)),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                                  height: 5,
                                ),
                            itemCount: snapshot.data!.length)
                        : const Text('ไม่พบข้อมูล');
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {},
          shape: const CircleBorder(),
          child: Icon(
            FontAwesomeIcons.plus,
            color: theme.colorScheme.surface,
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pushNamed(context, '/');
        return false;
      },
    );
  }
}

class GetUserResultsParser {
  // 1. pass the encoded json as a constructor argument
  GetUserResultsParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MUserInfo>> parseInBackground() async {
    // create a port
    final p = ReceivePort();
    // spawn the isolate and wait for it to complete
    await Isolate.spawn(_decodeAndParseJson, p.sendPort);
    // get and return the result data
    return await p.first;
  }

  // 3. json parsing
  Future<void> _decodeAndParseJson(SendPort p) async {
    // decode and parse the json
    final jsonData = jsonDecode(encodedJson);
    //final resultsJson = jsonData['results'] as List<dynamic>;
    final resultsJson = jsonData as List<dynamic>;
    final results =
        resultsJson.map((json) => MUserInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}
