import 'dart:convert';
import 'dart:developer';

import 'package:vehype/Models/vehicle_model.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;
//   List<Service> getServices() {
//     return [
//       Service(name: "Diagnostics", code: Services.diagnostics),
//        Service(name: "Detailing", code: Services.detailing),
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
  List<VehicleType> vehicleTypeList = [
    VehicleType(
        id: 1,
        title: "Passenger vehicle",
        icon: 'assets/passenger_vehicle.svg'),
    VehicleType(id: 2, title: "Motorcycle", icon: 'assets/motorcycle.svg'),
    VehicleType(id: 3, title: "Bus", icon: 'assets/bus.svg'),
    VehicleType(id: 4, title: "Truck", icon: 'assets/truck.svg'),
    VehicleType(id: 5, title: "Trailer", icon: 'assets/trailer.svg'),
    VehicleType(
        id: 6,
        title: "Incomplete Vehicle",
        icon: 'assets/incomplete_vehicle.svg'),
    VehicleType(
        id: 7,
        title: "Low speed vehicle",
        icon: 'assets/low_speed_vehicle.svg'),
    VehicleType(
        id: 8, title: "Off road vehicle", icon: 'assets/off_road_vehicle.svg'),
  ];

  return vehicleTypeList;
}

Future<List<VehicleModel>> getVehicleModel(
    int year, String make, String type) async {
  String vehicleType = type == 'Passenger vehicle' ? 'Car' : type;
  // await Future.delayed(const Duration(seconds: 5));

  // String jwtToken = await getJwtToken();
  List<VehicleModel> vehicleMakeList = [];
  http.Response response = await http.get(
      Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/$make/modelyear/$year/vehicletype/$vehicleType?format=json'),
      headers: {
        'Content-type': 'application/json',
        // 'Authorization': 'Bearer $jwtToken'
      });
  final data = jsonDecode(response.body);
  List listOfData = data['Results'] as List;

  for (var element in listOfData) {
    vehicleMakeList.add(VehicleModel(
        id: element['Make_ID'],
        title: element['Model_Name'],
        icon: '',
        vehicleMakeId: element['Make_ID'],
        vehicleTypeId: 0));
  }

  return vehicleMakeList;
}

Future<List> getModelsToStoreData(
    String make, String year, String jwtToken) async {
  // await Future.delayed(const Duration(seconds: 5));

  List vehicleMakeList = [];

  String recallApi = 'https://carapi.app/api/models?year=$year&make=$make';
  http.Response response = await http.get(Uri.parse(recallApi), headers: {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $jwtToken'
  });
  final data = jsonDecode(response.body);

  List listOfData = data['data'] as List;
  for (var element in listOfData) {
    // print(element);
    vehicleMakeList.add(element);
  }

  return vehicleMakeList;
}

Future<List<VehicleModel>> getSubModels(
    String make, String year, String type, String jwtToken) async {
  // await Future.delayed(const Duration(seconds: 5));

  List<VehicleModel> vehicleMakeList = [];
  if (type == 'Passenger vehicle') {
    String recallApi = 'https://carapi.app/api/models?year=$year&make=$make';
    http.Response response = await http.get(Uri.parse(recallApi), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $jwtToken'
    });
    final data = jsonDecode(response.body);

    List listOfData = data['data'] as List;
    for (var element in listOfData) {
      // print(element);
      vehicleMakeList.add(VehicleModel(
          id: element['make_id'] ?? 0,
          title: element['name'] ?? '',
          icon: '',
          vehicleTypeId: 0,
          vehicleMakeId: element['make_id'] ?? 0));
    }
  }

  return vehicleMakeList.isEmpty
      ? await getVehicleModel(int.tryParse(year)!, make, type)
      : vehicleMakeList;
}

Future<List> getTrimsToStoreData(String make, String year, String type,
    String model, String jwtToken) async {
  // await Future.delayed(const Duration(seconds: 5));

  List vehicleMakeList = [];

  String recallApi =
      'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
  http.Response response = await http.get(Uri.parse(recallApi), headers: {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $jwtToken'
  });
  final data = jsonDecode(response.body);

  List listOfData = data['data'] as List;

  for (var element in listOfData) {
    vehicleMakeList.add(element);
  }
  // vehicleMakeList.sort((a, b) => b.title.compareTo(a.title));
  return vehicleMakeList;
}

