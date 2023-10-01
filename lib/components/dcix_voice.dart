import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  String listenText = '';
  bool isListening = false;
  bool onPress = false;

  static const maxSecond = 6;

  int seconds = maxSecond;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    getValidateAccount().whenComplete(
      () {
        if (oAccount == null ||
            oAccount!.code == '' ||
            oAccount!.code.isEmpty) {
          // Navigator.pushNamed(context, '/login');
          Get.offAllNamed('/login');
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

  void startTimer({bool reset = true}) {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          onPress = true;
          seconds--;
        });
      } else {
        stopTimer(reset: true);
      }
    });
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }

    setState(() {
      timer?.cancel();
    });
  }

  void resetTimer() {
    seconds = maxSecond;
    setState(() {
      onPress = false;
    });
  }

  Future toggleRecording() => SpeechApi.toogleRecording(
        onResult: (text) {
          setState(() {
            listenText = 'คุณ: $text';
            //debugPrint('set result : $isListening  | $listenText');
          });
        },
        onListening: (isListening) {
          setState(() {
            this.isListening = isListening;
          });
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

    final isRunning = timer == null ? false : timer!.isActive;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            title: const Text('DCI-X (VOICE)'),
            centerTitle: false,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.leftLong),
              onPressed: () => Get.offAllNamed('/'),
            ),),
        body: Column(
          children: [
            Text('DCI-X : บอกสิ่งที่ต้องการให้ช่วยเหลือ ?', style: fntTitle),
            const SizedBox(height: 10),
            (isRunning) ? buildTimer() : const Text(''),
            (isRunning) ? const SizedBox(height: 10) : const Text(''),
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
          repeat: true,
          showTwoGlows: true,
          glowColor: Theme.of(context).primaryColor,
          child: FloatingActionButton(
            onPressed: () {
              startTimer();
              toggleRecording().whenComplete(
                () {
                  if (!isListening) {
                    Future.delayed(const Duration(seconds: maxSecond), () {
                      Utils.scanText(listenText);
                    });
                  }
                },
              );
            },
            child: Icon((onPress) ? Icons.mic : Icons.mic_off, size: 36),
          ),
        ),
      ),
      onWillPop: () async {
        Get.offAllNamed('/');
        return false;
      },
    );
  }

  Widget buildTimer() {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            color: Colors.green,
            strokeWidth: 20,
            value: seconds / maxSecond,
          ),
          Center(
            child: buildTime(),
          )
        ],
      ),
    );
  }

  Widget buildTime() {
    return Text(
      '$seconds',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green,
        fontSize: 28,
      ),
    );
  }
}
