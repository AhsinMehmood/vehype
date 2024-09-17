class VehicleType {
  final int id;
  final String title;
  final String icon;

  VehicleType({required this.id, required this.title, required this.icon});
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

  VehicleModel(
      {required this.id,
      required this.title,
      required this.icon,
      required this.vehicleMakeId,
      required this.vehicleTypeId});
  bool startsWith(String query) {
    return title.toLowerCase().startsWith(query.toLowerCase());
  }
}
