import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';

import '../Models/user_model.dart';
import '../Pages/message_page.dart';
import '../Pages/repair_page.dart';
import '../Widgets/loading_dialog.dart';

class OffersController {
  acceptOffer(OffersReceivedModel offersReceivedModel, OffersModel offersModel,
      UserModel userModel, UserModel postedByDetails) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
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
    });
    sendNotification(
        offersReceivedModel.offerBy,
        userModel.name,
        'Offer Update',
        '${userModel.name} Accepted the offer',
        offersReceivedModel.id,
        'Offer',
        '');

    ChatModel? chatModel = await ChatController()
        .getChat(userModel.userId, postedByDetails.userId, offersModel.offerId);
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
            secondUser: postedByDetails,
          ));
    } else {
      Get.close(2);

      Get.to(() => MessagePage(
            chatModel: chatModel,
            secondUser: postedByDetails,
          ));
    }
  }

  chatWithOffer(UserModel userModel, UserModel postedByDetails,
      OffersModel offersModel, OffersReceivedModel offersReceivedModel) async {
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
            secondUser: postedByDetails,
          ));
    } else {
      Get.close(1);

      Get.to(() => MessagePage(
            chatModel: chatModel,
            secondUser: postedByDetails,
          ));
    }
  }

  cancelOfferByOwner(
      OffersReceivedModel offersReceivedModel, UserModel userModel) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);

    await FirebaseFirestore.instance
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'Cancelled',
      'cancelBy': 'owner',
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inactive',
    });
    sendNotification(
        offersReceivedModel.offerBy,
        userModel.name,
        'Offer Update',
        '${userModel.name}, Cancelled the offer',
        offersReceivedModel.id,
        'Offer',
        '');

    Get.close(2);
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
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersReceivedModel.offerId)
        .update({
      'status': 'inProgress',
    });
    sendNotification(
        offersReceivedModel.offerBy,
        userModel.name,
        'Offer Update',
        '${userModel.name}, Cancelled the offer',
        offersReceivedModel.id,
        'Offer',
        '');

    Get.close(2);
  }

  addToCalenderOffer() async {}

  completeOffer() async {}
  giveRatingOwner() async {}
  giveRatingToProvider() async {}
  deleteOffer() async {}
}
