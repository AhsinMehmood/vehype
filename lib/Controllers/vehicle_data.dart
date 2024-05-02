import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Models/vehicle_model.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;
//   List<Service> getServices() {
//     return [
//       Service(name: "Diagnostics", code: Services.diagnostics),
//       Service(name: "Detailing", code: Services.detailing),
//       Service(name: "Towing", code: Services.towing),
//       Service(name: "Upholstery repair", code: Services.upholsteryRepair),
//       Service(name: "Windshield service", code: Services.windshieldServices),
//       Service(name: "Door glass service", code: Services.doorGlassServices),
//       Service(name: "Oil change", code: Services.oilChange),
//       Service(name: "Wheels and tires", code: Services.wheelsAndTires),
//       Service(name: "Wheels repair", code: Services.wheelsRepair),
//       Service(name: "Parts and supplies", code: Services.partsSupplies),
//       Service(name: "Locksmith", code: Services.locksmith),
//       Service(name: "Garage rent", code: Services.garageRent),
//       Service(name: "Car lift", code: Services.carLift),
//       Service(name: "Jumpstart", code: Services.jumpStart),
//       Service(name: "Body", code: Services.body),
//       Service(name: "Electrical", code: Services.electrical),
//       Service(name: "Engine", code: Services.engine),
//       Service(name: "Brake system", code: Services.brakeSystem),
//       Service(name: "Emission", code: Services.emission),
//       Service(name: "AC (Air conditioning)", code: Services.aCAirConditioning),
//       Service(name: "Suspension/Chassis", code: Services.suspensionChassis),
//       Service(name: "Drivetrain", code: Services.drivetrain),
//     ];
//   }

List<VehicleType> getVehicleType() {
  return [
    VehicleType(id: 1, title: "Motorcycle", icon: 'assets/motorcycle.svg'),
    // VehicleType(id: 2, title: "Car", icon: 'assets/passenger_vehicle.svg'),
    VehicleType(
        id: 2,
        title: "Passenger vehicle",
        icon: 'assets/passenger_vehicle.svg'),
    VehicleType(id: 3, title: "Truck", icon: 'assets/truck.svg'),
    VehicleType(id: 4, title: "Bus", icon: 'assets/bus.svg'),
    VehicleType(id: 5, title: "Trailer", icon: 'assets/trailer.svg'),
    VehicleType(
        id: 6,
        title: "Low speed vehicle",
        icon: 'assets/low_speed_vehicle.svg'),
    VehicleType(
        id: 7,
        title: "Incomplete Vehicle",
        icon: 'assets/incomplete_vehicle.svg'),
    VehicleType(
        id: 8, title: "Off road vehicle", icon: 'assets/off_road_vehicle.svg'),
  ];
}

Future<List<VehicleModel>> getVehicleModel(int year, String make) async {
  String jwtToken = await getJwtToken();
  List<VehicleModel> vehicleMakeList = [];

  http.Response response = await http.get(
      Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/$make?format=json'),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $jwtToken'
      });
  final data = jsonDecode(response.body);
  List listOfData = data['Results'] as List;

  print(listOfData.length);
  for (var element in listOfData) {
    print(element);
    vehicleMakeList.add(VehicleModel(
        id: element['Make_ID'],
        title: element['Model_Name'],
        icon: '',
        vehicleMakeId: element['Make_ID'],
        vehicleTypeId: 0));
  }

  return vehicleMakeList;
}

Future<List<VehicleMake>> getVehicleMake(String type) async {
  String vehicleType = type == 'Passenger Vehicle' ? 'Car' : type;
  try {
    List<VehicleMake> vehicleMakeList = [];

    http.Response response = await http.get(
        Uri.parse(
            'https://vpic.nhtsa.dot.gov/api/vehicles/GetMakesForVehicleType/$type?format=json'),
        headers: {
          'Content-type': 'application/json',
          // 'Authorization': 'Bearer $jwtToken'
        });
    final data = jsonDecode(response.body);
    List listOfData = data['Results'] as List;

    for (var element in listOfData) {
      // print(element);
      vehicleMakeList.add(VehicleMake(
          id: element['MakeId'] ?? 0,
          title: element['MakeName'] ?? '',
          icon: '',
          vehicleTypeId: 0));
    }

    return vehicleMakeList;
  } catch (e) {
    print(e);
    return [];
  }
}

Future<List<int>> getVehicleYear(String make) async {
  String jwtToken = await getJwtToken();
  List<int> vehicleMakeList = [];

  http.Response response = await http
      .get(Uri.parse('https://carapi.app/api/years?make=$make'), headers: {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $jwtToken'
  });
  final data = jsonDecode(response.body);
  List listOfData = data as List;

  print(listOfData.length);
  for (var element in listOfData) {
    print(element);
    vehicleMakeList.add(element);
  }
  if (vehicleMakeList.isEmpty) {
    List<int> years =
        List<int>.generate(2024 - 1800 + 1, (index) => 2024 - index);

    vehicleMakeList = years;
  }

  return vehicleMakeList;
}

Future<String> getJwtToken() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? jwtToken = sharedPreferences.getString('carApiToken');
  if (jwtToken == null) {
    http.Response response =
        await http.post(Uri.parse('https://carapi.app/api/auth/login'),
            headers: {
              'Content-type': 'application/json',
              'Accept': 'text/plain',
            },
            body: jsonEncode({
              "api_token": carApiToken,
              "api_secret": carApiSecret,
            }));
    if (response.statusCode == 200) {
      print(response.body);
      sharedPreferences.setString('carApiToken', response.body);
      // final responses = jsonDecode(response.body);
      return response.body;
    } else {
      print(response.body);

      return '';
    }
  } else {
    return jwtToken;
  }
}

List<Service> getServices() {
  return [
    Service(name: "Diagnostics", image: icDiagnostic),
    Service(name: "Detailing", image: icDetailing),
    Service(name: "Towing", image: icTowing),
    Service(name: "Upholstery repair", image: icUpholsteryRepair),
    Service(name: "Windshield service", image: icWindshield),
    Service(name: "Door glass service", image: icGlassDoorService),
    Service(name: "Oil change", image: icOilChange),
    Service(name: "Wheels and tires", image: icWheelTires),
    Service(name: "Wheels repair", image: icWheelRepair),
    Service(name: "Parts and supplies", image: icPartsSupplies),
    Service(name: "Locksmith", image: icLockSmith),
    Service(name: "Garage rent", image: icGarageRent),
    Service(name: "Car lift", image: icCarLift),
    Service(name: "Jumpstart", image: icJumpstart),
    Service(name: "Body", image: icBodyPaint),
    Service(name: "Electrical", image: icElectrical),
    Service(name: "Engine", image: icEngine),
    Service(name: "Brake system", image: icBreakSystem),
    Service(name: "Emission", image: icEmissions),
    Service(name: "AC (Air conditioning)", image: icAc),
    Service(name: "Suspension/Chassis", image: icSuspenssionChassis),
    Service(name: "Drivetrain", image: icDrivetrain),
  ];
}

class Service {
  final String name;
  final String image;

  Service({required this.name, required this.image});
}

class YearModel {
  final int year;

  YearModel(this.year);
  bool startsWith(int query, List<int> years) {
    return years.any((year) => year.toString().startsWith(query.toString()));
  }
}
