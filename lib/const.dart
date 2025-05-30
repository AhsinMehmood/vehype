import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'Models/vehicle_model.dart';

String debugOneSignalApiKey = 'd2e6efea-3e5f-42f9-85ab-9815924277a0';
String prodOneSignalApiKey = 'e236663f-f5c0-4a40-a2df-81e62c7d411f';
bool isDebug = false;
int maxVehiclesFree = 1;
int maxVehiclesPro = 5;
int maxRequestsFree = 1;
int maxRequestsPro = 5;
int maxQuestionsFree = 2;
int maxQuestionsPro = 8;
Duration requestsDuration = Duration(days: 7);
Duration aiQuestionsDuration = Duration(days: 1);

getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

double haversine(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Radius of Earth in kilometers
  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance in kilometers
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth's radius in kilometers
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distanceInKilometers = R * c; // Distance in kilometers
  return distanceInKilometers * 0.621371; // Distance in miles
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

bool areLocationsDifferent(
    double lat1, double lon1, double lat2, double lon2, double thresholdKm) {
  double distance = haversine(lat1, lon1, lat2, lon2);
  return distance <= thresholdKm;
}

Color changeColor({required String color}) {
  String hexColor = color;

  if (hexColor[0] == '#') {
    hexColor = hexColor.substring(1);
  }

  Color myColor = Color(int.parse('0xFF$hexColor'));
  // print(myColor.)
  /// DAMFTA4NRMKB7FA24869G82U
  return myColor;
}

String defaultImage =
    'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/user_place_holder.png?alt=media&token=c75336b0-87fb-4493-8d62-7c707d0b4757';

Color primaryColor = changeColor(color: '033043');
Color primaryColor2 = changeColor(color: 'FF2F53');
String carApiToken = 'ba831f89-cd77-4efc-9b3b-2a4ef151f959';
String carApiSecret = '2670c17201df7e3ecb7c5f82c274c855';
double maxHeightCapturedImage = 600;
double maxWidthCapturedImage = 600;
int qualityCapturedImage = 100;

int defaultSearchServiecRadius = 50;
int maxSearchServiecRadius = defaultSearchServiecRadius;
int uploadRequestImageLimit = 3;

double scopeUpdateInMile = 0.5;
int updateLocationIntervalInSec = 10;

String datePattern = "dd/MM/yyyy";
String dateTimePattern = "dd/MM/yyyy HH:mm";

String businessFilterSplitPattern = ",";

String poppinsRegular = "Poppins-Regular";
String poppinsLight = "Poppins-Light";
String poppinsMedium = "Poppins-Medium";
String poppinsBold = "Poppins-Bold";

const String colorPurple = '845EC2';
const String colorGrey80 = 'BABABA';
const String colorBlack60 = '8A8A8D';
const String colorBlue100 = '5CB8E4';
const String colorBlue20 = 'DEF0F9';
const String colorGreen100 = '16C79A';
const String colorGreen20 = 'D0F3EA';
const String colorOrange100 = 'F99417';
const String colorOrange20 = 'FDE9D0';
const String colorRed100 = 'F1526A';
const String colorRed20 = 'FCDCE1';
const String colorGrey100 = '9D9D9D';
const String colorGrey20 = 'EBEBEB';
const String colorYellow100 = 'FFC23C';
const String colorYellow20 = 'FFF2D8';

const String colorBlack100 = '3D3C42';
const String colorGrey60 = 'CECECE';
const String colorBlack80 = '636267';
const String colorPurple80 = 'A88ED4';

const String icPickUpMyVehicle = 'assets/images/ic_pick_up_my_vehicle.svg';
const String icFixAtMyPlace = 'assets/images/ic_fix_at_my_place.svg';

const String icAc = 'assets/images/ic_ac.svg';
const String icBodyPaint = 'assets/images/ic_body_paint.svg';
const String icBreakSystem = 'assets/images/ic_break_system.svg';
const String icBusinessMarker = 'assets/images/ic_business_marker.png';
const String icCamera = 'assets/images/ic_camera.svg';
const String icCanceledOrders = 'assets/images/ic_canceled_orders.svg';
const String icCarLift = 'assets/images/ic_car_lift.svg';
const String icDetailing = 'assets/images/ic_detailing.svg';
const String icDiagnostic = 'assets/images/ic_diagnostic.svg';
const String icDrivetrain = 'assets/images/ic_drivetrain.svg';
const String icElectrical = 'assets/images/ic_electrical.svg';
const String icEmissions = 'assets/images/ic_emissions.svg';
const String icEngine = 'assets/images/ic_engine.svg';
const String icFilter = 'assets/images/ic_filter.svg';
const String icGarage = 'assets/images/ic_garage.svg';
const String icGarageRent = 'assets/images/ic_garage_rent.svg';
const String icGlassDoorService = 'assets/images/ic_glass_door_service.svg';
const String icGoogle = 'assets/images/ic_google.svg';
const String icApple = 'assets/images/apple.png';

const String icGuest = 'assets/images/ic_guest.png';
const String icHelp = 'assets/images/ic_help.svg';
const String icHistory = 'assets/images/ic_history.svg';
const String icImageEmpty = 'assets/images/ic_image_empty.svg';
const String icInfo = 'assets/images/ic_info.svg';
const String icJumpstart = 'assets/images/ic_jumpstart.svg';
const String icLocation = 'assets/images/ic_location.svg';
const String icLocation1 = 'assets/images/ic_location_1.png';
const String icLockSmith = 'assets/images/ic_lock_smith.svg';
const String icLogin = 'assets/images/ic_login.svg';
const String icMinus = 'assets/images/ic_minus.svg';
const String icMyLocation = 'assets/images/ic_my_location.svg';
const String icOilChange = 'assets/images/ic_oil_change.svg';
const String icPartsSupplies = 'assets/images/ic_parts_supplies.svg';

const String icPlus = 'assets/images/ic_plus.svg';
const String icSetting = 'assets/images/ic_setting.svg';
const String icSuspenssionChassis = 'assets/images/ic_suspenssion_chassis.svg';
const String icSwitch = 'assets/images/ic_switch.svg';
const String icTowing = 'assets/images/ic_towing.svg';
const String icUpholsteryRepair = 'assets/images/ic_upholstery_repair.svg';
const String icUserMarker = 'assets/images/ic_user_marker.svg';
const String icWheelRepair = 'assets/rims_Repair_Bright.svg';
const String icWheelTires = 'assets/images/ic_wheel_tires.svg';
const String icWindshield = 'assets/images/ic_windshield.svg';
const String icWrench = 'assets/images/ic_wrench.svg';
const String icTransmission = 'assets/transmission_Icon_Dark_4-01.svg';

List<String> checkBadWords(String inputText) {
  List<String> detectedBadWords = [];

  // print(detectedBadWords.length);
  return detectedBadWords;
}

TextStyle textLable1Style() {
  return TextStyle(
    overflow: TextOverflow.ellipsis,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: poppinsBold,
  );
}

TextStyle textFieldLableStyle() {
  return TextStyle(
      overflow: TextOverflow.ellipsis,
      fontSize: 13,
      fontFamily: poppinsRegular,
      fontWeight: FontWeight.w600,
      color: Colors.grey[400]);
}

TextStyle textDialogStyle() {
  return TextStyle(
    fontSize: 16,
    fontFamily: poppinsRegular,
  );
}

TextStyle textButtonStyle() {
  return TextStyle(
      overflow: TextOverflow.ellipsis,
      fontSize: 12,
      decoration: TextDecoration.underline,
      decorationColor: primaryColor,
      fontFamily: poppinsMedium,
      fontWeight: FontWeight.w600,
      color: Colors.black54);
}

String apiKey = 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E';
Future<String> getCountryFromLatLng(double latitude, double longitude) async {
// Replace with your Google Maps API key
  String url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'OK' &&
          json['results'] != null &&
          json['results'].isNotEmpty) {
        // print(json['results'][0].toString());
        for (var result in json['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('country')) {
              return component[
                  'short_name']; // Returns country code (e.g., "US", "PK")
            }
          }
        }
        return '';
      } else {
        return '';
      }
    } else {
      return '';
    }
  } catch (e) {
    print(e);
    return '';
  }
}

Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  // Replace with your Google Maps API key
  String url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'OK' &&
          json['results'] != null &&
          json['results'].isNotEmpty) {
        return json['results'][2]['formatted_address'];
      } else {
        return 'Address not found';
      }
    } else {
      return 'Error retrieving address';
    }
  } catch (e) {
    print(e);
    return 'Failed to fetch address';
  }
}

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
  VehicleType(title: "Off-road vehicles", icon: 'assets/off_road_vehicle.svg'),
];
// Function to map vehicle type from VIN API response
VehicleType? mapVehicleType(String? apiVehicleType) {
  if (apiVehicleType == null) return null;

  apiVehicleType = apiVehicleType.toUpperCase();

  if (apiVehicleType.contains("PASSENGER")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Passenger vehicles");
  } else if (apiVehicleType.contains("PICKUP") ||
      apiVehicleType.contains("MPV")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Pickup Trucks");
  } else if (apiVehicleType.contains("MOTORCYCLE")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Motorcycles");
  } else if (apiVehicleType.contains("BUS") || apiVehicleType.contains("VAN")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Bus/Van");
  } else if (apiVehicleType.contains("TRUCK")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Semi-trucks");
  } else if (apiVehicleType.contains("TRAILER")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Trailers");
  } else if (apiVehicleType.contains("INCOMPLETE")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Incomplete Vehicles");
  } else if (apiVehicleType.contains("LOW SPEED")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Low-speed vehicles");
  } else if (apiVehicleType.contains("OFF ROAD")) {
    return vehicleTypeList.firstWhere((v) => v.title == "Off-road vehicles");
  } else {
    return null;
  }
}
