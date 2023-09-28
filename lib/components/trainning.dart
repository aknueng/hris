import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_training.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  Future<List<MTrainingInfo>>? oAryTraining;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() {
      if (oAccount == null || oAccount!.code == '' || oAccount!.token == '') {
        Navigator.pushNamed(context, '/login');
      }

      oAryTraining = fetchTraningData();
    });
  }

  void refreshData() {
    setState(() {
      oAryTraining = fetchTraningData();
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
          telephone: prefs.getString('telephone') ?? '',
          logInDate: DateTime.parse(
              prefs.getString('logInDate)') ?? DateTime.now().toString()));
    });
  }

  Future<List<MTrainingInfo>> fetchTraningData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getTrainning'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{'empCode': oAccount!.code}));

    if (response.statusCode == 200) {
      // on success, parse the JSON in the response body
      final parser = GetTrainingResultsParser(response.body);
      // return parser.parseInBackground();
      Future<List<MTrainingInfo>> data = parser.parseInBackground();
      data.then((value) =>
          value.sort((a, b) => b.scheduleStart.compareTo(a.scheduleStart)));
      return data;
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      throw ('failed to load data');
    } else {
      throw ('failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('ฝึกอบรม (Training Record)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface),
      body: FutureBuilder<List<MTrainingInfo>>(
        future: oAryTraining,
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
                                  Expanded(
                                    child: Text(
                                      '${snapshot.data![index].courseCode} : ${snapshot.data![index].courseName}',
                                      // style: const TextStyle(
                                      //     fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${snapshot.data![index].scheduleStart} - ${snapshot.data![index].scheduleEnd}',
                                      // style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.blue[900]),
                                    ),
                                  ),
                                  // const Text(', ใช้ : '),
                                  // Expanded(
                                  //     child: Text(
                                  //   snapshot.data![index].useText,
                                  //   style: TextStyle(
                                  //       fontSize: 14,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Colors.amber[700]),
                                  // )),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  (snapshot.data![index].evaluateResult == "P")
                                      ? const Text('ผ่าน',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green))
                                      : const Text('ไม่ผ่าน',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))
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

class GetTrainingResultsParser {
  // 1. pass the encoded json as a constructor argument
  GetTrainingResultsParser(this.encodedJson);
  final String encodedJson;

  // 2. public method that does the parsing in the background
  Future<List<MTrainingInfo>> parseInBackground() async {
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
        resultsJson.map((json) => MTrainingInfo.fromJson(json)).toList();
    // return the result data via Isolate.exit()
    Isolate.exit(p, results);
  }
}
