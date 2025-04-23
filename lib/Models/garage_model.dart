import 'package:cloud_firestore/cloud_firestore.dart';

class GarageModel {
  final String ownerId;
  final String bodyStyle;
  final String make;
  final String year;
  final String model;
  final String submodel;
  final String title;
  final String vin;

  final bool isCustomModel;
  final bool isCustomMake;
  final String imageUrl;

  final String garageId;
  final String createdAt;

  factory GarageModel.fromJson(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    String imageOne = data['imageOne'] ?? '';

    String id = snapshot.id;
    return GarageModel(
      createdAt: data['createdAt'] ?? DateTime.now().toIso8601String(),
      ownerId: data['ownerId'] ?? '',
      isCustomMake: data['isCustomMake'] ?? false,
      isCustomModel: data['isCustomModel'] ?? false,
      bodyStyle: data['bodyStyle'] ?? '',
      make: data['make'] ?? '',
      year: data['year'] ?? '',
      model: data['model'] ?? '',
      vin: data['vin'] ?? '',
      garageId: id,
      imageUrl: imageOne == ''
          ? 'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/WhatsApp%20Image%202024-07-25%20at%2022.08.41.jpeg?alt=media&token=3e2daa79-95e1-45a2-ab01-52a484423618'
          : imageOne,
      submodel: data['subModel'] ?? '',
      title: '${data['make']}, ${data['year']}, ${data['model']}',
    );
  }

  String getString() {
    return 'Garage ID: $garageId, Make: $make, Model: $model, Year: $year, SubModel: $submodel';
  }

  GarageModel(
      {required this.ownerId,
      required this.isCustomModel,
      required this.isCustomMake,
      required this.submodel,
      required this.title,
      required this.imageUrl,
      required this.bodyStyle,
      required this.make,
      required this.year,
      required this.model,
      required this.vin,
      required this.garageId,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'isCustomMake': isCustomMake,
      'isCustomModel': isCustomModel,
      'subModel': submodel,
      'title': title,
      'imageOne': imageUrl,
      'bodyStyle': bodyStyle,
      'make': make,
      'year': year,
      'model': model,
      'vin': vin,
      'createdAt': createdAt,
    };
  }

  GarageModel copyWith({
    String? garageId,
    String? ownerId,
    String? bodyStyle,
    String? make,
    String? year,
    String? model,
    String? submodel,
    String? title,
    String? vin,
    bool? isCustomModel,
    bool? isCustomMake,
    String? imageUrl,
    String? createdAt,
  }) {
    return GarageModel(
      garageId: garageId ?? this.garageId,
      ownerId: ownerId ?? this.ownerId,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      make: make ?? this.make,
      year: year ?? this.year,
      model: model ?? this.model,
      submodel: submodel ?? this.submodel,
      title: title ?? this.title,
      vin: vin ?? this.vin,
      createdAt: createdAt ?? this.createdAt,
      isCustomModel: isCustomModel ?? this.isCustomModel,
      isCustomMake: isCustomMake ?? this.isCustomMake,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
