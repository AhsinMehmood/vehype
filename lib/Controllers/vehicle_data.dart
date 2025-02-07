import 'dart:convert';
// import 'dart:developer';
import 'dart:math';
// import 'package:hive_ce/hive.dart';
// import 'package:isar/isar.dart'; /
import 'package:vehype/Models/vehicle_model.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;

import '../Database/database.dart';

List<VehicleType> getVehicleTypeForPref() {
  List<VehicleType> vehicleTypeList = [
    VehicleType(
        title: "Passenger vehicles", icon: 'assets/passenger_vehicle.svg'),
    VehicleType(title: "Pickup Trucks", icon: 'assets/pickup_truck_light.svg'),
    VehicleType(title: "Motorcycles", icon: 'assets/motorcycle.svg'),
    VehicleType(title: "Bus/Van", icon: 'assets/bus.svg'),
    VehicleType(title: "Semi-trucks", icon: 'assets/truck.svg'),
    VehicleType(title: "Trailers", icon: 'assets/trailer.svg'),
    VehicleType(
        title: "Incomplete Vehicles", icon: 'assets/incomplete_vehicle.svg'),
    VehicleType(
        title: "Low-speed vehicles", icon: 'assets/low_speed_vehicle.svg'),
    VehicleType(
        title: "Off-road vehicles", icon: 'assets/off_road_vehicle.svg'),
  ];

  return vehicleTypeList;
}

Map<String, String> titleMapping = {
  "Passenger vehicles": "Passenger vehicle",
  "Pickup Trucks": "Pickup Trucks",
  "Motorcycles": "Motorcycle",
  "Bus/Van": "Bus",
  "Semi-trucks": "Truck",
  "Trailers": "Trailer",
  "Incomplete Vehicles": "Incomplete Vehicle",
  "Low-speed vehicles": "Low speed vehicle",
  "Off-road vehicles": "Off road vehicle",
};
List<VehicleType> getVehicleType() {
  List<VehicleType> vehicleTypeList = [
    VehicleType(
        title: "Passenger vehicles", icon: 'assets/passenger_vehicle.svg'),
    VehicleType(title: "Pickup Trucks", icon: 'assets/pickup_truck_light.svg'),
    VehicleType(title: "Motorcycles", icon: 'assets/motorcycle.svg'),
    VehicleType(title: "Bus/Van", icon: 'assets/bus.svg'),
    VehicleType(title: "Semi-trucks", icon: 'assets/truck.svg'),
    VehicleType(title: "Trailers", icon: 'assets/trailer.svg'),
    VehicleType(
        title: "Incomplete Vehicles", icon: 'assets/incomplete_vehicle.svg'),
    VehicleType(
        title: "Low-speed vehicles", icon: 'assets/low_speed_vehicle.svg'),
    VehicleType(
        title: "Off-road vehicles", icon: 'assets/off_road_vehicle.svg'),
  ];

  return vehicleTypeList;
}

