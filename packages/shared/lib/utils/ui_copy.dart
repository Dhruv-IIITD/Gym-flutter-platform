class UiCopy {
  static const emptyChat = 'No messages yet. Start the conversation.';
  static const emptyChatCta = 'Say hi';
  static const requestSent = 'Call requested. Waiting for trainer approval.';
  static String approved(String date, String time) =>
      'Call approved for $date $time.';
  static String declined(String reason) =>
      'Call request declined. Reason: $reason.';
  static const joinPrompt = 'Ready to join? Check mic and camera.';
  static const ended = 'Session saved to your logs.';
  static const noSessions = 'Schedule your first call';
}
