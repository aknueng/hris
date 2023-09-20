import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Command {
  static const pd01 = 'ยอดการผลิต';
  static const pd02 = 'อันดงบอร์ด';
  static const pd03 = 'แผนการผลิต';
  static const hrm01 = 'โอที';
  static const hrm04 = 'OT';
  static const hrm02 = 'ลางาน';
  static const hrm03 = 'รักษาพยาบาล';
}

class Utils {
  static void scanText(BuildContext context, String rawText) {
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    final txtListen = rawText.toLowerCase();
    if (txtListen.contains(Command.pd01)) {
      final body = _getTextAfterCommand(text: txtListen, command: Command.pd01);
      debugPrint('go to PD Result');
      openEmail(body: body);
    } else if (txtListen.contains(Command.pd02)) {
      final url = _getTextAfterCommand(text: txtListen, command: Command.pd02);
      debugPrint('go to Andon');
      openLink(url: url);
    } else if (txtListen.contains(Command.pd03)) {
      final url = _getTextAfterCommand(text: txtListen, command: Command.pd03);
      debugPrint('go to PD Plan');
      openLink(url: url);
    } else if (txtListen.contains(Command.hrm01) ||
        txtListen.contains(Command.hrm04)) {
      debugPrint('go to OT');
      Navigator.pushNamed(context, '/ot');
      // navigatorKey.currentState!.pushNamed('/ot');
    } else if (txtListen.contains(Command.hrm02)) {
      debugPrint('go to LV');
      Navigator.pushNamed(context, '/lv');
      // navigatorKey.currentState!.pushNamed('/lv');
    } else if (txtListen.contains(Command.hrm03)) {
      debugPrint('go to MED');
      Navigator.pushNamed(context, '/med');
      // navigatorKey.currentState!.pushNamed('/med');
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