Future<List<VehicleModel>> getVehicleModel(
    int year, String make, String type) async {
  String vehicleType =
      titleMapping[type] == 'Passenger vehicle' ? 'Car' : titleMapping[type]!;

  String cacheKey = 'vehicleModels-$year-$make'; // Unique key for caching

  Map<String, dynamic>? cachedData = await dbHelper.getJsonData(cacheKey);
  print(cachedData);

  if (cachedData != null) {
    List<dynamic> cachedList = cachedData['data'];
    print(cachedList);
    return cachedList
        .map((e) => VehicleModel(
              id: e['Make_ID'] ?? 0,
              title: e['Model_Name'] ?? '',
              icon: '',
              vehicleTypeId: 0,
              vehicleMakeId: e['Make_ID'] ?? 0,
            ))
        .toList();
  }

  List<VehicleModel> vehicleMakeList = [];

  try {
    http.Response response = await http.get(
      Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/$make/modelyear/$year/vehicletype/$vehicleType?format=json'),
      headers: {'Content-type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    List listOfData = data['Results'] as List;

    for (var element in listOfData) {
      vehicleMakeList.add(VehicleModel(
        id: element['Make_ID'],
        title: element['Model_Name'],
        icon: '',
        vehicleMakeId: element['Make_ID'],
        vehicleTypeId: 0,
      ));
    }

    // Adding extra models for "Bobcat" make
    if (make == 'Bobcat') {
      vehicleMakeList.addAll([
        VehicleModel(
            id: 0,
            title: 'UV34 Gas',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'UV34 Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'UV34 XL Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'UV34 XL GAS',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY11 GAS',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY11 Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY12 GAS',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY12 Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY13 GAS',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY13 Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY14 GAS',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
        VehicleModel(
            id: 0,
            title: 'MY14 Diesel',
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0),
      ]);
    }

    // Cache the result in HiveCE
    // await box.put(cacheKey, vehicleMakeList.map((e) => e.toJson()).toList());
    try {
      await dbHelper.saveJsonData(cacheKey, {'data': listOfData});
    } catch (e) {
      print(e);
    }
    return vehicleMakeList;
  } catch (e) {
    print(e.toString() + ' Get Vehicle make error');

    return [];
  }
}

final dbHelper = DatabaseHelper();
Future<List<VehicleModel>> getSubModels(
    String make, String year, String type, String jwtToken) async {
  String vehicleType = titleMapping[type]!;
  String cacheKey = 'models-$year-$make';
  print(cacheKey);
  if (vehicleType == 'Pickup Trucks') {
    List<VehicleModel> pickupModels = [];
    for (var element in pickupTrucksModels) {
      if (element['makeName'].toString().toLowerCase() == make.toLowerCase()) {
        pickupModels.add(VehicleModel(
            id: 0,
            title: element['modelName'],
            icon: '',
            vehicleMakeId: 0,
            vehicleTypeId: 0));
      }
    }
    return pickupModels;
  } else {
    try {
      // **Check cache first**
      Map<String, dynamic>? cachedData = await dbHelper.getJsonData(cacheKey);
      print(cachedData);

      if (cachedData != null) {
        List<dynamic> cachedList = cachedData['data'];
        print(cachedList);
        return cachedList
            .map((e) => VehicleModel(
                  id: e['make_id'] ?? 0,
                  title: e['name'] ?? '',
                  icon: '',
                  vehicleTypeId: 0,
                  vehicleMakeId: e['make_id'] ?? 0,
                ))
            .toList();
      }

      // **Fetch from API**
      List<VehicleModel> vehicleMakeList = [];
      if (vehicleType == 'Passenger vehicle') {
        String recallApi =
            'https://carapi.app/api/models?year=$year&make=$make';
        http.Response response = await http.get(Uri.parse(recallApi), headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        });

        final data = jsonDecode(response.body);
        List listOfData = data['data'] as List;
        print('object');

        for (var element in listOfData) {
          vehicleMakeList.add(VehicleModel(
            id: element['make_id'] ?? 0,
            title: element['name'] ?? '',
            icon: '',
            vehicleTypeId: 0,
            vehicleMakeId: element['make_id'] ?? 0,
          ));
        }

        // **Save JSON to SQLite**
        try {
          await dbHelper.saveJsonData(cacheKey, {'data': listOfData});
        } catch (e) {
          print(e);
        }
      }

      return vehicleMakeList.isEmpty
          ? await getVehicleModel(int.tryParse(year)!, make, type)
          : vehicleMakeList;
    } catch (e) {
      print(e.toString() + ' Get Vehicle model error');
      return await getVehicleModel(int.tryParse(year)!, make, type);
    }
  }
}

Future<List<VehicleModel>> getTrims(String make, String year, String typess,
    String model, String jwtToken) async {
  String cacheKey = 'vehicleTrims-$year-$make-$model';
  if (titleMapping[typess] == 'Pickup Trucks') {
    List<VehicleModel> pickupModels = [];
    for (var element in pickupTrucksTrims) {
      print(make);

      if (element['modelName'].toString().toLowerCase() ==
          model.toLowerCase()) {
        for (var trim in element['trims']) {
          pickupModels.add(VehicleModel(
              id: 0,
              title: trim['trimName'],
              icon: '',
              vehicleMakeId: 0,
              vehicleTypeId: 0));
        }
      }
    }
    return pickupModels;
  } else {
    Map<String, dynamic>? cachedData = await dbHelper.getJsonData(cacheKey);
    print(cachedData);

    if (cachedData != null) {
      List<dynamic> cachedList = cachedData['data'];
      print(cachedList);
      return cachedList
          .map((e) => VehicleModel(
                id: 0,
                title: e['description'] ?? '',
                icon: '',
                vehicleTypeId: 0,
                vehicleMakeId: 0,
              ))
          .toList();
    }

    List<VehicleModel> vehicleMakeList = [];

    try {
      String recallApi =
          'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
      http.Response response = await http.get(Uri.parse(recallApi), headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $jwtToken'
      });

      final data = jsonDecode(response.body);
      // print(data);
      List listOfData = data['data'] as List;

      for (var element in listOfData) {
        vehicleMakeList.add(VehicleModel(
            id: 0,
            title: element['description'] ?? '',
            icon: '',
            vehicleTypeId: 0,
            vehicleMakeId: 0));
      }

      // Cache the result in HiveCE
      // await box.put(cacheKey, vehicleMakeList.map((e) => e.toJson()).toList());
      try {
        await dbHelper.saveJsonData(cacheKey, {'data': listOfData});
      } catch (e) {
        print(e);
      }

      return vehicleMakeList;
    } catch (e) {
      print(e.toString() + ' Get Trims error');
      return vehicleMakeList;
    }
  }
}

Future<List<VehicleMake>> getVehicleMake(String type, String jwtToken) async {
  String vehicleType =
      titleMapping[type] == 'Passenger vehicle' ? 'Car' : titleMapping[type]!;
  // print(object);
  // await Future.delayed(const Duration(seconds: 5));
  if (vehicleType == 'Pickup Trucks') {
    return getPickupTrucksMakes();
  } else {
    // List<VehicleMake> vehicleMakeList = [];
    String cacheKey = 'vehicleMakes-$type';

    try {
      List<VehicleMake> vehicleMakeList = [];

      // Fetch from API if not in cache
      if (vehicleType == 'Car') {
        Map<String, dynamic>? cachedData = await dbHelper.getJsonData(cacheKey);
        // print(cachedData);

        if (cachedData != null) {
          List<dynamic> cachedList = cachedData['data'];
          print(cachedList);
          return cachedList
              .map((e) => VehicleMake(
                    id: 0,
                    title: e['name'] ?? '',
                    icon: '',
                    vehicleTypeId: 0,
                  ))
              .toList();
        }
        String recallApi = 'https://carapi.app/api/makes';
        http.Response response = await http.get(Uri.parse(recallApi), headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        });
        final data = jsonDecode(response.body);
        List listOfData = data['data'] as List;

        for (var element in listOfData) {
          vehicleMakeList.add(VehicleMake(
            id: element['id'] ?? 0,
            title: element['name'] ?? '',
            icon: '',
            vehicleTypeId: 0,
          ));
        }
        try {
          await dbHelper.saveJsonData(cacheKey, {'data': listOfData});
        } catch (e) {
          print(e);
        }
      } else {
        Map<String, dynamic>? cachedData = await dbHelper.getJsonData(cacheKey);
        print(cachedData);

        if (cachedData != null) {
          List<dynamic> cachedList = cachedData['data'];
          print(cachedList);
          return cachedList
              .map((e) => VehicleMake(
                    id: 0,
                    title: e['MakeName'] ?? '',
                    icon: '',
                    vehicleTypeId: 0,
                  ))
              .toList();
        }
        http.Response response = await http.get(
            Uri.parse(
                'https://vpic.nhtsa.dot.gov/api/vehicles/GetMakesForVehicleType/$vehicleType?format=json'),
            headers: {
              'Content-type': 'application/json',
            });
        final data = jsonDecode(response.body);
        List listOfData = data['Results'] as List;

        for (var element in listOfData) {
          vehicleMakeList.add(VehicleMake(
              id: element['MakeId'] ?? 0,
              title: element['MakeName'] ?? '',
              icon: '',
              vehicleTypeId: 0));
        }
        try {
          await dbHelper.saveJsonData(cacheKey, {'data': listOfData});
        } catch (e) {
          print(e);
        }
        if (vehicleType == 'Low speed vehicle') {
          vehicleMakeList.add(
              VehicleMake(id: 0, title: 'Bobcat', icon: '', vehicleTypeId: 0));
        }
        if (vehicleType == 'Truck') {
          vehicleMakeList.removeWhere((test) => test.title == 'ACURA');
        }
      }

      // Store fetched data in HiveCE as JSON string
      // await box.put(vehicleType,
      //     jsonEncode(vehicleMakeList.map((e) => e.toJson()).toList()));

      return vehicleMakeList;
    } catch (e) {
      print(e.toString() + ' Get Vehicle make error');

      return [];
    }
  }
}

