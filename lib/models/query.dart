class Query {
  final String id;
  final String userId;
  final String question;
  final String? response;
  final DateTime timestamp;

  Query({
    required this.id,
    required this.userId,
    required this.question,
    this.response,
    required this.timestamp,
  });

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      question: json['question'] ?? '',
      response: json['response'],
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'question': question,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
