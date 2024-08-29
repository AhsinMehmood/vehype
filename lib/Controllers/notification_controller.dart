import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/offers_model.dart';
import '../Models/user_model.dart';

class NotificationController {
  Future<void> sendNotification({
    required UserModel senderUser,
    required UserModel receiverUser,
    required String offerId,
    required String? requestId,
    required String title,
    required String subtitle,
  }) async {
    const appId = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
    const restApiKey = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';
    // OneSignal.login(externalId)
    final message = {
      'app_id': appId,
      'headings': {'en': title},
      'contents': {'en': subtitle},
      'include_external_user_ids': [receiverUser.userId],
      'data': {
        'offerId': offerId,
        'type': 'request',
        'requestId': requestId,
      },
    };

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        body: jsonEncode(message),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $restApiKey',
        },
      );
      print('Notification sent: ${response.body}');
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  Future<void> sendMessageNotification({
    required UserModel senderUser,
    required UserModel receiverUser,
    required OffersModel offersModel,
    required String chatId,
    required String messageId,
  }) async {
    const appId = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
    const restApiKey = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';
    // OneSignal.login(externalId)
    final message = {
      'app_id': appId,
      'headings': {'en': 'New Message: ${offersModel.issue}'},
      'contents': {'en': '${receiverUser.name} sent you a message'},
      'include_external_user_ids': [senderUser.userId],
      'data': {
        'chatId': chatId,
        'type': 'chat',
      },
    };

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        body: jsonEncode(message),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $restApiKey',
        },
      );
      print('Notification sent: ${response.body}');
    } catch (error) {
      print('Error sending notification: $error');
    }
  }
}
