import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehype/Models/product_service_model.dart';

// import 'package:vehype/Pages/offers_received_details.dart';/s
class OffersNotification {
  final String checkById;
  bool isRead;
  final String title;
  final String subtitle;
  final String createdAt;
  final String senderId;
  final String offersReceivedId;

  OffersNotification(
      {required this.checkById,
      required this.isRead,
      required this.title,
      required this.offersReceivedId,
      required this.subtitle,
      required this.senderId,
      required this.createdAt});

  factory OffersNotification.fromDb(data) {
    return OffersNotification(
        checkById: data['checkById'],
        isRead: data['isRead'],
        title: data['title'],
        offersReceivedId: data['offersReceivedId'] ?? '',
        createdAt:
            data['createdAt'] ?? DateTime.now().toUtc().toIso8601String(),
        senderId: data['senderId'] ?? data['checkById'],
        subtitle: data['subtitle']);
  }
}

class OffersModel {
  final String offerId;
  final String ownerId;
  final String vehicleId;
  final String issue;
  final double lat;
  final double long;
  final String description;
  final String imageOne;
  final List images;
  final String additionalService;
  final List offersReceived;
  final List ignoredBy;
  final String status;
  final String createdAt;
  final String garageId;
  final List<OffersNotification> checkByList;
  final String offerReceivedIdJob;
  final String address;
  final String vehicleType;

  OffersModel(
      {required this.offerId,
      required this.offersReceived,
      required this.offerReceivedIdJob,
      required this.address,
      required this.ownerId,
      required this.garageId,
      required this.status,
      required this.vehicleId,
      required this.additionalService,
      required this.ignoredBy,
      required this.issue,
      required this.imageOne,
      required this.lat,
      required this.long,
      required this.description,
      required this.createdAt,
      required this.checkByList,
      required this.images,
      required this.vehicleType});

  factory OffersModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    List<OffersNotification> offersNotifications = [];
    List checkByMap = data['checkByList'] ?? [];
    for (var element in checkByMap) {
      offersNotifications.add(OffersNotification.fromDb(element));
    }
    // print(data.toString());
    String id = snapshot.id;
    return OffersModel(
      offerId: id,
      createdAt: data['createdAt'] ?? DateTime.now().toIso8601String(),
      garageId: data['garageId'] ?? '',
      ignoredBy: data['ignoredBy'] ?? [],
      offersReceived: data['offersReceived'] ?? [],
      ownerId: data['ownerId'] ?? '',
      vehicleId: data['vehicleName'] ?? '',
      address: data['address'] ?? '',
      issue: data['issue'] ?? '',
      additionalService: data['additionalService'] ?? '',
      offerReceivedIdJob: data['offerReceivedIdJob'] ?? 'nothing',
      imageOne: data['imageOne'] ?? '',
      status: data['status'] ?? '',
      lat: data['lat'] ?? 0.0,
      long: data['long'] ?? 0.0,
      description: data['description'] ?? '',
      checkByList: offersNotifications,
      images: data['images'] ?? [],
      vehicleType: data['vehicleType'] ?? '',
    );
  }
  String getString() =>
      'OfferId: $offerId, garageId: $garageId, service: $issue';
}

//  'offerBy': userModel.userId,
//       'offerAt': DateTime.now().toUtc().toIso8601String(),
//       'status': 'pending',
//       'price': garageController.price,
//       'startDate': garageController.startDate!.toUtc().toIso8601String(),
//       'endDate': garageController.endDate!.toUtc().toIso8601String(),
class OffersReceivedModel {
  final String offerBy;
  final String offerAt;
  final List<OffersNotification> checkByList;

  final String price;
  // final String startDate;
  final String ownerId;
  final String offerId;
  // final String? endDate;
  final double ratingOne;
  final double ratingTwo;
  final String id;
  final String cancelBy;
  final String comment;
  final String status;
  final String commentOne;
  final String commentTwo;
  final String cancelReason;
  final String ratingOneImage;
  final String ratingTwoImage;
  final bool isDone;
  final String ownerEventId;
  final String ownerCalendarId;
  final String seekerEventId;
  final String seekerCalendarId;
  final String createdAt;
  // final List ids;
  final String randomId;
  final List<ProductServiceModel> products;
  final String completedAt;

  OffersReceivedModel({
    required this.offerBy,
    required this.cancelReason,
    required this.commentOne,
    required this.commentTwo,
    required this.ratingOne,
    required this.ratingTwo,
    required this.checkByList,
    required this.offerAt,
    required this.comment,
    required this.ownerId,
    required this.cancelBy,
    required this.id,
    required this.offerId,
    required this.price,
    // required this.ids,
    required this.products,
    required this.randomId,
    // required this.startDate,
    // required this.endDate,
    required this.isDone,
    required this.ratingOneImage,
    required this.ratingTwoImage,
    required this.status,
    required this.ownerEventId,
    required this.ownerCalendarId,
    required this.seekerEventId,
    required this.seekerCalendarId,
    required this.createdAt,
    required this.completedAt,
  });

  factory OffersReceivedModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> data = snap.data()!;
    List<OffersNotification> offersNotifications = [];
    List checkByMap = data['checkByList'] ?? [];
    for (var element in checkByMap) {
      offersNotifications.add(OffersNotification.fromDb(element));
    }
    // print(data.toString());
    // String id = snap.id;
    // log(id);

    return OffersReceivedModel(
        createdAt: data['createdAt'] ?? '',
        // ids: data['productIds'] ?? [],
        ratingOne: data['ratingOne'] ?? 0.0,
        products: (data['products'] as List<dynamic>?)
                ?.map((item) => ProductServiceModel.fromJsonMap(item))
                .toList() ??
            [],
        randomId: data['randomId'] ?? '11',
        ratingTwo: data['ratingTwo'] ?? 0.0,
        offerBy: data['offerBy'] ?? 'null',
        comment: data['comment'] ?? '',
        cancelReason: data['cancelReason'] ?? '',
        offerAt: data['offerAt'] ?? DateTime.now().toLocal().toIso8601String(),
        price: data['price'].toString(),
        id: snap.id,
        cancelBy: data['cancelBy'] ?? '',
        // startDate:
        //     data['startDate'] ?? DateTime.now().toLocal().toIso8601String(),
        // endDate: data['endDate'],
        checkByList: offersNotifications,
        status: data['status'] ?? '',
        ratingOneImage: data['ratingOneImage'] ?? '',
        ratingTwoImage: data['ratingTwoImage'] ?? '',
        ownerId: data['ownerId'] ?? '',
        commentOne: data['commentOne'] ?? '',
        isDone: data['isDone'] ?? false,
        ownerEventId: data['ownerEventId'] ?? '',
        ownerCalendarId: data['ownerCalendarId'] ?? '',
        seekerCalendarId: data['seekerCalendarId'] ?? '',
        seekerEventId: data['seekerEventId'] ?? '',
        commentTwo: data['commentTwo'] ?? '',
        completedAt: data['completedAt'] ?? DateTime.now().toIso8601String(),
        offerId: data['offerId'] ?? 'null');
  }
}
