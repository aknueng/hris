import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:hris/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  final frmPwdChgKey = GlobalKey<FormState>();
  bool obscureTxtPwdOld = true;
  bool obscureTxtPwd1New = true;
  bool obscureTxtPwd2New = true;
  String pwdOld = '';
  String pwd1New = '';
  String pwd2New = '';

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(() async {
      if (oAccount == null || oAccount!.code == '' || oAccount!.token == '') {
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
      }
    });
  }

  void _toggle(String txtPwd) {
    setState(() {
      if (txtPwd == "OLD") {
        obscureTxtPwdOld = !obscureTxtPwdOld;
      } else if (txtPwd == "NEW1") {
        obscureTxtPwd1New = !obscureTxtPwd1New;
      } else if (txtPwd == "NEW2") {
        obscureTxtPwd2New = !obscureTxtPwd2New;
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
    });
  }

  Future changePassword(String paramUser, String paramOldPassword,
      String paramNewPassword) async {
    // print('>> ${formatYMD.format(paramLVDate)} $paramLVType $paramLVFrom $paramLVTo $paramReason');
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/emp/chgpass'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${oAccount!.token}',
        },
        body: jsonEncode(<String, String>{
          'user': paramUser,
          'passOld': paramOldPassword,
          'passNew': paramNewPassword
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
        // Navigator.pushNamed(context, '/login');
        Get.offAllNamed('/login');
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
            content: Expanded(child: Text('รหัสผ่านเก่าไม่ถูกต้อง')),
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
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('เปลี่ยนรหัสผ่าน (Change Password)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface,
          leading: IconButton(
              icon: const Icon(FontAwesomeIcons.leftLong),
              onPressed: () => Get.offAllNamed('/'),
            ),
        ),
        body: Form(
          key: frmPwdChgKey,
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
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                      MinLengthValidator(6,
                          errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป')
                    ]),
                    onSaved: (pwd) {
                      setState(() {
                        pwdOld = pwd.toString();
                      });
                    },
                    maxLength: 20,
                    obscureText: obscureTxtPwdOld,
                    decoration: InputDecoration(
                        hintText: 'รหัสผ่านเก่า',
                        labelText: 'รหัสผ่านเก่า',
                        fillColor: Colors.lime[50],
                        filled: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.all(10),
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(FontAwesomeIcons.key)),
                        suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                                onPressed: () {
                                  _toggle("OLD");
                                },
                                icon: (obscureTxtPwdOld)
                                    ? const Icon(
                                        FontAwesomeIcons.starOfLife,
                                        size: 10,
                                      )
                                    : const Icon(
                                        FontAwesomeIcons.eye,
                                        size: 10,
                                      ))),
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
                      MinLengthValidator(6,
                          errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป')
                    ]),
                    onSaved: (pwd) {
                      setState(() {
                        pwd1New = pwd.toString();
                      });
                    },
                    maxLength: 20,
                    obscureText: obscureTxtPwd1New,
                    decoration: InputDecoration(
                        hintText: 'รหัสผ่านใหม่',
                        labelText: 'รหัสผ่านใหม่',
                        fillColor: Colors.lime[50],
                        filled: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.all(10),
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(FontAwesomeIcons.key)),
                        suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                                onPressed: () {
                                  _toggle("NEW1");
                                },
                                icon: (obscureTxtPwd1New)
                                    ? const Icon(
                                        FontAwesomeIcons.starOfLife,
                                        size: 10,
                                      )
                                    : const Icon(
                                        FontAwesomeIcons.eye,
                                        size: 10,
                                      ))),
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
                    validator: (val) =>
                        MatchValidator(errorText: 'รหัสผ่านใหม่ไม่ตรงกัน')
                            .validateMatch(val!, pwd1New),
    
                    // validator: MultiValidator([
                    //   RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                    //   MinLengthValidator(6,
                    //       errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป'),
                    // ]),
                    onSaved: (pwd) {
                      setState(() {
                        pwd2New = pwd.toString();
                      });
                    },
                    maxLength: 20,
                    obscureText: obscureTxtPwd2New,
                    decoration: InputDecoration(
                        hintText: 'ยืนยันรหัสผ่านใหม่',
                        labelText: 'ยืนยันรหัสผ่านใหม่',
                        fillColor: Colors.lime[50],
                        filled: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.all(10),
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(FontAwesomeIcons.key)),
                        suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                                onPressed: () {
                                  _toggle("NEW2");
                                },
                                icon: (obscureTxtPwd2New)
                                    ? const Icon(
                                        FontAwesomeIcons.starOfLife,
                                        size: 10,
                                      )
                                    : const Icon(
                                        FontAwesomeIcons.eye,
                                        size: 10,
                                      ))),
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
                      frmPwdChgKey.currentState!.save();
    
                      if (frmPwdChgKey.currentState!.validate()) {
                        changePassword(oAccount!.code, pwdOld, pwd1New);
                      }
                      //frmPwdChgKey.currentState!.reset();
                    },
                    child: const Text('เปลี่ยนรหัสผ่าน')),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        Get.offAllNamed('/');
        return false;
      },
    );
  }
}
