import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/const.dart';

import '../Models/garage_model.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../Pages/message_page.dart';
import '../Pages/owner_request_details_inprogress_inactive_page.dart';
import '../Pages/service_request_details.dart';
import '../Widgets/loading_dialog.dart';
import 'offers_controller.dart';
import 'user_controller.dart';
import 'package:http/http.dart' as http;

class NotificationController {
  String appId = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
  String restApiKey = 'NmZiZWJhZDktZGQ5Yi00MjBhLTk2MGQtMmQ5MWI1NjEzOWVi';
  navigateChat(Map<String, dynamic> data) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    ChatModel? chatModel = await ChatController().getSingleChat(data['chatId']);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    DocumentSnapshot<Map<String, dynamic>> secondUserQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(chatModel!.members.firstWhere((id) => id != userId))
            .get();
    UserModel secondUser = UserModel.fromJson(secondUserQuery);
    DocumentSnapshot<Map<String, dynamic>> offerQuery = await FirebaseFirestore
        .instance
        .collection('offers')
        .doc(chatModel.offerId)
        .get();
    OffersModel offersModel = OffersModel.fromJson(offerQuery);
    DocumentSnapshot<Map<String, dynamic>> garageQuery = await FirebaseFirestore
        .instance
        .collection('garages')
        .doc(offersModel.garageId)
        .get();
    GarageModel garageModel = GarageModel.fromJson(garageQuery);
    Get.close(1);
    Get.to(() => MessagePage(
        chatModel: chatModel,
        secondUser: secondUser,
        garageModel: garageModel,
        offersModel: offersModel));
  }

  void showNotificationToastForChat(
      String title,
      String message,
      BuildContext context,
      Map<String, dynamic> data,
      UserController userController) {
    // BuildContext? context = navigatorKey.currentContext;
    Get.showSnackbar(GetSnackBar(
      titleText: Text(
        title,
        style: TextStyle(
          color: userController.isDark ? Colors.white : primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark
                      ? Colors.white.withOpacity(0.5)
                      : primaryColor.withOpacity(0.5),
                )),
            height: 45,
            width: 140,
            child: Center(
              child: Text(
                'Tap to See',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      // message: message,
      snackPosition: SnackPosition.TOP,

      duration: Duration(seconds: 4),
      onTap: (snack) {
        Get.closeCurrentSnackbar();

        navigateChat(data);
      },
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      borderColor: userController.isDark
          ? Colors.white.withOpacity(0.5)
          : primaryColor.withOpacity(0.5),
    ));
  }

  navigateOwner(Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String offerId = data['offerId'];
    String requestId = data['requestId'] ?? '';
    DocumentSnapshot<Map<String, dynamic>> offerQuery =
        await firestore.collection('offers').doc(offerId).get();
    DocumentSnapshot<Map<String, dynamic>> userQuery =
        await firestore.collection('users').doc(userId).get();
    OffersModel offersModel = OffersModel.fromJson(offerQuery);
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    DocumentSnapshot<Map<String, dynamic>> garageSnap = await FirebaseFirestore
        .instance
        .collection('garages')
        .doc(offersModel.garageId)
        .get();
    OffersReceivedModel? offersReceivedModel;
    if (requestId != '') {
      DocumentSnapshot<Map<String, dynamic>> offersReceivedQuery =
          await firestore.collection('offersReceived').doc(requestId).get();
      offersReceivedModel = OffersReceivedModel.fromJson(offersReceivedQuery);
    }
    Get.close(1);
    OffersController().updateNotificationForOffers(
        offerId: offersModel.offerId,
        userId: userId,
        checkByList: offersModel.checkByList,
        isAdd: false,
        offersReceived: offersReceivedModel?.id,
        notificationTitle: '',
        senderId: userId,
        notificationSubtitle: '');
    if (UserModel.fromJson(userQuery).accountType == 'provider') {
      Get.to(() => ServiceRequestDetails(
            offersModel: offersModel,
            // chatId: chatModel.id,
            offersReceivedModel: offersReceivedModel,
          ));
      return;
    }

    if (offersModel.status == 'active') {
      Get.to(() => OwnerRequestDetailsInprogressInactivePage(
            offersModel: offersModel,
            garageModel: GarageModel.fromJson(garageSnap),
            offersReceivedModel: offersReceivedModel!,
          ));
    } else if (offersModel.status == 'inProgress' ||
        offersModel.status == 'inactive') {
      if (offersModel.offersReceived.isNotEmpty) {
        Get.to(() => OwnerRequestDetailsInprogressInactivePage(
              offersModel: offersModel,
              garageModel: GarageModel.fromJson(garageSnap),
              offersReceivedModel: offersReceivedModel!,
            ));
      }
    }
  }

  void showNotificationToast(String title, String message, BuildContext context,
      Map<String, dynamic> data, UserController userController) {
    // BuildContext? context = navigatorKey.currentContext;
    Get.showSnackbar(GetSnackBar(
      titleText: Text(
        title,
        style: TextStyle(
          color: userController.isDark ? Colors.white : primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark
                      ? Colors.white.withOpacity(0.5)
                      : primaryColor.withOpacity(0.5),
                )),
            height: 45,
            width: 140,
            child: Center(
              child: Text(
                'Tap to See',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      // message: message,
      snackPosition: SnackPosition.TOP,

      duration: Duration(seconds: 4),
      onTap: (snack) {
        Get.closeCurrentSnackbar();

        navigateOwner(data);
      },
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      borderColor: userController.isDark
          ? Colors.white.withOpacity(0.5)
          : primaryColor.withOpacity(0.5),
    ));
  }

  // listenOneSignalNotification(RemoteMessage message) {}

  Future<void> sendNotification({
    required String offerId,
    required String requestId,
    required String title,
    required String subtitle,
    required List<String> userIds,
  }) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final message = {
        'app_id': appId,
        'headings': {'en': title},
        'contents': {'en': subtitle},
        'include_external_user_ids': [sharedPreferences.getString('userId')],
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
    final message = {
      'app_id': appId,
      'headings': {'en': 'New Message: ${offersModel.issue}'},
      'contents': {'en': '${receiverUser.name} sent you a message'},
      'include_external_user_ids': [senderUser.userId],
      'data': {'chatId': chatId, 'messageId': messageId, 'type': 'chat'},
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
