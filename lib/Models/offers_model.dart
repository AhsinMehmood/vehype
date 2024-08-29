import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:vehype/Pages/offers_received_details.dart';/s
class OffersNotification {
  final String checkById;
  final bool isRead;
  final String title;
  final String subtitle;

  OffersNotification(
      {required this.checkById,
      required this.isRead,
      required this.title,
      required this.subtitle});

  factory OffersNotification.fromDb(data) {
    return OffersNotification(
        checkById: data['checkById'],
        isRead: data['isRead'],
        title: data['title'],
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
      required this.images});

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
        images: data['images'] ?? []);
  }
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

  final double price;
  final String startDate;
  final String ownerId;
  final String offerId;
  final String endDate;
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
  OffersReceivedModel(
      {required this.offerBy,
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
      required this.startDate,
      required this.endDate,
      required this.isDone,
      required this.ratingOneImage,
      required this.ratingTwoImage,
      required this.status});

  factory OffersReceivedModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> data = snap.data() ?? {};
    List<OffersNotification> offersNotifications = [];
    List checkByMap = data['checkByList'] ?? [];
    for (var element in checkByMap) {
      offersNotifications.add(OffersNotification.fromDb(element));
    }
    // print(data.toString());
    // String id = snap.id;
    return OffersReceivedModel(
        ratingOne: data['ratingOne'] ?? 0.0,
        ratingTwo: data['ratingTwo'] ?? 0.0,
        offerBy: data['offerBy'],
        comment: data['comment'] ?? '',
        cancelReason: data['cancelReason'] ?? '',
        offerAt: data['offerAt'],
        price: data['price'],
        id: snap.id,
        cancelBy: data['cancelBy'] ?? '',
        startDate: data['startDate'],
        endDate: data['endDate'],
        checkByList: offersNotifications,
        status: data['status'],
        ratingOneImage: data['ratingOneImage'] ?? '',
        ratingTwoImage: data['ratingTwoImage'] ?? '',
        ownerId: data['ownerId'] ?? '',
        commentOne: data['commentOne'] ?? '',
        isDone: data['isDone'] ?? false,
        commentTwo: data['commentTwo'] ?? '',
        offerId: data['offerId']);
  }
}
