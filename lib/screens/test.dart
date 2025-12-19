import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceTestScreen extends StatefulWidget {
  const VoiceTestScreen({super.key});

  @override
  State<VoiceTestScreen> createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  final VoiceService _voice = VoiceService();
  String _text = '';

  @override
  void initState() {
    super.initState();
    _voice.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Test')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_text),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _voice.startListening(
                onResult: (t) {
                  setState(() => _text = t);
                },
              );
            },
            child: const Text('Start Listening'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _voice.stopListening();
              await _voice.speak(_text);
            },
            child: const Text('Stop & Speak'),
          ),
        ],
      ),
    );
  }
}
