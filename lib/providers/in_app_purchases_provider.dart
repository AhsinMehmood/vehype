import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/user_model.dart';

class InAppPurchaseProvider with ChangeNotifier {
  List<IAPItem> _products = [];
  List<IAPItem> get products => _products;

  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;

  late StreamSubscription _purchaseUpdatedSubscription;
  late StreamSubscription _purchaseErrorSubscription;
  InAppPurchaseProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await FlutterInappPurchase.instance.initialize();

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((item) {
      if (item != null) {
        _onPurchaseUpdated(item);
      } else {
        _purchasePending = false;
        notifyListeners();
      }
    });
    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
      // FlutterInappPurchase.instance.
      _purchasePending = false;
      notifyListeners();
    });
    await _getProducts();
  }

  checkForAppStoreInitiatedProducts() async {
    List<IAPItem> appStoreProducts = await FlutterInappPurchase.instance
        .getAppStoreInitiatedProducts(); // Get list of products
    for (var element in appStoreProducts) {
      print(element.productId);
    }
  }

  Future<void> _getProducts() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions([
      'premium_pro_yearly',
      'premium_business_yearly',
      'premium_pro_monthly',
      'premium_business_monthly',
    ]);
    // print(items.length);
    _products = items;
    notifyListeners();
  }

  Future<void> buyProduct(IAPItem product) async {
    // if (_isTransactionInProgress) {
    //   debugPrint("Purchase already in progress");
    //   return;
    // }

    _purchasePending = true;
    notifyListeners();

    try {
      await FlutterInappPurchase.instance
          .requestSubscription(product.productId!);
    } catch (e) {
      _purchasePending = false;
      notifyListeners();
      rethrow;
    }
  }

  void _onPurchaseUpdated(PurchasedItem item) async {
    if (item.transactionId != null && item.transactionReceipt != null) {
      String plan = 'free';
      if (item.productId!.contains('pro')) {
        plan = 'pro';
      } else if (item.productId!.contains('business')) {
        plan = 'business';
      }
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String userId = sharedPreferences.getString('userId') ?? '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc('${userId}seeker')
          .update({
        'plan': plan,
        // 'duration': duration,
        'productId': item.productId,
        'purchaseToken': item.purchaseToken,
      });
      // Optionally verify with server here
      // final callable =
      //     FirebaseFunctions.instance.httpsCallable('verifyPurchase');

      // try {
      //   log(item.purchaseToken.toString());
      //   final HttpsCallableResult response = await callable.call({
      //     'purchaseToken': item.purchaseToken,
      //     'productId': item.productId,
      //     'userId': '${userId}seeker',
      //   });
      //   final result = response.data;
      //   log(item.toString());
      //   log(result.toString());

      //   if (result['status'] == 'success') {
      //     print('✅ Verified: ${result['message']}');
      //     // Optionally show a success Snackbar or update app state
      //   } else {
      //     print('❌ Verification failed: ${result['message']}');
      //     // Show error to user or retry
      //   }
      // } catch (e) {
      //   print('❌ Verification failed: $e');
      // }
      // Mark transaction complete
      await FlutterInappPurchase.instance.finishTransaction(item);

      _purchasePending = false;
      notifyListeners();
      Get.back();
    } else {
      _purchasePending = false;
      log(item.toString() + ' NULL SOMETHING');
      notifyListeners();
    }
  }

  endConnection() {
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    _purchasePending = false;
    FlutterInappPurchase.instance.clearTransactionIOS();
    FlutterInappPurchase.instance.finalize();
    notifyListeners();
  }

  static Future<void> checkSubscriptionStatus(UserModel userModel) async {
    // Initialize connection
    await FlutterInappPurchase.instance.initialize();

    // Get user's active subscriptions
    List<PurchasedItem> subscriptions =
        await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];
    for (var element in subscriptions) {
      log(element.toString());
    }
    bool hasActiveSubscription =
        subscriptions.any((item) => item.productId == userModel.productId);

    if (hasActiveSubscription) {
      log('Subscription is active');
      // Keep premium access
    } else {
      log('Subscription is canceled or expired');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.userId)
          .update({
        'plan': 'free',
        'productId': '',
      });
      // Downgrade user access, show renewal prompt
    }

    // Dispose connection when done
    await FlutterInappPurchase.instance.finalize();
  }
}
