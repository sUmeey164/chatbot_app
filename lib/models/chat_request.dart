class ChatRequest {
  final String sessionId;
  final String message;

  ChatRequest({required this.sessionId, required this.message});

  Map<String, dynamic> toJson() {
    return {'sessionId': sessionId, 'message': message};
  }
}
