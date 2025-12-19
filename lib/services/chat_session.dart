class ChatSession {
  static final List<Map<String, String>> messages = [];

  static void addUserMessage(String text) {
    messages.add({'sender': 'user', 'text': text});
  }

  static void addAiMessage(String text) {
    messages.add({'sender': 'ai', 'text': text});
  }

  static void clear() {
    messages.clear();
  }
}
