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
    String imageOnes = data['imageOne'] ?? '';

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
      imageOne: imageOnes.isEmpty
          ? 'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/WhatsApp%20Image%202024-07-25%20at%2022.08.41.jpeg?alt=media&token=3e2daa79-95e1-45a2-ab01-52a484423618'
          : imageOnes,
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
