import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_annual.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AnnualScreen extends StatefulWidget {
  const AnnualScreen({super.key});

  @override
  State<AnnualScreen> createState() => _AnnualScreenState();
}

class _AnnualScreenState extends State<AnnualScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  Future<List<MAnnualInfo>>? oAryANN;

  @override
  void initState() {
    super.initState();

    getValidateAccount().whenComplete(
      () {
        if (oAccount == null || oAccount!.code == '') {
          Navigator.pushNamed(context, '/login');
        }

        oAryANN = fetchANNUALData();
      },
    );
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
              prefs.getString('logInDate') ?? DateTime.now().toString()));
    });
  }

  void refreshData() {
    setState(() {
      oAryANN = fetchANNUALData();
    });
  }

  Future<List<MAnnualInfo>> fetchANNUALData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getAnnual'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{'empCode': oAccount!.code}));

    if (response.statusCode == 200) {
      // on success, parse the JSON in the response body
      final parser = GetAnnualResultsParser(response.body);
      // return parser.parseInBackground();
      Future<List<MAnnualInfo>> data = parser.parseInBackground();
      data.then((value) =>
          value.sort((a, b) => b.yearAnnual.compareTo(a.yearAnnual)));
      return data;
    } else {
      throw ('failed to load data');
    }
  }

  // List<MAnnualInfo> parseANNList(String responseBody) {
  //   final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  //   return parsed.map<MAnnualInfo>((json) => MAnnualInfo.fromJson(json)).toList();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('วันลาพักร้อน (Annual)'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: FutureBuilder<List<MAnnualInfo>>(
        future: oAryANN,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Row(
                                children: [
                                  const Text('ปี '),
                                  Text(
                                    snapshot.data![index].yearAnnual,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  const Text('ได้รับ: '),
                                  Text(
                                    snapshot.data![index].totalText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900]),
                                  ),
                                  const Text(', ใช้ : '),
                                  Expanded(
                                      child: Text(
                                    snapshot.data![index].useText,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700]),
                                  )),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  const Text(
                                    'คงเหลือ ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(snapshot.data![index].remainHr,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green))
                                ],
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: snapshot.data!.length),
                  ),
                ],
              );
            } else {
              return const Text('ไม่พบข้อมูล');
            }
          } else if (snapshot.hasError) {
            return Text('err: ${snapshot.error}');
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class GetAnnualResultsParser {
  // 1. pass the encoded json as a constructor argument
  GetAnnualResultsParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MAnnualInfo>> parseInBackground() async {
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
        resultsJson.map((json) => MAnnualInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}
