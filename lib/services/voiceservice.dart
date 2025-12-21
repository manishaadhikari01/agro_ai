import 'package:speech_to_text/speech_to_text.dart';

class VoiceService1 {
  final SpeechToText _speech = SpeechToText();
  bool isListening = false;

  Future<bool> init() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
      },
      onError: (error) {
        print("Speech error: $error");
      },
    );
    return available;
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_speech.isAvailable) {
      print("Speech not available");
      return;
    }

    isListening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    isListening = false;
    await _speech.stop();
  }
}
