import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hris/models/md_account.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Initially password is obscure
  bool _obscureText = true;
  String _password = '';
  String _username = '';

  final formKey = GlobalKey<FormState>();
  late Future<MAccount> oAccount;

  @override
  void initState() {
    super.initState();
    oAccount = fetchData();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void checkLogin() {
    setState(() {
      oAccount = fetchData();

      oAccount.then((acc) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        if (acc.code != '' && acc.code != null) {
          prefs.setString('code', acc.code);
          prefs.setString('name', acc.name);
          prefs.setString('surn', acc.surn);
          prefs.setString('shortName', acc.shortName);
          prefs.setString('fullName', acc.fullName);
          prefs.setString('tName', acc.tName);
          prefs.setString('tSurn', acc.tSurn);          
          prefs.setString('joinDate', acc.joinDate.toString());
          prefs.setString('tFullName', acc.tFullName);
          prefs.setString('posit', acc.posit);          
          prefs.setString('token', acc.token);
          prefs.setString('logInDate', acc.logInDate.toString());

          if(context.mounted) Navigator.pushNamed(context, '/');
        } else {}
      });
    });
  }

  Future<MAccount> fetchData() async {
    final response = await http.post(
        Uri.parse('https://scm.dci.co.th/hrisapi/api/Authen'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode(<String, String>{"user": _username, "pass": _password}));
    if (response.statusCode == 200) {
      // print(response.body);
      //return MAccount.fromJson(jsonDecode(response.body));
      return MAccount.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      return MAccount(
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
          logInDate: DateTime.now());
    } else {
      throw Exception('fail load data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 0)
                ]),
                child: TextFormField(
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'กรุณากรอกรหัสพนักงาน'),
                    MinLengthValidator(5, errorText: 'รหัสพนักงาน 5 ตัวอักษร')
                  ]),
                  onSaved: (usr) {
                    _username = usr.toString();
                  },
                  decoration: InputDecoration(
                    hintText: 'รหัสพนักงาน',
                    fillColor: Colors.lime[50],
                    filled: true,
                    contentPadding: const EdgeInsets.all(10),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(FontAwesomeIcons.user),
                    ),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(FontAwesomeIcons.starOfLife),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 50, right: 50),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 0)
                ]),
                child: TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                      MinLengthValidator(6,
                          errorText: 'กรุณากรอกรหัสผ่าน 6 ตัวอักษรขึ้นไป')
                    ]),
                    onSaved: (pwd) {
                      _password = pwd.toString();
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                        hintText: 'รหัสผ่าน',
                        fillColor: Colors.lime[50],
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(FontAwesomeIcons.key)),
                        suffixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                                onPressed: () {
                                  _toggle();
                                },
                                icon: (_obscureText)
                                    ? const Icon(FontAwesomeIcons.starOfLife)
                                    : const Icon(FontAwesomeIcons.eye))),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none))),
              ),
              // ElevatedButton(
              //     onPressed: () async {
              //       if (formKey.currentState!.validate()) {
              //         formKey.currentState!.save();
              //         checkLogin();
              //       }
              //       //formKey.currentState!.reset();
              //     },
              //     child: Text('Login')),
              const SizedBox(
                height: 30,
              ),
              FutureBuilder<MAccount>(
                  future: oAccount,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done &&
                        snapshot.data!.code != '') {
                      return Text(
                          ' log in - ${snapshot.data!.code} ${snapshot.data!.fullName}');
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              checkLogin();
                            }
                            //formKey.currentState!.reset();
                          },
                          child: const Text('Login'));
                    }
                  }),
            ],
          )),
    );
  }
}
