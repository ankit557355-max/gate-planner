import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakSlotStart(String subject, String time) async {
    await speak('$time बज गए। अब $subject शुरू करो। मेहनत करो, AIR 100 तुम्हारा इंतज़ार कर रहा है!');
  }

  Future<void> speakBreak() async {
    await speak('Break time! एक घंटे के लिए आराम करो। तुमने बहुत अच्छा काम किया।');
  }

  Future<void> speakMorning(String name, String quote) async {
    await speak('Good morning $name! आज का दिन शानदार होगा। $quote');
  }

  Future<void> speakSlotDone(String subject) async {
    await speak('$subject slot complete! बहुत अच्छा, आगे बढ़ते रहो!');
  }

  Future<void> speakMilestone(int streak) async {
    await speak('वाह! $streak दिन की streak पूरी हो गई! तुम कमाल के हो। GATE AIR 100 तुम्हारा है!');
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
