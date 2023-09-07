import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_slip.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SlipScreen extends StatefulWidget {
  const SlipScreen({super.key});

  @override
  State<SlipScreen> createState() => _SlipScreenState();
}

class _SlipScreenState extends State<SlipScreen> {
  final formatDMY = DateFormat('MMMM, yyyy');
  Future<List<MSlipInfo>>? oArySlip;
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  List<bool> _obscureText = [];

  @override
  void initState() {
    super.initState();

    getValidateAccount().whenComplete(() {
      if (oAccount == null || oAccount!.code == '') {
        Navigator.pushNamed(context, '/login');
      }

      oArySlip = fetchDataSlip();
    });
  }

  void refreshData() {
    setState(() {
      oArySlip = fetchDataSlip();
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
        logInDate: DateTime.parse(
            prefs.getString('logInDate)') ?? DateTime.now().toString()),
      );
    });
  }

  Future<List<MSlipInfo>> fetchDataSlip() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getDocument'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{'empCode': oAccount!.code}));

    if (response.statusCode == 200) {
      _obscureText = [];

      // on success, parse the JSON in the response body
      final parser = GetSlipResultsParser(response.body);
      Future<List<MSlipInfo>> data = parser.parseInBackground();

      // Future<List<MSlipInfo>> data = compute(parseSlipList, response.body);

      data.then(
        (value) {
          for (var i = 0; i < value.length; i++) {
            _obscureText.add(true);
          }
        },
      );

      data.then((value) => value.sort(
            (a, b) => b.reqDate!.compareTo(a.reqDate!),
          ));
      return data;
      //return compute((message) => parseSlipList(response.body), response.body);
    } else {
      throw ('failed to load data slip');
    }
  }

  // List<MSlipInfo> parseSlipList(String responseBody) {
  //   final jsonData = jsonDecode(responseBody);
  //   //final resultsJson = jsonData['results'] as List<dynamic>;
  //   final resultsJson = jsonData as List<dynamic>;
  //   return resultsJson.map((json) => MSlipInfo.fromJson(json)).toList();
  // }

  List<MSlipInfo> parseSlipList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<MSlipInfo>((json) => MSlipInfo.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle txtBold =
        const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
    TextStyle txtSecret =
        const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('สลิปเงินเดือน (E-Pay Slip)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        ),
        body: FutureBuilder<List<MSlipInfo>>(
          future: oArySlip,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  (snapshot.data!.isNotEmpty)
                      ? Expanded(
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                String display = formatDMY.format(
                                    DateTime.parse(
                                        snapshot.data![index].reqDate ??
                                            DateTime.now().toString()));
                                return ListTile(
                                  title: Row(
                                    children: [
                                      const Text('ประจำเดือน '),
                                      Text(
                                        display,
                                        style: txtBold,
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 15),
                                          child: const Text('รหัสในการเปิด ')),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
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
                                                '${snapshot.data![index].passcode}',
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
                                  trailing: OutlinedButton.icon(
                                      onPressed: () async {
                                        Navigator.pushNamed(context, '/pdf',
                                            arguments: {
                                              'url':
                                                  'https://www.dci.co.th/hris/pdfviewer.aspx?f=dist/Slip/${snapshot.data![index].docFile}'
                                            });
                                        // String UrlFile ='https://www.dci.co.th/hris/pdfviewer.aspx?f=dist/Slip/${snapshot.data![index].docFile}';

                                        //https://www.dci.co.th/hris/pdfviewer.aspx?f=dist/Slip/202308\40865_HR042308-0050.pdf&fn=202308\40865_HR042308-0050.pdf
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.paperclip,
                                        size: 20,
                                      ),
                                      label: const Text('ดูสลิป')),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 5,
                                  ),
                              itemCount: snapshot.data!.length),
                        )
                      : const Text('ไม่พบข้อมูล'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      onWillPop: () async {
        Navigator.pushNamed(context, '/');
        return false;
      },
    );
  }
}

class GetSlipResultsParser {
  // 1. pass the encoded json as a constructor argument
  GetSlipResultsParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MSlipInfo>> parseInBackground() async {
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
        resultsJson.map((json) => MSlipInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}
