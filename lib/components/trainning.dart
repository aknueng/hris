import 'package:flutter/material.dart';
import 'package:hris/models/md_account.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  @override
  void initState(){
    super.initState();
    getValidateAccount().whenComplete(() {
      if(oAccount == null || oAccount!.code == ''){
        Navigator.pushNamed(context, '/login');
      }

    });
  }

  void refreshData(){
    setState(() {
      
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
              prefs.getString('logInDate)') ?? DateTime.now().toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('ฝึกอบรม (Training Record)'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface),
    );
  }
}
