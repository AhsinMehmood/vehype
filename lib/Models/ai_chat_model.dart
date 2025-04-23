import 'dart:io';

class AiChatModel {
  final String intent;
  final String response;
  final bool isUser;
  final bool hasSuggestions;
  final File? file;
  final String imageUrl;
  final String garageId;
  final String offerId;
  final bool showServices;
  final String service;
  final bool showGuide;
  final bool showVehicle;
  final Map<String, dynamic> repairGuide;
  AiChatModel(
      {required this.intent,
      required this.response,
      required this.showServices,
      required this.imageUrl,
      required this.offerId,
      required this.garageId,
      required this.service,
      required this.repairGuide,
      required this.showGuide,
      required this.showVehicle,
      required this.isUser,
      required this.hasSuggestions,
      required this.file});
}
