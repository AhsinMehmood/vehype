import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';

import '../Models/user_model.dart';
import '../Pages/message_page.dart';

import '../Widgets/loading_dialog.dart';

class OffersController {
  updateNotificationForOffers(
      {required String offerId,
      required String userId,
      required List<OffersNotification> checkByList,
      required bool isAdd,
      // required bool isNew,
      required String? offersReceived,
      required String notificationTitle,
      required String senderId,
      required String notificationSubtitle}) async {
    List<OffersNotification> notifications = checkByList;
    List mapData = [];
    if (isAdd) {
      notifications.removeWhere((test) => test.checkById == userId);

      notifications.add(OffersNotification.fromDb({
        'checkById': userId,
        'isRead': false,
        'title': notificationTitle,
        'subtitle': notificationSubtitle,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'senderId': senderId,
        'offersReceivedId': offersReceived ?? '',
      }));
      for (var element in notifications) {
        mapData.add({
          'checkById': element.checkById,
          'isRead': element.isRead,
          'title': element.title,
          'subtitle': element.subtitle,
          'senderId': senderId,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'offersReceivedId': offersReceived ?? '',
        });
      }
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .update({
        'checkByList': mapData,
      });
      if (offersReceived != null) {
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(offersReceived)
            .update({
          'checkByList': mapData,
        });
      }
    } else {
      notifications.removeWhere((test) => test.checkById == userId);
      for (var element in notifications) {
        mapData.add({
          'checkById': element.checkById,
          'isRead': element.isRead,
          'title': element.title,
          'subtitle': element.subtitle,
          'senderId': senderId,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'offersReceivedId': offersReceived ?? '',
        });
      }

      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .update({
        'checkByList': mapData,
      });
      if (offersReceived != null) {
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(offersReceived)
            .update({
          'checkByList': mapData,
        });
      }
    }
  }

  acceptOffer(
      OffersReceivedModel offersReceivedModel,
      OffersModel offersModel,
      UserModel userModel,
      UserModel postedByDetails,
      String? chatId,
      GarageModel garageModel) async {
    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Upcoming',
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersModel.offerId)
        .update({
      'status': 'inProgress',
      'offerReceivedIdJob': offersReceivedModel.id
    });
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('offersReceived')
        .where('status', isEqualTo: 'Pending')
        .where('offerId', isEqualTo: offersModel.offerId)
        .get();
    for (var element in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('offersReceived')
          .doc(element.id)
          .update({
        'status': 'Rejected',
      });
    }
    //TODO Send Offer Accepted By Owner Notification
    // sendNotification(
    //     offersReceivedModel.offerBy,
    //     userModel.name,
    //     'Offer Update',
    //     '${userModel.name} Accepted the offer',
    //     offersReceivedModel.id,
    //     'Offer',
    //     '');

    if (chatId == null) {
      ChatModel? chatModel = await ChatController().getChat(
          userModel.userId, postedByDetails.userId, offersModel.offerId);
      if (chatModel == null) {
        await ChatController().createChat(
            userModel,
            postedByDetails,
            offersReceivedModel.id,
            offersModel,
            'Offer Accepted',
            '${userModel.name} accepted your offer for ${offersModel.vehicleId}',
            'chat');

        ChatModel? newchat = await ChatController().getChat(
            userModel.userId, postedByDetails.userId, offersModel.offerId);
        Get.close(2);
        Get.to(() => MessagePage(
              chatModel: newchat!,
              offersModel: offersModel,
              secondUser: postedByDetails,
              garageModel: garageModel,
            ));
      } else {
        await ChatController()
            .updateChatRequestId(chatModel.id, offersReceivedModel.id);
        Get.close(2);

        // Get.to(() => MessagePage(
        //       chatModel: chatModel,
        //       offersModel: offersModel,
        //       secondUser: postedByDetails,
        //       garageModel: garageModel,
        //     ));
      }
    }
  }

  chatWithOffer(
      UserModel userModel,
      UserModel postedByDetails,
      OffersModel offersModel,
      OffersReceivedModel offersReceivedModel,
      GarageModel garageModel) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    ChatModel? chatModel = await ChatController()
        .getChat(userModel.userId, postedByDetails.userId, offersModel.offerId);
    if (chatModel == null) {
      await ChatController().createChat(
          userModel,
          postedByDetails,
          offersReceivedModel.id,
          offersModel,
          'New Message',
          '${userModel.name} started a chat for ${offersModel.vehicleId}',
          'Message');
      ChatModel? newchat = await ChatController().getChat(
          userModel.userId, postedByDetails.userId, offersModel.offerId);
      Get.close(1);
      Get.to(() => MessagePage(
            chatModel: newchat!,
            offersModel: offersModel,
            secondUser: postedByDetails,
            garageModel: garageModel,
          ));
    } else {
      await ChatController()
          .updateChatRequestId(chatModel.id, offersReceivedModel.id);
      Get.close(1);

      Get.to(() => MessagePage(
            chatModel: chatModel,
            offersModel: offersModel,
            secondUser: postedByDetails,
            garageModel: garageModel,
          ));
    }
  }

  cancelOfferByProvider(
      OffersReceivedModel offersReceivedModel, UserModel userModel) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);

    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Cancelled',
      'cancelBy': 'provider',
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inactive',
    });

    Get.close(2);
  }

  addToCalenderOffer() async {}

  completeOffer(OffersReceivedModel offersReceivedModel) async {
    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Completed',
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inactive',
    });
  }

  cancelOfferByOwner(
      OffersReceivedModel offersReceivedModel,
      OffersModel offersModel,
      String userId,
      String serviceId,
      String cancelReason) async {
    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Cancelled',
      'cancelBy': 'owner',
      'cancelReason': cancelReason,
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inactive',
    });
  }

  cancelOfferByService(OffersReceivedModel offersReceivedModel,
      OffersModel offersModel, String cancelReason) async {
    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Cancelled',
      'cancelBy': 'provider',
      'cancelReason': cancelReason,
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inactive',
    });
  }

  giveRatingOwner() async {}
  giveRatingToProvider() async {}
  deleteOffer() async {}
}
