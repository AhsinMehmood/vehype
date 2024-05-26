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
  );

  factory UserModel.fromJson(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    String userId = snapshot.id;
    List ratings = data['ratings'] ?? [];
    double totalRating = ratings.isEmpty
        ? 0.0
        : ratings.fold<double>(
            0.0, (prev, element) => prev + (element['rating'] as double));
    return UserModel(
      userId,
      data['profileUrl'] ?? '',
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
    );
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
}
