class MessageModel {
  final String id;
  final String sentAt;
  final String sentById;
  final String text;
  final bool isSystemMessage;
  final String mediaUrl;
  final bool isVideo;
  final String thumbnailUrl;
  final int state;
 
  MessageModel(
      {required this.id,
      required this.isSystemMessage,
      required this.sentAt,
      required this.sentById,
      required this.thumbnailUrl,
      required this.isVideo,
      required this.mediaUrl,
      required this.text,
      required this.state});
}
