import 'dart:ui';

import 'package:flutter/material.dart';

Color changeColor({required String color}) {
  String hexColor = color;

  if (hexColor[0] == '#') {
    hexColor = hexColor.substring(1);
  }

  Color myColor = Color(int.parse('0xFF$hexColor'));
  return myColor;
}

Color primaryColor = const Color(0xff2A2E43);
Color primaryColor2 = changeColor(color: 'FF2F53');
String carApiToken = 'ba831f89-cd77-4efc-9b3b-2a4ef151f959';
String carApiSecret = 'fe2b4d59ddb5d026d6ba4690e596c183';
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
const String icFixAtMyPlace = 'assets/images/ic_fix_at_my_place.svg';
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
const String icPickUpMyVehicle = 'assets/images/ic_pick_up_my_vehicle.svg';
const String icPlus = 'assets/images/ic_plus.svg';
const String icSetting = 'assets/images/ic_setting.svg';
const String icSuspenssionChassis = 'assets/images/ic_suspenssion_chassis.svg';
const String icSwitch = 'assets/images/ic_switch.svg';
const String icTowing = 'assets/images/ic_towing.svg';
const String icUpholsteryRepair = 'assets/images/ic_upholstery_repair.svg';
const String icUserMarker = 'assets/images/ic_user_marker.svg';
const String icWheelRepair = 'assets/images/ic_wheel_repair.svg';
const String icWheelTires = 'assets/images/ic_wheel_tires.svg';
const String icWindshield = 'assets/images/ic_windshield.svg';
const String icWrench = 'assets/images/ic_wrench.svg';

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
