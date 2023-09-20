import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechApi {
  static final _speech = SpeechToText();

  static Future<bool> toogleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    debugPrint('start call: ${_speech.isListening}');

    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (e) => debugPrint('Error: $e'),
    );

    if (isAvailable) {
      // _speech.listen(onResult: (value) => onResult(value.recognizedWords));
      _speech.listen(
          localeId: 'th_TH',
          onResult: (result) => onResult(result.recognizedWords));
    }

    debugPrint('mic status : ${_speech.isListening}');
    return isAvailable;
  }
}
