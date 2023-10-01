import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
// import 'package:flutter/rendering.dart';
import 'package:hris/models/md_account.dart';
import 'package:hris/models/md_medical.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  Future<MedicalInfo>? oMedical;

  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      if (oAccount == null || oAccount!.code == '' || oAccount!.token == '') {
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
      }

      oMedical = fetchData();
    });
  }

  void refreshData() {
    setState(() {
      oMedical = fetchData();
      // print(oMedical);
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
              prefs.getString('logInDate') ?? DateTime.now().toString()));
    });
  }

  Future<MedicalInfo> fetchData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getMedical'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': oAccount!.code,
        }));
    if (response.statusCode == 200) {
      return MedicalInfo.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
      }
      throw ('failed to load data');
    } else {
      throw Exception('fail load data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final styleBody = theme.textTheme.bodyMedium!.copyWith(
    //   color: theme.colorScheme.onSurface,
    // );
    final styleFontRemain = TextStyle(
      color: Colors.blueAccent[700],
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final styleFontInfo = TextStyle(
      color: Colors.blueAccent[700],
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final styleFontDetail = TextStyle(
      color: Colors.brown[900],
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final styleFontUse = TextStyle(
      color: Colors.redAccent[700],
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    String tilte = 'นาย';
    // String idno = '1-4799-00071-20-9';

    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('ค่ารักษาพยาบาล (Medical)'),
            centerTitle: false,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.leftLong),
              onPressed: () => Get.offAllNamed('/'),
            ),
          ),
          body: SingleChildScrollView(
            child: FutureBuilder<MedicalInfo>(
                future: oMedical,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  blurStyle: BlurStyle.outer,
                                  spreadRadius: 0),
                            ],
                            color: Colors.blue[100],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, top: 5, bottom: 5, right: 25),
                            child: Text(
                              '$tilte ${oAccount!.tFullName}',
                              //'$tilte ${oAccount!.tFullName}\nเลขที่บัตรประชาชน $idno ',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.yellow[50],
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      const Text('ผู้ป่วยนอก '),
                                      Text(
                                        '(ไม่เกิน ${snapshot.data!.oPDAllow} บาท/ปี)',
                                        style: styleFontInfo,
                                      ),
                                    ],
                                  )),
                              const Divider(
                                height: 2,
                                color: Colors.orange,
                              ),
                              ListTile(
                                title: const Text('ตนเอง คู่สมรส บุตร'),
                                subtitle: Text(
                                  'ไม่เกิน (${snapshot.data!.oPDAllowFamily} บาท/ปี)',
                                  style: styleFontInfo,
                                ),
                                trailing: Text(snapshot.data!.oPDUseFamily,
                                    style: styleFontDetail),
                              ),
                              ListTile(
                                title: const Text('พ่อ แม่'),
                                subtitle: Text(
                                    'ไม่เกิน (${snapshot.data!.oPDAllowParent} บาท/ปี)',
                                    style: styleFontInfo),
                                trailing: Text(
                                  snapshot.data!.oPDUseParent,
                                  style: styleFontDetail,
                                ),
                              ),
                              ListTile(
                                title: const Text('ผดุงครรภ์'),
                                subtitle: Text(
                                    'ไม่เกิน (${snapshot.data!.oPDAllowPregnant} บาท/ปี)',
                                    style: styleFontInfo),
                                trailing: Text(
                                  snapshot.data!.oPDUsePregnant,
                                  style: styleFontDetail,
                                ),
                              ),
                              const Divider(
                                height: 2,
                                color: Colors.orange,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('รวมผู้ป่วยนอก'),
                                    Column(
                                      children: [
                                        const Text('ใช้'),
                                        Text(
                                          snapshot.data!.oPDUseTotal,
                                          style: styleFontUse,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text('คงเหลือ'),
                                        Text(
                                          snapshot.data!.oPDAllowRemain,
                                          style: styleFontRemain,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: Colors.yellow[50],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ผู้ป่วยใน'),
                                    Text(
                                      '(ไม่เกิน ${snapshot.data!.iPDAllow} บาท/ปี)',
                                      style: styleFontInfo,
                                    ),
                                    const Text('ตนเอง คู่สมรส บุตร พ่อ แม่'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('ใช้'),
                                    Text(
                                      snapshot.data!.iPDUse,
                                      style: styleFontUse,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('คงเหลือ'),
                                    Text(
                                      snapshot.data!.iPDAllowRemain,
                                      style: styleFontRemain,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: Colors.yellow[50],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('รวมค่ารักษาพยาบาล'),
                                    Text(
                                      '(ไม่เกิน ${snapshot.data!.medicalAllow} บาท/ปี)',
                                      style: styleFontInfo,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('ใช้'),
                                    Text(
                                      snapshot.data!.medicalUse,
                                      style: styleFontUse,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('คงเหลือ'),
                                    Text(
                                      snapshot.data!.medicalRemain,
                                      style: styleFontRemain,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Err: ${snapshot.error} ');
                  }
    
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          )),
          onWillPop: () async {
            Get.offAllNamed('/');
            return false;
          },
    );
  }
}
