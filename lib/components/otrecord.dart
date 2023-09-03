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
  Future<List<MOtInfo>>? oAryOT;
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  final formatYMD = DateFormat("yyyyMMdd");
  // final List<MOTJob> oAryOTJob = [
  //   MOTJob(dataValue: 'A', dataDisplay: 'A : งาน'),
  //   MOTJob(dataValue: 'B', dataDisplay: 'B : งาน'),
  //   MOTJob(dataValue: 'C', dataDisplay: 'C : งาน'),
  //   MOTJob(dataValue: 'D', dataDisplay: 'D : งาน'),
  //   MOTJob(dataValue: 'E', dataDisplay: 'E : งาน'),
  //   MOTJob(dataValue: 'F', dataDisplay: 'F : งาน'),
  //   MOTJob(dataValue: 'G', dataDisplay: 'G : งาน'),
  // ];
  List<String>? _selectOTJob;

  List<DropdownMenuItem<String>> oAryOTJob = [
    const DropdownMenuItem<String>(value: '', child: Text('เลือกงาน')),
    const DropdownMenuItem<String>(value: 'A', child: Text('A : งาน')),
    const DropdownMenuItem<String>(value: 'B', child: Text('B : งาน')),
    const DropdownMenuItem<String>(value: 'C', child: Text('C : งาน')),
    const DropdownMenuItem<String>(value: 'D', child: Text('D : งาน')),
    const DropdownMenuItem<String>(value: 'E', child: Text('E : งาน')),
    const DropdownMenuItem<String>(value: 'F', child: Text('F : งาน')),
    const DropdownMenuItem<String>(value: 'G', child: Text('G : งาน')),
  ];

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      if (oAccount == null || oAccount!.code == '') {
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


  showConfirmDialog(BuildContext contexxt, MOtInfo mOT ) {
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
          const Text('ยกเลิกการร้องขอOT วันที่ '),
          Expanded(
            child: Text('${mOT.strDate} ?',
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

  Future getValidateAccount() async {
    final SharedPreferences pers = await SharedPreferences.getInstance();
    setState(() {
      oAccount = MAccount(
          code: pers.getString('code') ?? '',
          name: pers.getString('name') ?? '',
          surn: pers.getString('surn') ?? '',
          shortName: pers.getString('shortName') ?? '',
          fullName: pers.getString('fullName') ?? '',
          tName: pers.getString('tName') ?? '',
          tSurn: pers.getString('tSurn') ?? '',
          joinDate: DateTime.parse(
              pers.getString('joinDate') ?? DateTime.now().toString()),
          tFullName: pers.getString('tFullName') ?? '',
          posit: pers.getString('posit') ?? '',
          token: pers.getString('token') ?? '',
          logInDate: DateTime.parse(
              pers.getString('logInDate)') ?? DateTime.now().toString()));
    });
  }

  Future requestOT(
      String paramOTDate, String paramOTType, String paramOTJob) async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/reqot'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'empCode': oAccount!.code,
          'empShortName': oAccount!.shortName,
          'otDate': paramOTDate,
          'otType': paramOTType,
          'otJob': paramOTJob,
          'empWType': 'S',
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      refreshData();
    }
  }

  Future<List<MOtInfo>> fetchDataOT() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getot'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': oAccount!.code,
          'DateStart': formatYMD
              .format(DateTime.now().subtract(const Duration(hours: 8))),
          'DateEnd': formatYMD
              .format(DateTime.now().add(const Duration(days: 6, hours: 16))),
        }));

    if (response.statusCode == 200) {
      _selectOTJob = [];

      Future<List<MOtInfo>> data =
          compute((message) => parseOTList(response.body), response.body);
      data.then((value) {
        for (var i = 0; i < value.length; i++) {
          _selectOTJob!.add('');
        }
      });

      return data;

      // return compute((message) => parseOTList(response.body), response.body);
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
    final theme = Theme.of(context);
    TextStyle txtBold =
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
    TextStyle txtBrown = const TextStyle(
      color: Colors.orange,
    );
    TextStyle txtBlue = const TextStyle(
      color: Colors.blue,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทำโอที (Overtime)'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: FutureBuilder<List<MOtInfo>>(
            future: oAryOT,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                        child: snapshot.data!.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  bool canRequest = false;

                                  if (snapshot.data![index].dateNow == "YES") {
                                    canRequest = (DateTime.now().hour < 13)
                                        ? true
                                        : false;
                                  } else {
                                    canRequest = true;
                                  }

                                  String otType = "";
                                  String timePeriod = "";
                                  if (snapshot.data![index].status == "") {
                                    if (snapshot.data![index].shift == "D") {
                                      timePeriod = "18:15 - 20:00";
                                      otType = "A";
                                    }
                                    if (snapshot.data![index].shift == "HD") {
                                      timePeriod = "08:00 - 20:00";
                                      otType = "F";
                                    }
                                    if (snapshot.data![index].shift == "N") {
                                      timePeriod = "06:05 - 07:50";
                                      otType = "D";
                                    }
                                    if (snapshot.data![index].shift == "HN") {
                                      timePeriod = "20:00 - 07:50";
                                      otType = "K";
                                    }
                                  } else if (snapshot.data![index].status ==
                                      "") {
                                  } else {
                                    timePeriod =
                                        '${snapshot.data![index].otStart} - ${snapshot.data![index].otEnd}';
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                              blurRadius: 10,
                                              spreadRadius: 0,
                                              blurStyle: BlurStyle.outer,
                                              color: Colors.black12)
                                        ]),
                                    child: ListTile(
                                      tileColor:
                                          (snapshot.data![index].status ==
                                                  "APPROVE")
                                              ? Colors.greenAccent[100]
                                              : theme.colorScheme.surface,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '(${snapshot.data![index].shift})  ',
                                            style:
                                                (snapshot.data![index].shift ==
                                                            "D" ||
                                                        snapshot.data![index]
                                                                .shift ==
                                                            "N")
                                                    ? txtBlue
                                                    : txtBrown,
                                          ),
                                          Text(
                                            '${snapshot.data![index].strDate}',
                                            style: txtBold,
                                          ),
                                          (snapshot.data![index].status == "" &&
                                                  canRequest)
                                              ? Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: DropdownButton(
                                                      value:
                                                          _selectOTJob![index],
                                                      items: oAryOTJob,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectOTJob![index] =
                                                              value!;
                                                          // print(_selectOTJob![
                                                          //     index]);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const Text('')
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 35),
                                        child: Row(
                                          children: [
                                            const Text('เวลา '),
                                            Text(
                                              timePeriod,
                                              style: txtBold,
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: (snapshot.data![index].status ==
                                              "")
                                          ? (canRequest)
                                              ? ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.yellow[100],
                                                      foregroundColor:
                                                          Colors.black,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20)),
                                                  onPressed: () {
                                                    if (_selectOTJob![index] !=
                                                        '') {
                                                      requestOT(
                                                          formatYMD.format(
                                                              snapshot
                                                                      .data![
                                                                          index]
                                                                      .otDate ??
                                                                  DateTime
                                                                      .now()),
                                                          otType,
                                                          _selectOTJob![index]);
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Center(
                                                            child: Text(
                                                                'กรุณาเลือกงาน ก่อนกดร้องขอ OT'),
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  30),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child:
                                                      const Text('ร้องขอ OT'))
                                              : const Text(' ')
                                          : (snapshot.data![index].status ==
                                                  "REQUEST")
                                              ? (canRequest)
                                                  ? ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors
                                                              .redAccent[400],
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  20)),
                                                      onPressed: () {
                                                        showConfirmDialog(context, snapshot.data![index] );

                                                      },
                                                      child:
                                                          const Text('ยกเลิก OT'))
                                                  : const Text('')
                                              : const Text(''),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(
                                          height: 5,
                                        ),
                                itemCount: snapshot.data!.length)
                            : const Center(child: Text('ไม่พบรายการ'))),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            }),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: refreshData,
      //   child: const Icon(FontAwesomeIcons.rotate),
      // ),
    );
  }
}
