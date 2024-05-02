import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List members;
  final String lastMessageAt;
  final Map lastOpen;
  final String text;
  final String lastMessageMe;

  final String offerRequestId;
  final String offerId;
  final Map userRoles;

  ChatModel(
      {required this.id,
      required this.lastOpen,
      required this.members,
      required this.lastMessageMe,
      required this.lastMessageAt,
      required this.offerId,
      required this.offerRequestId,
      required this.userRoles,
      required this.text});

  factory ChatModel.fromJson(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    String id = snapshot.id;
    return ChatModel(
        id: id,
        userRoles: {},
        members: data['members'] ?? [],
        offerId: data['offerId'] ?? '',
        offerRequestId: data['offerRequestId'] ?? '',
        lastOpen: data['lastOpen'] ?? {},
        lastMessageMe: data['lastMessageMe'] ?? '',
        lastMessageAt:
            data['lastMessageAt'] ?? DateTime.now().toLocal().toIso8601String(),
        text: data['text'] ?? '');
  }
}
