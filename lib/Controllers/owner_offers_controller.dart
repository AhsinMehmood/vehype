import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehype/Models/offers_model.dart';

import '../Models/user_model.dart';

class OwnerOffersController {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  ignoreOffer(
      OffersModel offersModel, OffersReceivedModel offersReceivedModel) async {
    await firebaseFirestore
        .collection('offersReceived')
        .doc(offersReceivedModel.id)
        .update({
      'status': 'ignore',
    });
  }

  cancelOfferByOwner(
      OffersReceivedModel offersReceivedModel, UserModel userModel) async {
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
    //TODO Send Offer Cancelled By Owner Notification
    // sendNotification(
    //     offersReceivedModel.offerBy,
    //     userModel.name,
    //     'Offer Update',
    //     '${userModel.name}, Cancelled the Job.',
    //     offersReceivedModel.id,
    //     'Offer',
    //     '');
  }
}