Future<List<VehicleModel>> getTrims(String make, String year, String type,
    String model, String jwtToken) async {
  // await Future.delayed(const Duration(seconds: 5));

  List<VehicleModel> vehicleMakeList = [];

  String recallApi =
      'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
  http.Response response = await http.get(Uri.parse(recallApi), headers: {
    'Content-type': 'application/json',
    'Authorization': 'Bearer $jwtToken'
  });
  final data = jsonDecode(response.body);
  List listOfData = data['data'] as List;
  // print(listOfData[0]);
  for (var element in listOfData) {
    vehicleMakeList.add(VehicleModel(
        id: element['make_model_id'] ?? 0,
        title: element['description'] ?? '',
        icon: '',
        vehicleTypeId: 0,
        vehicleMakeId: element['make_id'] ?? 0));
  }
  // vehicleMakeList.sort((a, b) => b.title.compareTo(a.title));
  return vehicleMakeList;
}

Future<List> getVehicleMakeToSaveData(String type, String jwtToken) async {
  String vehicleType = type == 'Passenger vehicle' ? 'Car' : type;
  // print(object);
  // await Future.delayed(const Duration(seconds: 5));

  try {
    List<Map<String, dynamic>> vehicleMakeList = [];
    if (vehicleType == 'Car') {
      String recallApi = 'https://carapi.app/api/makes';
      http.Response response = await http.get(Uri.parse(recallApi), headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $jwtToken'
      });
      final data = jsonDecode(response.body);
      List listOfData = data['data'] as List;
      for (var element in listOfData) {
        // print(element);
        vehicleMakeList.add(element);
      }
    }

    return vehicleMakeList;
  } catch (e) {
    return [];
  }
}

Future<List<VehicleMake>> getVehicleMake(String type, String jwtToken) async {
  String vehicleType = type == 'Passenger vehicle' ? 'Car' : type;
  // print(object);
  // await Future.delayed(const Duration(seconds: 5));

  try {
    List<VehicleMake> vehicleMakeList = [];
    if (vehicleType == 'Car') {
      String recallApi = 'https://carapi.app/api/makes';
      http.Response response = await http.get(Uri.parse(recallApi), headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $jwtToken'
      });
      final data = jsonDecode(response.body);
      List listOfData = data['data'] as List;
      for (var element in listOfData) {
        // print(element);
        vehicleMakeList.add(VehicleMake(
          id: element['id'] ?? 0,
          title: element['name'] ?? '',
          icon: '',
          vehicleTypeId: 0,
        ));
      }
    } else {
      http.Response response = await http.get(
          Uri.parse(
              'https://vpic.nhtsa.dot.gov/api/vehicles/GetMakesForVehicleType/$vehicleType?format=json'),
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
    }

    return vehicleMakeList;
  } catch (e) {
    return [];
  }
}

Future<List<int>> getVehicleYear(
    String make, String jwtToken, bool isCustomMake) async {
  List<int> vehicleMakeList = [];
  // await Future.delayed(const Duration(seconds: 5));
  if (isCustomMake) {
    List<int> years =
        List<int>.generate(2024 - 1800 + 1, (index) => 2024 - index);

    log(years.toString());
    vehicleMakeList = years;
  } else {
    http.Response response = await http
        .get(Uri.parse('https://carapi.app/api/years?make=$make'), headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $jwtToken'
    });
    final data = jsonDecode(response.body);
    List listOfData = data as List;

    // print(listOfData.length);
    for (var element in listOfData) {
      // print(element);
      vehicleMakeList.add(element);
    }
    if (vehicleMakeList.contains(2025)) {
      vehicleMakeList.remove(2025);
    }
    if (vehicleMakeList.isEmpty) {
      List<int> years =
          List<int>.generate(2024 - 1800 + 1, (index) => 2024 - index);

      vehicleMakeList = years;
    }
  }

  return vehicleMakeList;
}

Future<String> getJwtToken() async {
  http.Response response =
      await http.post(Uri.parse('https://carapi.app/api/auth/login'),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'text/plain',
          },
          body: jsonEncode({
            "api_token": 'ba831f89-cd77-4efc-9b3b-2a4ef151f959',
            "api_secret": 'c4234b2783a659dad7f5f13cbfc54683',
          }));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    return '';
  }
}

List<AdditionalServiceModel> getAdditionalService() {
  List<AdditionalServiceModel> list = [
    AdditionalServiceModel(name: 'Fix at my place', icon: icFixAtMyPlace),
    AdditionalServiceModel(name: 'Pick it up', icon: icPickUpMyVehicle),
  ];

  return list;
}

List<Service> getServices() {
  List<Service> services = [
    Service(name: "AC (Air conditioning)", image: icAc),
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
    Service(name: "Suspension/Chassis", image: icSuspenssionChassis),
    Service(name: "Drivetrain", image: icDrivetrain),
    Service(name: "Transmission", image: icTransmission),
  ];

  services.sort((a, b) => a.name.compareTo(b.name));
  return services;
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

class AdditionalServiceModel {
  final String name;
  final String icon;

  AdditionalServiceModel({required this.name, required this.icon});
}
