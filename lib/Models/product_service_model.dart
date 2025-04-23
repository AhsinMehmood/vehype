import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServiceModel {
  final String name;
  final String desc;
  final String totalPrice;
  final int index;
  final String hourlyRate;
  final String hours;
  final String flatRate;
  final String pricePerItem;
  final String quantity;
  final String id;
  final String serviceId;
  final String createdAt;

  ProductServiceModel({
    required this.name,
    required this.desc,
    required this.totalPrice,
    required this.index,
    required this.hourlyRate,
    required this.hours,
    required this.flatRate,
    required this.pricePerItem,
    required this.createdAt,
    required this.quantity,
    required this.serviceId,
    required this.id,
  });

  /// Convert Firestore DocumentSnapshot to ProductServiceModel
  factory ProductServiceModel.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductServiceModel(
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      totalPrice: data['totalPrice'] ?? '0.0',
      index: data['index'] ?? 1,
      hourlyRate: data['hourlyRate'] ?? '0.0',
      serviceId: data['serviceId'] ?? '',
      hours: data['perHour'] ?? '0.0',
      createdAt: data['createdAt'] ?? DateTime.now().toUtc().toIso8601String(),
      flatRate: data['flatRate'] ?? '0.0',
      pricePerItem: data['pricePerItem'] ?? '0.0',
      quantity: data['quantity'] ?? '1',
      id: doc.id, // Using Firestore document ID
    );
  }
  factory ProductServiceModel.fromJsonMap(Map map) {
    final data = map;
    return ProductServiceModel(
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      totalPrice: data['totalPrice'] ?? '0.0',
      index: data['index'] ?? 1,
      hourlyRate: data['hourlyRate'] ?? '0.0',
      serviceId: data['serviceId'] ?? '',
      hours: data['perHour'] ?? '0.0',
      createdAt: data['createdAt'] ?? DateTime.now().toUtc().toIso8601String(),
      flatRate: data['flatRate'] ?? '0.0',
      pricePerItem: data['pricePerItem'] ?? '0.0',
      quantity: data['quantity'] ?? '1',
      id: data['id'], // Using Firestore document ID
    );
  }


  /// Convert ProductServiceModel to a JSON map (for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'desc': desc,
      'totalPrice': totalPrice,
      'index': index,
      'hourlyRate': hourlyRate,
      'perHour': hours,
      'flatRate': flatRate,
      'pricePerItem': pricePerItem,
      'quantity': quantity,
      'serviceId': serviceId,
      'id': id,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
