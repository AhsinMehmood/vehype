

// part 'vehicle_model.g.dart';


class VehicleType {
  final String title;
  final String icon;

  VehicleType({required this.title, required this.icon});
}


class VehicleMake {
  final int id;
  final String title;
  final String icon;
  final int vehicleTypeId;

  VehicleMake(
      {required this.id,
      required this.title,
      required this.icon,
      required this.vehicleTypeId});
  // Convert VehicleMake to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'vehicleTypeId': vehicleTypeId,
    };
  }

  // Convert JSON to VehicleMake
  factory VehicleMake.fromJson(Map<String, dynamic> json) {
    return VehicleMake(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      vehicleTypeId: json['vehicleTypeId'] ?? 0,
    );
  }
  bool startsWith(String query) {
    return title.toLowerCase().startsWith(query.toLowerCase());
  }
}

class VehicleModel {
  final int id;
  final String title;
  final String icon;
  final int vehicleTypeId;
  final int vehicleMakeId;
  // final bool isCustom;

  VehicleModel(
      {required this.id,
      required this.title,
      required this.icon,
      required this.vehicleMakeId,
      required this.vehicleTypeId});
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      vehicleTypeId: json['vehicleTypeId'],
      vehicleMakeId: json['vehicleMakeId'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'vehicleTypeId': vehicleTypeId,
      'vehicleMakeId': vehicleMakeId,
    };
  }

  bool startsWith(String query) {
    return title.toLowerCase().startsWith(query.toLowerCase());
  }
}