Future<List<int>> getVehicleYear(
    String make, String jwtToken, bool isCustomMake) async {
  List<int> vehicleMakeList = [];
  // await Future.delayed(const Duration(seconds: 5));
  if (isCustomMake) {
    List<int> years =
        List<int>.generate(2025 - 1800 + 1, (index) => 2025 - index);

    // log(years.toString());
    vehicleMakeList = years;
  } else {
    http.Response response = await http.get(
        Uri.parse('https://carapi.app/api/years?limit=500&make=$make'),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $jwtToken'
        });
    final data = jsonDecode(response.body);
    // log(data.toString() + ' sdjkldsj');

    List listOfData = data as List;

    // print(listOfData.length);
    for (var element in listOfData) {
      // print(element);
      vehicleMakeList.add(element);
    }
    // if (vehicleMakeList.contains(2025)) {
    //   vehicleMakeList.remove(2025);
    // }
    if (vehicleMakeList.isEmpty) {
      List<int> years =
          List<int>.generate(2025 - 1800 + 1, (index) => 2025 - index);

      vehicleMakeList = years;
    }
  }

  return vehicleMakeList;
}

List<VehicleMake> getPickupTrucksMakes() {
  List<VehicleMake> makes = [];
  try {
    for (var element in pickupTrucksMakes) {
      print(element);
      makes.add(VehicleMake(
          id: element['Id'] ?? 0,
          title: element['makeName'],
          icon: '',
          vehicleTypeId: 0));
    }
  } catch (e) {
    print(e);
  }
  return makes;
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

List pickupTrucksTrims = [
  {
    "makeName": "Ford",
    "modelName": "F-1",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom Cab"},
      {"trimName": "Deluxe Cab"}
    ]
  },
  {
    "makeName": "Ford",
    "modelName": "F-100",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"},
      {"trimName": "Ranger"},
      {"trimName": "Explorer"}
    ]
  },
  {
    "makeName": "Ford",
    "modelName": "F-150",
    "trims": [
      {"trimName": "XL"},
      {"trimName": "XLT"},
      {"trimName": "Lariat"},
      {"trimName": "King Ranch"},
      {"trimName": "Platinum"},
      {"trimName": "Limited"},
      {"trimName": "Raptor"}
    ]
  },
  {
    "makeName": "Ford",
    "modelName": "Ranger",
    "trims": [
      {"trimName": "XL"},
      {"trimName": "XLT"},
      {"trimName": "Lariat"},
      {"trimName": "Tremor"}
    ]
  },
  {
    "makeName": "Ford",
    "modelName": "Lightning (Electric)",
    "trims": [
      {"trimName": "Pro"},
      {"trimName": "XLT"},
      {"trimName": "Lariat"},
      {"trimName": "Platinum"}
    ]
  },
  {
    "makeName": "Chevrolet",
    "modelName": "C/K Series",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"},
      {"trimName": "Scottsdale"},
      {"trimName": "Silverado"}
    ]
  },
  {
    "makeName": "Chevrolet",
    "modelName": "Silverado",
    "trims": [
      {"trimName": "Work Truck (WT)"},
      {"trimName": "Custom"},
      {"trimName": "LT"},
      {"trimName": "RST"},
      {"trimName": "Trail Boss"},
      {"trimName": "High Country"}
    ]
  },
  {
    "makeName": "Chevrolet",
    "modelName": "Colorado",
    "trims": [
      {"trimName": "Work Truck (WT)"},
      {"trimName": "LT"},
      {"trimName": "Z71"},
      {"trimName": "Trail Boss"},
      {"trimName": "ZR2"}
    ]
  },
  {
    "makeName": "Dodge/Ram",
    "modelName": "1500/2500/3500",
    "trims": [
      {"trimName": "Tradesman"},
      {"trimName": "Big Horn"},
      {"trimName": "Laramie"},
      {"trimName": "Rebel"},
      {"trimName": "Limited"},
      {"trimName": "TRX"}
    ]
  },
  {
    "makeName": "Dodge/Ram",
    "modelName": "Power Wagon",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"},
      {"trimName": "Warlock"}
    ]
  },
  {
    "makeName": "GMC",
    "modelName": "Sierra",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "SLE"},
      {"trimName": "SLT"},
      {"trimName": "AT4"},
      {"trimName": "Denali"}
    ]
  },
  {
    "makeName": "GMC",
    "modelName": "Canyon",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "SLE"},
      {"trimName": "SLT"},
      {"trimName": "AT4"},
      {"trimName": "Denali"}
    ]
  },
  {
    "makeName": "Toyota",
    "modelName": "Tacoma",
    "trims": [
      {"trimName": "SR"},
      {"trimName": "SR5"},
      {"trimName": "TRD Sport"},
      {"trimName": "TRD Off-Road"},
      {"trimName": "Limited"},
      {"trimName": "TRD Pro"}
    ]
  },
  {
    "makeName": "Toyota",
    "modelName": "Tundra",
    "trims": [
      {"trimName": "SR"},
      {"trimName": "SR5"},
      {"trimName": "Limited"},
      {"trimName": "Platinum"},
      {"trimName": "1794 Edition"},
      {"trimName": "TRD Pro"}
    ]
  },
  {
    "makeName": "Nissan",
    "modelName": "Titan",
    "trims": [
      {"trimName": "S"},
      {"trimName": "SV"},
      {"trimName": "Pro-4X"},
      {"trimName": "SL"},
      {"trimName": "Platinum Reserve"}
    ]
  },
  {
    "makeName": "Nissan",
    "modelName": "Frontier",
    "trims": [
      {"trimName": "S"},
      {"trimName": "SV"},
      {"trimName": "Pro-4X"},
      {"trimName": "SL"}
    ]
  },
  {
    "makeName": "International Harvester",
    "modelName": "Scout",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Scout 80"},
      {"trimName": "Scout 800"}
    ]
  },
  {
    "makeName": "International Harvester",
    "modelName": "Travelall",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"},
      {"trimName": "Deluxe"}
    ]
  },
  {
    "makeName": "Jeep",
    "modelName": "Gladiator",
    "trims": [
      {"trimName": "Sport"},
      {"trimName": "Overland"},
      {"trimName": "Rubicon"},
      {"trimName": "Mojave"}
    ]
  },
  {
    "makeName": "Jeep",
    "modelName": "Comanche",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"},
      {"trimName": "Eliminator"}
    ]
  },
  {
    "makeName": "Honda",
    "modelName": "Ridgeline",
    "trims": [
      {"trimName": "Sport"},
      {"trimName": "RTL"},
      {"trimName": "RTL-E"},
      {"trimName": "Black Edition"}
    ]
  },
  {
    "makeName": "Studebaker",
    "modelName": "Champ",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"}
    ]
  },
  {
    "makeName": "Studebaker",
    "modelName": "Coupe Express",
    "trims": [
      {"trimName": "Base"}
    ]
  },
  {
    "makeName": "Hummer",
    "modelName": "H2 SUT",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Adventure Series"}
    ]
  },
  {
    "makeName": "Hummer",
    "modelName": "Hummer EV Pickup",
    "trims": [
      {"trimName": "EV2"},
      {"trimName": "EV2X"},
      {"trimName": "EV3X"}
    ]
  },
  {
    "makeName": "Mercury",
    "modelName": "M-Series",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"}
    ]
  },
  {
    "makeName": "Tesla",
    "modelName": "Cybertruck",
    "trims": [
      {"trimName": "Single Motor RWD"},
      {"trimName": "Dual Motor AWD"},
      {"trimName": "Tri Motor AWD"}
    ]
  },
  {
    "makeName": "Rivian",
    "modelName": "R1T",
    "trims": [
      {"trimName": "Adventure"},
      {"trimName": "Explore"}
    ]
  },
  {
    "makeName": "Mazda",
    "modelName": "B-Series",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "DX"},
      {"trimName": "LX"}
    ]
  },
  {
    "makeName": "Plymouth",
    "modelName": "Trail Duster",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Custom"}
    ]
  },
  {
    "makeName": "Subaru",
    "modelName": "Brat",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "GL"}
    ]
  },
  {
    "makeName": "Subaru",
    "modelName": "Baja",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Sport"},
      {"trimName": "Turbo"}
    ]
  },
  {
    "makeName": "AMC",
    "modelName": "J-Series",
    "trims": [
      {"trimName": "Base"},
      {"trimName": "Honcho"},
      {"trimName": "Custom"}
    ]
  }
];
List pickupTrucksModels = [
  // {"makeName": "Ford", "modelName": "F-Series (F-1, F-100, F-150)"},
  {"makeName": "Ford", "modelName": "F-1"},
  {"makeName": "Ford", "modelName": "F-100"},
  {"makeName": "Ford", "modelName": "F-150"},
  {"makeName": "Ford", "modelName": "Ranger"},

  {"makeName": "Ford", "modelName": "Lightning (Electric)"},
  {"makeName": "Chevrolet", "modelName": "C/K Series"},
  {"makeName": "Chevrolet", "modelName": "Silverado"},
  {"makeName": "Chevrolet", "modelName": "Colorado"},
  {"makeName": "Dodge/Ram", "modelName": "1500/2500/3500"},
  {"makeName": "Dodge/Ram", "modelName": "Power Wagon"},
  {"makeName": "GMC", "modelName": "Sierra"},
  {"makeName": "GMC", "modelName": "Canyon"},
  {"makeName": "Toyota", "modelName": "Tacoma"},
  {"makeName": "Toyota", "modelName": "Tundra"},
  {"makeName": "Nissan", "modelName": "Titan"},
  {"makeName": "Nissan", "modelName": "Frontier"},
  {"makeName": "International Harvester", "modelName": "Scout"},
  {"makeName": "International Harvester", "modelName": "Travelall"},
  {"makeName": "Jeep", "modelName": "Gladiator"},
  {"makeName": "Jeep", "modelName": "Comanche"},
  {"makeName": "Honda", "modelName": "Ridgeline"},
  {"makeName": "Studebaker", "modelName": "Champ"},
  {"makeName": "Studebaker", "modelName": "Coupe Express"},
  {"makeName": "Hummer", "modelName": "H2 SUT"},
  {"makeName": "Hummer", "modelName": "Hummer EV Pickup"},
  {"makeName": "Mercury", "modelName": "M-Series"},
  {"makeName": "Tesla", "modelName": "Cybertruck"},
  {"makeName": "Rivian", "modelName": "R1T"},
  {"makeName": "Mazda", "modelName": "B-Series"},
  {"makeName": "Plymouth", "modelName": "Trail Duster"},
  {"makeName": "Subaru", "modelName": "Brat"},
  {"makeName": "Subaru", "modelName": "Baja"},
  {"makeName": "AMC", "modelName": "J-Series"}
];

List pickupTrucksMakes = [
  {"makeName": "Ford"},
  {"makeName": "Chevrolet"},
  {"makeName": "Dodge/Ram"},
  {"makeName": "GMC"},
  {"makeName": "Toyota"},
  {"makeName": "Nissan"},
  {"makeName": "International Harvester"},
  {"makeName": "Jeep"},
  {"makeName": "Honda"},
  {"makeName": "Studebaker"},
  {"makeName": "Hummer"},
  {"makeName": "Mercury"},
  {"makeName": "Tesla"},
  {"makeName": "Rivian"},
  {"makeName": "Mazda"},
  {"makeName": "Plymouth"},
  {"makeName": "Subaru"},
  {"makeName": "AMC"}
];
