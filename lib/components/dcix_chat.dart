import 'package:flutter/material.dart';
import 'package:hris/models/md_account.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;

  @override
  void initState() {
    super.initState();
    getValidateAccount().whenComplete(
      () {
        if (oAccount == null ||
            oAccount!.code == '' ||
            oAccount!.code.isEmpty) {
          Navigator.pushNamed(context, '/login');
        }
      },
    );
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
              prefs.getString('logInDate)') ?? DateTime.now().toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle fntSmall = const TextStyle(
      fontSize: 12,
    );
    TextStyle fntTitle = const TextStyle(
      fontSize: 18,
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text('DCI-X (CHAT BOT)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface),
      body: Column(
        children: [
          Text('กรุณาบอกสิ่งที่ต้องการให้ช่วยเหลือ', style: fntTitle),
        ],
      ),
    );
  }
}
