import 'package:flutter/material.dart';
import 'package:hris/main.dart';
import 'package:url_launcher/url_launcher.dart';

class PatternMain {
  static const pd01 = 'ยอดการผลิต';
  static const pd02 = 'อันดงบอร์ด';
  static const pd03 = 'แผนการผลิต';
  static const hrm01 = 'โอที';
  static const hrm04 = 'ot';
  static const hrm02 = 'ลางาน';
  static const hrm03 = 'รักษาพยาบาล';
}

class PatternLine {
  static const pd01 = 'ยอดการผลิต';
  static const pd02 = 'อันดงบอร์ด';
  static const pd03 = 'แผนการผลิต';
  static const hrm01 = 'โอที';
  static const hrm04 = 'ot';
  static const hrm02 = 'ลางาน';
  static const hrm03 = 'รักษาพยาบาล';
}

class PatternPeriod {
  static const pd01 = 'ยอดการผลิต';
  static const pd02 = 'อันดงบอร์ด';
  static const pd03 = 'แผนการผลิต';
  static const hrm01 = 'โอที';
  static const hrm04 = 'ot';
  static const hrm02 = 'ลางาน';
  static const hrm03 = 'รักษาพยาบาล';
}

class Utils {
  static void scanText(String rawText) {
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    BuildContext? context = NavigationService.navigatorKey.currentContext;

    final txtListen = rawText.toLowerCase();
    if (txtListen.contains(PatternMain.pd01)) {
      final body = _getTextAfterCommand(text: txtListen, command: PatternMain.pd01);
      // debugPrint('go to PD Result');
      openEmail(body: body);
    } else if (txtListen.contains(PatternMain.pd02)) {
      final url = _getTextAfterCommand(text: txtListen, command: PatternMain.pd02);
      // debugPrint('go to Andon');
      openLink(url: url);
    } else if (txtListen.contains(PatternMain.pd03)) {
      final url = _getTextAfterCommand(text: txtListen, command: PatternMain.pd03);
      // debugPrint('go to PD Plan');
      openLink(url: url);
    } else if (txtListen.contains(PatternMain.hrm01) ||
        txtListen.contains(PatternMain.hrm04)) {
      // debugPrint('go to OT');

      Navigator.pushNamedAndRemoveUntil(
        context!,
        '/ot',
        (route) => true,
      );
    } else if (txtListen.contains(PatternMain.hrm02)) {
      // debugPrint('go to LV');
      Navigator.pushNamedAndRemoveUntil(
        context!,
        '/lv',
        (route) => true,
      );
    } else if (txtListen.contains(PatternMain.hrm03)) {
      // debugPrint('go to MED');

      Navigator.pushNamedAndRemoveUntil(
        context!,
        '/med',
        (route) => true,
      );
    } else {
      // debugPrint('not match [$txtListen] ');
    }
  }

  static String _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return '';
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static Future openLink({
    required String url,
  }) async {
    if (url.trim().isEmpty) {
      await _launchUrl('https://google.com');
    } else {
      await _launchUrl('https://$url');
    }
  }

  static Future openEmail({
    required String body,
  }) async {
    final url = 'mailto: ?body=${Uri.encodeFull(body)}';
    await _launchUrl(url);
  }

  static Future _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
