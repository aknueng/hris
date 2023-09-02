import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_ot.dart';
import 'package:hris/models/md_todos.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ดึงข้อมูลจัดการข้อมูลบนเครือข่าย internet

class OTRecordScreen extends StatefulWidget {
  const OTRecordScreen({super.key});

  @override
  State<OTRecordScreen> createState() => _OTRecordScreenState();
}

class _OTRecordScreenState extends State<OTRecordScreen> {
  Future<List<MOtInfo>>? oAryOT;

  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  @override
  void initState() {
    super.initState();

    getValidateAccount().whenComplete(() async {
      if (oAccount == null) {
        Navigator.pushNamed(context, '/login');
      }

      oAryOT = fetchOTData();
    });
  }

  void refreshData() {
    setState(() {
      oAryOT = fetchOTData();
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
            prefs.getString('logInDate') ?? DateTime.now().toString()),
      );
    });
  }

  Future<List<MOtInfo>> fetchOTData() async {
    final DateFormat formatYMD = DateFormat('yyyyMMdd');
    final String st =
        formatYMD.format(DateTime.now().subtract(const Duration(hours: 8)));

    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getot'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'dateStart': formatYMD
              .format(DateTime.now().subtract(const Duration(hours: 8))),
          'dateEnd': formatYMD
              .format(DateTime.now().add(const Duration(days: 6, hours: 16))),
          'EmpCode': oAccount!.code,
        }));

    if (response.statusCode == 200) {
      return compute((message) => parseOTList(response.body), response.body);
      // final parsed = jsonDecode(response.body)['todos'].cast<Map<String, dynamic>>();
      // return parsed.map<Todos>((json) => Todos.fromJson(json)).toList();
    } else {
      // กรณี error
      throw Exception('Failed to load ot list');
    }
  }

  List<MOtInfo> parseOTList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<MOtInfo>((json) => MOtInfo.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OT Record'),
      ),
      body: Center(
        child: FutureBuilder<List<MOtInfo>>(
            future: oAryOT,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration:
                          BoxDecoration(color: Colors.teal.withAlpha(100)),
                      child: Row(children: [
                        Text('Total ${snapshot.data!.length} items')
                      ]),
                    ),
                    Expanded(
                        child: snapshot.data!.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  String PeriodTime = "";
                                  String OTType = "";
                                  if (snapshot.data![index].status == "") {
                                    if (snapshot.data![index].shift == "D") {
                                      PeriodTime = "18:15 - 20:00";
                                      OTType = "A";
                                    } else if (snapshot.data![index].shift ==
                                        "N") {
                                      PeriodTime = "06:05 - 07:50";
                                      OTType = "D";
                                    } else if (snapshot.data![index].shift ==
                                        "HD") {
                                      PeriodTime = "08:00 - 20:00";
                                      OTType = "F";
                                    } else if (snapshot.data![index].shift ==
                                        "HN") {
                                      PeriodTime = "20:00 - 07:50";
                                      OTType = "K";
                                    }
                                  } else {
                                    PeriodTime =
                                        '${snapshot.data![index].otStart} - ${snapshot.data![index].otEnd}';
                                  }

                                  return ListTile(
                                    title: (snapshot.data![index].status ==
                                            "APPROVE")
                                        ? Text(
                                            '${snapshot.data![index].shift}   ${snapshot.data![index].strDate} เวลา $PeriodTime')
                                        : Text(
                                            '${snapshot.data![index].shift}   ${snapshot.data![index].strDate} เวลา $PeriodTime'),
                                    subtitle: (snapshot.data![index].otStart !=
                                            '')
                                        ? Text(
                                            '${snapshot.data![index].otStart} - ${snapshot.data![index].otEnd}')
                                        : const Text(''),
                                    trailing: (snapshot.data![index].status ==
                                            "APPROVE")
                                        ? const Icon(
                                            FontAwesomeIcons.circleCheck)
                                        : const Icon(
                                            FontAwesomeIcons.circleXmark),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                itemCount: snapshot.data!.length)
                            : const Center(child: Text('No item'))),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshData,
        child: const Icon(FontAwesomeIcons.rotate),
      ),
    );
  }
}
