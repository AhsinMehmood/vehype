import 'package:cloud_firestore/cloud_firestore.dart';

class GarageModel {
  final String ownerId;
  final String bodyStyle;
  final String make;
  final String year;
  final String model;
  final String vin;
  final String description;
  final String imageTwo;
  final String imageOne;
  final String garageId;

  factory GarageModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String id = snapshot.id;
    return GarageModel(
      ownerId: data['ownerId'] ?? '',
      bodyStyle: data['bodyStyle'] ?? '',
      make: data['make'] ?? '',
      year: data['year'] ?? '',
      model: data['model'] ?? '',
      vin: data['vin'] ?? '',
      description: data['description'] ?? '',
      garageId: id,
      imageOne: data['imageOne'] ?? '',
      imageTwo: data['imageTwo'] ?? '',
    );
  }

  GarageModel(
      {required this.ownerId,
      required this.imageOne,
      required this.imageTwo,
      required this.bodyStyle,
      required this.make,
      required this.year,
      required this.model,
      required this.vin,
      required this.description,
      required this.garageId});
}
