import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_ot.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ดึงข้อมูลจัดการข้อมูลบนเครือข่าย internet

class OTRecordScreen extends StatefulWidget {
  const OTRecordScreen({super.key});

  @override
  State<OTRecordScreen> createState() => _OTRecordScreenState();
}

class _OTRecordScreenState extends State<OTRecordScreen> {
  late Future<List<MOtInfo>> oAryOT;
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() {

      if (oAccount == null) {
        Navigator.pushNamed(context, '/login');
      }
      
      oAryOT = fetchDataOT();
    });
  }

  void refreshData() {
    setState(() {
      oAryOT = fetchDataOT();
    });
  }

  Future getValidateAccount() async {
    final SharedPreferences pers = await SharedPreferences.getInstance();
    oAccount = MAccount(
        code: pers.getString('code') ?? '',
        name: pers.getString('name') ?? '',
        surn: pers.getString('surn') ?? '',
        shortName: pers.getString(' shorName') ?? '',
        fullName: pers.getString(' fulName') ?? '',
        tName: pers.getString(' Name') ?? '',
        tSurn: pers.getString(' Surn') ?? '',
        joinDate: DateTime.parse(
            pers.getString(' joiDate') ?? DateTime.now().toString()),
        tFullName: pers.getString(' tFulName') ?? '',
        posit: pers.getString(' osit') ?? '',
        token: pers.getString(' oken') ?? '',
        logInDate: DateTime.parse(
            pers.getString(' logInate)') ?? DateTime.now().toString()));
  }

  Future<List<MOtInfo>> fetchDataOT() async {
    final formatYMD = DateFormat("yyyyMMdd");
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getot'),
        headers: <String, String>{
          'Content-type': 'application/json; charset: UTF-8;',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'DateStart': formatYMD
              .format(DateTime.now().subtract(const Duration(hours: 8))),
          'DateEnd': formatYMD.format(
              DateTime.now().subtract(const Duration(days: 6, hours: 16))),
          'EmpCode': oAccount!.code
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
                                  return ListTile(
                                    title: Text(
                                        '${snapshot.data![index].shift} : ${snapshot.data![index].strDate}'),
                                    subtitle: Text(
                                        'By : ${snapshot.data![index].status}'),
                                    trailing: (snapshot.data![index].status == "APPROVE")
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
