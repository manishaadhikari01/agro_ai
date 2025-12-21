import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import '../services/token_service.dart';
import '../services/chat_session.dart';
import 'login_screen.dart';

import '../services/voice_service.dart';
import '../services/voiceservice.dart';
import 'voice_chat_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final VoiceService _voice = VoiceService();
  final VoiceService1 _voice1 = VoiceService1();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _voice.init();

    _initVoice();
  }

  Future<void> _initVoice() async {
    bool ok = await _voice1.init();
    if (!ok) {
      print("Speech service not available or permission denied");
    }
  }

  Future<void> _checkAuth() async {
    final token = await TokenService.getAccessToken();

    if (token == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _isLoading) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      ChatSession.addUserMessage(userMessage);
      _isLoading = true;
    });

    try {
      final aiResponse = await ChatbotService.sendMessage(userMessage);

      if (aiResponse == '__AUTH_REQUIRED__' ||
          aiResponse == '__SESSION_EXPIRED__') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      setState(() {
        ChatSession.addAiMessage(aiResponse);
      });
    } catch (e) {
      setState(() {
        ChatSession.addAiMessage(
          'Sorry, I\'m having trouble connecting right now.',
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ChatSession.messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('AI Farming Assistant'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                ChatSession.clear();
              });
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && _isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final message = messages[index];
                    final isUser = message['sender'] == 'user';

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.green.shade700 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Row(
                  children: [
                    // 🎤 MIC BUTTON
                    IconButton(
                      icon: Icon(
                        _voice.isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.green.shade700,
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_voice.isListening) {
                                  await _voice.stopListening();
                                } else {
                                  await _voice.startListening(
                                    onResult: (text) {
                                      setState(() {
                                        _controller.text = text;
                                      });
                                    },
                                  );
                                }
                              },
                    ),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ask me about farming...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      backgroundColor:
                          _isLoading ? Colors.grey : Colors.green.shade700,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 🎧 VOICE CHAT BUTTON (RIGHT SIDE, ABOVE INPUT BAR)
          Positioned(
            bottom: 90, // ⬅️ controls vertical distance above input bar
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.green.shade700,
              tooltip: 'Voice Chat',
              child: const Icon(Icons.headset_mic),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
