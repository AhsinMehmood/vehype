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
  final bool isAudio;
  final String audioUrl;
  final bool isLocation;
  final double lat;
  final double long;

  MessageModel(
    
      {required this.id,
      required this.isSystemMessage,
      required this.isAudio,
      required this.sentAt,
      required this.sentById,
      required this.audioUrl,
      required this.thumbnailUrl,
      required this.isVideo,
      required this.mediaUrl,
      required this.text,
      required this.state,
      required this.isLocation,
      required this.lat,
      required this.long});
}
