import 'dart:convert';
//import 'dart:ui_web';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_lv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  Future<List<MLVInfo>>? oAryLV;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(
      () {
        if (oAccount == null || oAccount!.code == '') {
          Navigator.pushNamed(context, '/login');
        }

        oAryLV = fetchLVData();
      },
    );
  }

  showConfirmDialog(BuildContext contexxt, MLVInfo mLV, String lvType) {
    Widget btnConfirm = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.red[100],
            ),
        onPressed: () {
          refreshData();
          Navigator.of(context).pop();
        },
        icon: Icon(
          FontAwesomeIcons.circleCheck,
          color: Colors.blue[900],
        ),
        label: Text(
          'ยืนยัน',
          style:
              TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
        ));

    Widget btnCancel = ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(FontAwesomeIcons.circleXmark, color: Colors.red[900]),
        label: Text('ปิด',
            style: TextStyle(
                color: Colors.red[900], fontWeight: FontWeight.bold)));

    AlertDialog alDlg = AlertDialog(
      title: const Text('ยืนยันการยกเลิกรายการ'),
      backgroundColor: Colors.white,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('ยกเลิกการร้องขอการ'),
          Expanded(
            child: Text(
              '$lvType วันที่ ${mLV.cDate} ?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      actions: [btnConfirm, btnCancel],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alDlg;
      },
    );
  }

  void refreshData() {
    setState(() {
      oAryLV = fetchLVData();
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
              prefs.getString('logInDate') ?? DateTime.now().toString()));
    });
  }

  Future<List<MLVInfo>> fetchLVData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getlv'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.code,
          'dateStart': formatYMD
              .format(DateTime.now().subtract(const Duration(days: 90))),
          'dateEnd':
              formatYMD.format(DateTime.now().add(const Duration(days: 30)))
        }));

    if (response.statusCode == 200) {
      Future<List<MLVInfo>> data =
          compute((message) => parseLVList(response.body), response.body);
      data.then((value) => value.sort((a, b) => b.cDate.compareTo(a.cDate)));
      return data;
    } else {
      throw ('failed to load data');
    }
  }

  List<MLVInfo> parseLVList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<MLVInfo>((json) => MLVInfo.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขาด ลา มาสาย (Leave Record)'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: FutureBuilder<List<MLVInfo>>(
        future: oAryLV,
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
                          String lvtype = "", lvStatus = "";
                          Color? lvStatusCorlor;
                          if (snapshot.data![index].type == "ANNU") {
                            lvtype = 'ลาพักร้อน';
                          } else if (snapshot.data![index].type == "SICK") {
                            lvtype = 'ลาป่วย';
                          } else if (snapshot.data![index].type == "BUSI") {
                            lvtype = 'พักร้อน';
                          } else if (snapshot.data![index].type == "ABSE") {
                            lvtype = 'ขาดงาน';
                          } else if (snapshot.data![index].type == "PERS") {
                            lvtype = 'ลากิจ';
                          } else if (snapshot.data![index].type == "MONK") {
                            lvtype = 'ลาบวช';
                          } else if (snapshot.data![index].type == "CARE") {
                            lvtype = 'ลาคลอด';
                          }

                          if (snapshot.data![index].reqSTATUS == "APPROVE") {
                            lvStatus = 'อนุมัติแล้ว';
                            lvStatusCorlor = Colors.greenAccent[400]!;
                          } else if (snapshot.data![index].reqSTATUS ==
                              "REQUEST") {
                            lvStatus = 'รอการอนุมัติ';
                            lvStatusCorlor = Colors.yellow[400]!;
                          } else if (snapshot.data![index].reqSTATUS ==
                              "REJECT") {
                            lvStatus = 'ไม่อนุมัติ';
                            lvStatusCorlor = Colors.redAccent[700]!;
                          } else if (snapshot.data![index].reqSTATUS ==
                              "CANCEL") {
                            lvStatus = 'ยกเลิก';
                            lvStatusCorlor = Colors.black45;
                          }

                          return ListTile(
                            title: Row(
                              children: [
                                Text('${snapshot.data![index].cDate}  '),
                                Text(
                                  '$lvtype (${snapshot.data![index].type})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                const Text('เวลา: '),
                                Text(
                                    '${snapshot.data![index].lvFrom}-${snapshot.data![index].lvTo}'),
                                const Text(', เหตุผล : '),
                                Expanded(
                                    child: Text(snapshot.data![index].reason)),
                              ],
                            ),
                            trailing: TextButton(
                                onPressed: () {
                                  if (snapshot.data![index].reqSTATUS ==
                                      "REQUEST") {
                                  // confirm cancel leave
                                  showConfirmDialog(
                                      context, snapshot.data![index], lvtype);
                                  }
                                  
                                },
                                child: Text(
                                  lvStatus,
                                  style: TextStyle(
                                      color: lvStatusCorlor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )),
                          );
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.indigoAccent[700],
        onPressed: () {
          Navigator.pushNamed(context, '/lvreq');
        },
        child: const Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}
