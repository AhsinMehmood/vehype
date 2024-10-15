import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String profileUrl;
  final String name;
  final String email;
  final String phoneNumber;
  final String accountType;

  final double rating;
  final List services;
  final double lat;
  final double long;
  final String pushToken;
  final List ratings;
  final String adminStatus;
  final bool unread;
  final List blockedUsers;
  final List blockedBy;
  final String secondId;
  final String businessInfo;
  final String contactInfo;
  final String website;

  final List gallery;
  final bool isActiveNew;
  final bool isActivePending;
  final bool isActiveInProgress;
  final bool isActiveCompleted;
  final bool isActiveCancelled;
  final bool isActive;
  final bool isActiveHistory;
  final String businessAddress;
  final List offerIdsToCheck;
  final List favProviderIds;
  final List favBy;
  final List additionalServices;
  final bool isGuest;
  final int radius;

  UserModel(
    this.userId,
    this.profileUrl,
    this.name,
    this.email,
    this.phoneNumber,
    this.accountType,
    this.rating,
    this.services,
    this.lat,
    this.long,
    this.pushToken,
    this.ratings,
    this.adminStatus,
    this.unread,
    this.blockedUsers,
    this.blockedBy,
    this.secondId,
    this.businessInfo,
    this.contactInfo,
    this.website,
    this.gallery,
    this.isActiveNew,
    this.isActivePending,
    this.isActiveInProgress,
    this.isActiveCompleted,
    this.isActiveCancelled,
    this.isActive,
    this.isActiveHistory,
    this.businessAddress,
    this.offerIdsToCheck,
    this.favProviderIds,
    this.favBy,
    this.additionalServices,
    this.isGuest,
    this.radius,
  );

  factory UserModel.fromJson(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    String userId = snapshot.id;
    bool isGuestUser = data['email'] == 'No email set' ? true : false;

    // List<Map<String, dynamic>> rawRatings = data['ratings'] ?? [];
    List ratings = data['ratings'] ?? [];

    double totalRating = ratings.isEmpty
        ? 0.0
        : ratings.fold<double>(
            0.0, (prev, element) => prev + (element['rating']));
    return UserModel(
        userId,
        data['profileUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/user_place_holder.png?alt=media&token=c75336b0-87fb-4493-8d62-7c707d0b4757',
        data['name'] ?? '',
        data['email'] ?? '',
        data['phoneNumber'] ?? '',
        data['accountType'] ?? '',
        totalRating,
        data['services'] ?? [],
        data['lat'] ?? 0.0,
        data['long'] ?? 0.0,
        data['pushToken'] ?? '',
        ratings,
        data['adminStatus'] ?? 'Active',
        data['unread'] ?? false,
        data['blockedUsers'] ?? [],
        data['blockedBy'] ?? [],
        data['secondId'] ?? '',
        data['businessInfo'] ?? '',
        data['contactInfo'] ?? '',
        data['website'] ?? '',
        data['gallery'] ?? [],
        // [
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FBGInSktIzvcBLNFQCbQTGT5GIp53%2F1714990262141039.jpg?alt=media&token=2aba2d40-7b01-429f-ad4e-5d836a66f432',
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FlzCv0Ko5KvO7I8hh5cDyKyQaZQe2%2F1716640490808914.jpg?alt=media&token=b481c0b7-82cf-4d94-9e54-f17c465717a5',
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FvR0JinKItZWiprBVTRDPLQVJd7B2%2F1712777911523072.jpg?alt=media&token=9946b913-dace-4669-b13d-54238e13cb12',
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FZ430ctH1ZzM3iNrn0G1tYqwqAWp2%2F1712856188882960.jpg?alt=media&token=cdf726ad-dfc2-4ff8-ab30-e63dd940f4ee',
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FZ430ctH1ZzM3iNrn0G1tYqwqAWp2seeker%2F1716753333630168.jpg?alt=media&token=d368090c-75de-4b8c-bb29-9a484df3c8a0',
        //   'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/users%2FZ430ctH1ZzM3iNrn0G1tYqwqAWp2%2F1714187177364780.jpg?alt=media&token=387e646d-5156-4933-b023-8cd2696ed3fd',
        // ],
        data['isActiveNew'] ?? false,
        data['isActivePending'] ?? false,
        data['isActiveInProgress'] ?? false,
        data['isActiveCompleted'] ?? false,
        data['isActiveCancelled'] ?? false,
        data['isActive'] ?? false,
        data['isHistoryActive'] ?? false,
        data['businessAddress'] ?? '',
        data['offerIdsToCheck'] ?? [],
        data['favProviderIds'] ?? [],
        data['favBy'] ?? [],
        data['additionalServices'] ?? [],
        isGuestUser,
        data['radius'] ?? 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'profileUrl': profileUrl,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'accountType': accountType,
      'services': services,
      'lat': lat,
      'long': long,
      'pushToken': pushToken,
      'ratings': ratings,
      'adminStatus': adminStatus,
      'unread': unread,
      'blockedUsers': blockedUsers,
      'blockedBy': blockedBy,
    };
  }

  String get searchKey => '$name $services'.toLowerCase();
}
