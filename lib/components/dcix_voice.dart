import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:hris/api/speech_api.dart';
import 'package:hris/api/utils.dart';
import 'package:hris/models/md_account.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIVoiceScreen extends StatefulWidget {
  const AIVoiceScreen({super.key});

  @override
  State<AIVoiceScreen> createState() => _AIVoiceScreenState();
}

class _AIVoiceScreenState extends State<AIVoiceScreen> {
  final formatYMD = DateFormat("yyyyMMdd");
  String? code, shortName, fullName, tFullName, posit, joinDate, token;
  MAccount? oAccount;
  String listenText = 'กดเพื่อบอกสิ่งที่ต้องการ';
  bool isListening = false;

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
          logInDate: DateTime.parse(
              prefs.getString('logInDate)') ?? DateTime.now().toString()));
    });
  }

  Future toggleRecording() => SpeechApi.toogleRecording(
        onResult: (text) {
          setState(() {
            listenText = text;
          });
        },
        onListening: (isListening) {
          setState(() {
            this.isListening = isListening;
          });

          if (!isListening) {
            Future.delayed(const Duration(seconds: 1), () {
              Utils.scanText(context, listenText);
            });
          }
        },
      );

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
          title: const Text('DCI-X'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface),
      body: Column(
        children: [
          Text('กรุณาบอกสิ่งที่ต้องการให้ช่วยเหลือ', style: fntTitle),
          Text(
            listenText,
            style: fntSmall,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 80,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          onPressed: toggleRecording,
          child: Icon((isListening) ? Icons.mic : Icons.mic_off, size: 36),
        ),
      ),
    );
  }
}
