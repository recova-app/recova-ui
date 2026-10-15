/// Individual chat message entity in AI coach conversations.
class CoachChatMessage {
  final String text;
  final bool isAI;
  final DateTime createdAt;
  final String? personaKey;

  const CoachChatMessage({
    required this.text,
    required this.isAI,
    required this.createdAt,
    this.personaKey,
  });
}
