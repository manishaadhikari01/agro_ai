import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../services/chatbot_service.dart';
import '../services/chat_session.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final VoiceService _voice = VoiceService();

  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _voice.init();
  }

  // 🎙️ Start listening
  Future<void> _startListening() async {
    if (_isSpeaking) return;

    setState(() {
      _isListening = true;
    });

    await _voice.startListening(
      onResult: (text) async {
        await _voice.stopListening();
        setState(() => _isListening = false);

        if (text.isEmpty) return;

        await _handleUserSpeech(text);
      },
    );
  }

  // 🤖 Handle user → AI → voice reply
  Future<void> _handleUserSpeech(String text) async {
    // Save user message
    ChatSession.addUserMessage(text);

    setState(() => _isSpeaking = true);

    final reply = await ChatbotService.sendMessage(text);

    // Save AI reply
    ChatSession.addAiMessage(reply);

    await _voice.speak(reply);

    setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Voice Assistant',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎤 MIC ICON
            Icon(
              _isListening
                  ? Icons.mic
                  : _isSpeaking
                  ? Icons.volume_up
                  : Icons.mic_none,
              size: 120,
              color:
                  _isListening
                      ? Colors.red
                      : _isSpeaking
                      ? Colors.green
                      : Colors.white,
            ),

            const SizedBox(height: 30),

            // 📝 STATUS TEXT
            Text(
              _isListening
                  ? 'Listening...'
                  : _isSpeaking
                  ? 'Speaking...'
                  : 'Tap to speak',
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 50),

            // 🎙️ MIC BUTTON
            GestureDetector(
              onTap: _isListening ? null : _startListening,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
