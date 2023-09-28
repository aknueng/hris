import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hris/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  final frmProfileChgKey = GlobalKey<FormState>();
  bool obscureTxtPwdOld = true;
  bool obscureTxtPwd1New = true;
  bool obscureTxtPwd2New = true;
  String telEmp = '';

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      if (oAccount == null || oAccount!.code == '' || oAccount!.token == '') {
        Navigator.pushNamed(context, '/login');
      }
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

      telEmp = oAccount!.telephone;
    });
  }

  Future changeProfile(String paramEmpCode, String paramTelephone) async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/updateprofile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'EmpCode': paramEmpCode,
          'Telephone': paramTelephone,
          'UpdateBy': oAccount!.code
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('code');
      prefs.remove('name');
      prefs.remove('surn');
      prefs.remove('shortName');
      prefs.remove('fullName');
      prefs.remove('tName');
      prefs.remove('tSurn');
      prefs.remove('joinDate');
      prefs.remove('tFullName');
      prefs.remove('posit');
      prefs.remove('token');
      prefs.remove('telephone');
      prefs.remove('logInDate');
      setState(() {
        oAccount = MAccount(
            code: '',
            name: '',
            surn: '',
            shortName: '',
            fullName: '',
            tName: '',
            tSurn: '',
            joinDate: DateTime.now(),
            tFullName: '',
            posit: '',
            token: '',
            role: '',
            telephone: '',
            logInDate: DateTime.now());
      });

      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(30),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Expanded(child: Text('ข้อมูลไม่ถูกต้อง')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(30),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลส่วนตัว (Profile)'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.surface,
      ),
      body: Form(
        key: frmProfileChgKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 35,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black38.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0)
              ]),
              child: TextFormField(
                  initialValue: oAccount!.fullName,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: 'ชื่อ-นามสกุล',
                      labelText: 'ชื่อ-นามสกุล',
                      fillColor: Colors.blue[50],
                      filled: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(10),
                      prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(FontAwesomeIcons.user)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.orangeAccent)))),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black38.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0)
              ]),
              child: TextFormField(
                  initialValue: oAccount!.posit,
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: 'ตำแหน่ง',
                      labelText: 'ตำแหน่ง',
                      fillColor: Colors.blue[50],
                      filled: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(10),
                      prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(FontAwesomeIcons.user)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.orangeAccent)))),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.black38.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0)
              ]),
              child: TextFormField(
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                    MinLengthValidator(10,
                        errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป'),
                  ]),
                  onSaved: (tel) {
                    setState(() {
                      telEmp = tel.toString();
                    });
                  },
                  initialValue: telEmp,
                  maxLength: 10,
                  decoration: InputDecoration(
                      hintText: 'เบอร์โทรศัพท์',
                      labelText: 'เบอร์โทรศัพท์',
                      fillColor: Colors.lime[50],
                      filled: true,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(10),
                      prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(FontAwesomeIcons.phone)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.orangeAccent)))),
            ),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                  onPressed: () async {
                    frmProfileChgKey.currentState!.save();

                    if (frmProfileChgKey.currentState!.validate()) {
                      changeProfile(oAccount!.code, telEmp);
                    }
                    //frmPwdChgKey.currentState!.reset();
                  },
                  child: const Text('บันทึกข้อมูลส่วนตัว')),
            ),
          ],
        ),
      ),
    );
  }
}
