import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel {
  //  'title': title,
  //   'subTitle': subtitle,
  //   'createdAt': DateTime.now().toLocal().toIso8601String(),
  //   'senderId': notificationSender.userId,
  //   'senderName': notificationSender.name,
  //   'type': type, 
  //   'isRead': false,
  //   'objectId': objectId,
  final String title;
  final String subTitle;
  final String createdAt;
  final String senderId;
  final String senderName;
  final String type;
  final bool isRead;
  final String objectId;
  final String id;


  NotificationsModel(
      {required this.title,
      required this.subTitle,
      required this.createdAt,
      required this.senderId,
      required this.senderName,
      required this.type,
      required this.isRead,
      required this.id,
      required this.objectId});

  factory NotificationsModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    String id = snapshot.id;
    return NotificationsModel(
        title: data['title'],
        subTitle: data['subTitle'],
        createdAt: data['createdAt'],
        senderId: data['senderId'],
        senderName: data['senderName'],
        type: data['type'],
        isRead: data['isRead'],
        id: id,
        objectId: data['objectId']);
  }
}
