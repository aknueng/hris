import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris/models/md_medical.dart';
import 'package:http/http.dart' as http;

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  late Future<MedicalInfo> oMedical;

  @override
  void initState() {
    super.initState();
    oMedical = fetchData();
  }

  void refreshData() {
    setState(() {
      oMedical = fetchData();
      print(oMedical);
    });
  }

  Future<MedicalInfo> fetchData() async {
    var empcode = '40865';
    var token =
        'eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTUxMiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IjQwODY1IiwiZXhwIjoxNjkzMjI4MTUzfQ.F7oWt0C5I1tbquLfLaobV7GtpSzLzoujGFkmfj6LkqCDpHeBEtPfZ497b_XqlQThdfBUVfrwh74lQ_aU0R0gCg';
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/getMedical'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': empcode,
        }));
    if (response.statusCode == 200) {
      return MedicalInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('fail load data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleBody = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('ค่ารักษาพยาบาล (Medical)'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
        ),
        body: Container(
          child: FutureBuilder<MedicalInfo>(
              future: oMedical,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('ค่ารักษาพยาบาล'),
                              subtitle: Text(
                                  'วงเงินรวมไม่เกิน (${snapshot.data!.oPDAllow} บาท)'),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Err: ${snapshot.error} ');
                }

                return const CircularProgressIndicator();
              }),
        ));
  }
}
