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
  bool onPress = false;
  int cnt = 0;

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

  void countDown() {
    int count = 5;
    setState(() {
      onPress = true;
    });
    for (var i = 0; i < count; i++) {
      setCount();
    }
  }

  void setCount() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        debugPrint('count : $cnt [$onPress]');
        cnt = (cnt >= 5) ? 0 : cnt++;
        onPress = (cnt >= 5) ? false : true;
      });
    });
  }

  Future toggleRecording() => SpeechApi.toogleRecording(
        onResult: (text) {
          setState(() {
            listenText = text;
            //debugPrint('set result : $isListening  | $listenText');
          });
        },
        onListening: (isListening) {
          setState(() {
            this.isListening = isListening;
          });

          // debugPrint('before : $isListening');
          // if (!isListening) {
          //   Future.delayed(const Duration(seconds: 3), () {
          //     debugPrint('in before : $isListening  | $listenText');
          //     Utils.scanText(listenText);

          //     debugPrint('in after : $isListening  | $listenText');
          //   });
          // }

          // debugPrint('after : $isListening');
        },
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle fntSmall = const TextStyle(
      fontSize: 16,
    );
    TextStyle fntTitle = const TextStyle(
      fontSize: 22,
    );
    return Scaffold(
      appBar: AppBar(
          title: const Text('DCI-X (VOICE)'),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.surface),
      body: Column(
        children: [
          Text('กรุณาบอกสิ่งที่ต้องการให้ช่วยเหลือ : $cnt/5', style: fntTitle),
          Wrap(
            children: [
              Text(
                listenText,
                style: fntSmall,
              ),
            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: onPress,
        endRadius: 80,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          onPressed: () {
            countDown();
            toggleRecording().whenComplete(
              () {
                if (!isListening) {
                  Future.delayed(const Duration(seconds: 5), () {
                    Utils.scanText(listenText);
                  });
                }
              },
            );
          },
          child: Icon((isListening) ? Icons.mic : Icons.mic_off, size: 36),
        ),
      ),
    );
  }
}
