import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechReady = false;
  bool _isListening = false;

  // ---------------- INIT ----------------

  Future<void> init() async {
    _speechReady = await _speech.initialize();
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  // ---------------- SPEECH → TEXT ----------------

  Future<void> startListening({required Function(String text) onResult}) async {
    if (!_speechReady || _isListening) return;

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    _isListening = false;
  }

  // ---------------- TEXT → SPEECH ----------------

  Future<void> speak(String text) async {
    await _tts.stop(); // stop previous speech
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ---------------- STATE ----------------

  bool get isListening => _isListening;
}
