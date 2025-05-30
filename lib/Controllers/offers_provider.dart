import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:vehype/Models/offers_model.dart';

import '../Models/user_model.dart';

class OffersProvider extends ChangeNotifier {
  StreamSubscription<List<OffersReceivedModel>>? _offersReceivedSubscription;
  StreamSubscription<List<OffersModel>>? _offersSubscription;
  List<OffersModel> offers = [];
  List<OffersReceivedModel> offersReceived = [];

  StreamSubscription<List<OffersModel>>? _ownerOffersSubscription;
  List<OffersModel> ownerOffers = [];

  void startListeningOwnerOffers(String userId) {
    // OneSignal.Notifications.pos
    _ownerOffersSubscription = FirebaseFirestore.instance
        .collection('offers')
        .where('ownerId', isEqualTo: userId)
        // .where('status', isEqualTo: 'active')
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => OffersModel.fromJson(e)).toList())
        .listen((rawOffers) {
      ownerOffers = rawOffers;
      log('${ownerOffers.length} Owner Offers');

      notifyListeners();
    });
    // print(object)
  }

  void startListening(UserModel userModel) {
    _offersSubscription = FirebaseFirestore.instance
        .collection('offers')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => OffersModel.fromJson(e)).toList())
        .listen((rawOffers) {
      offers = rawOffers;
      log('${offers.length} Offers');

      notifyListeners();
    });
    // print(object)
  }

  void startListeningOffers(String userId) {
    try {
      // log(2.toString());

      _offersReceivedSubscription = FirebaseFirestore.instance
          .collection('offersReceived')
          .where('offerBy', isEqualTo: userId)
          // .orderBy('createdAt', descending: true)
          .snapshots()
          .map((event) =>
              event.docs.map((e) => OffersReceivedModel.fromJson(e)).toList())
          .listen((offersReceivedList) {
        offersReceived = offersReceivedList;
        offersReceivedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        log('${offersReceived.length} Offers Receeivedd');

        notifyListeners();
      });
      log(2.toString());
    } catch (e) {
      // log(2.toString());

      log(e.toString());
    }
  }

  void stopListening() {
    _offersReceivedSubscription?.cancel();
    _ownerOffersSubscription?.cancel();
    _offersSubscription?.cancel();
  }
}
