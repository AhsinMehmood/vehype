import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/ai_chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/providers/firebase_storage_provider.dart';
import 'package:vehype/providers/garage_provider.dart';
import 'package:vehype/providers/generate_photo_provider.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/mix_panel_controller.dart';
import '../Controllers/notification_controller.dart';
import '../Controllers/offers_controller.dart';
import '../Models/offers_model.dart';
import '../Models/vehicle_model.dart';
import '../const.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class AssistanceChatProvider with ChangeNotifier {
  List<AiChatModel> _aiChats = [];
  ChatSession? _chatSession;
  ChatSession? get chatSession => _chatSession;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool get isListening => _isListening;
  double _soundLevel = 0.0;
  double get soundLevel => _soundLevel;

  Future<String?> startListening(
    GarageProvider garageController,
    UserModel userModel,
    FirebaseStorageProvider firebaseStorageProvider,
    OffersProvider offersProvider,
  ) async {
    bool available = await _speech.initialize();
    final Completer<String?> completer = Completer<String?>();

    if (available) {
      _isListening = true;
      _isConverting = false;
      notifyListeners();

      _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: false,
          autoPunctuation: true,
          cancelOnError: true,
          onDevice: false,
        ),

        onResult: (result) async {
          if (result.finalResult && !completer.isCompleted) {
            _isListening = false;
            _isConverting = true;
            notifyListeners();

            await Future.delayed(const Duration(milliseconds: 500), () {
              _isConverting = false;
              notifyListeners();
              completer.complete(result.recognizedWords);
            });
          } else {}
          // _isConverting = false;
          // notifyListeners();
        },
        // onSoundLevelChangeTimeout: Duration(seconds: 2),
        // Optional: you can stop listening after silence timeout
      );
    } else {
      completer.complete(null);
    }

    return completer.future;
  }

  final List<double> _soundWave = List.filled(50, 0.0); // fixed-length history
  List<double> get soundWave => _soundWave;
  bool _isConverting = false;
  bool get isConverting => _isConverting;

  void setConverting(bool value) {
    _isConverting = value;
    notifyListeners();
  }

  void updateSoundLevel(double level) {
    // Normalize the level [0–60] to [0–1]
    double normalized = ((level + 60).clamp(0.0, 60.0)) / 60.0;

    log(normalized.toString());
    // Keep fixed length list
    _soundWave.removeAt(0);
    _soundWave.add(normalized);

    notifyListeners();
  }

  void stopListening() {
    // setConverting(true);
    _speech.stop();
    _soundLevel = 0.0;
    _isListening = false;
    notifyListeners();
  }

  clearChats() {
    _aiChats = [];
    // notifyListeners();
  }

//   Devel@@.@@1
  List<AiChatModel> get aiChats => _aiChats.reversed.toList();
  final vertexAI = FirebaseVertexAI.instance;
  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  closeChatSession() {
    _chatSession = null;
  }

  startChatSession() {
    List<String> services = [];
    List<String> vehicleTypes = [];

    List<String> intents = [
      'add_vehicle',
      'delete_vehicle',
      'repair_guide',
      'create_a_request',
      'add_image_to_vehicle',
      'find_nearby_services',
      'unknown'
    ];

    for (var element in getServices()) {
      services.add(element.name);
    }
    for (var element in getVehicleType()) {
      vehicleTypes.add(element.title);
    }

    final jsonSchema = Schema.object(
      properties: {
        'response': Schema.object(
          properties: {
            'status': Schema.enumString(enumValues: [
              'unknown',
              'incomplete',
              'complete',
              'decline',
              'awaiting_submodel'
            ]),
            'imageUrl': Schema.string(),
            'image_type': Schema.enumString(enumValues: ['upload_image']),
            'message': Schema.string(),
            'service': Schema.enumString(enumValues: ['unknown', ...services]),
            'intent': Schema.enumString(enumValues: intents),
            'vehicleId': Schema.string(),
            'request_description': Schema.string(nullable: true),
            'vinNumber': Schema.string(),
            'show_services': Schema.boolean(),
            'show_guide': Schema.boolean(),
            'selected_submodel': Schema.string(),
            'offerId': Schema.string(
                description: 'The id of their selected open request'),

            // 'generateImagePrompt': Schema.string(
            //   description: 'include vehicle type, make, model and year',
            // ),
            'vehicleModel': Schema.string(),
            'vehicleMake': Schema.string(),
            'vehicleYear': Schema.string(),
            'vehicleType': Schema.enumString(enumValues: vehicleTypes),
            'repairGuide': Schema.object(properties: {
              'toolsRequired': Schema.array(items: Schema.string()),
              'steps': Schema.array(items: Schema.string()),
              'partsRequired': Schema.array(items: Schema.string()),
              'timeEstimate': Schema.string(),
              'costEstimate': Schema.string(),
              'sources': Schema.array(items: Schema.string()),
            })
          },
        ),
      },
      // optionalProperties: ['service', 'intent', 'vehicleType'],
    );
    try {
      final GenerativeModel generativeModel =
          FirebaseVertexAI.instance.generativeModel(
        systemInstruction: Content.system('''
You are VEHYPE's intelligent AI assistant. Understand the user's intent and respond with a JSON object matching the following schema (under the "response" key):

{
  "intent": "...",
  "status": "...", // "complete", "incomplete", "decline", "awaiting_submodel" or "unknown"
  "vehicleId": "...",
  "imageUrl": "...",
  "image_type": "upload_image",
  "vehicleMake": "...",
  "vehicleModel": "...",
  "vehicleYear": "...",
  'selected_submodel': "...",
  "vehicleType": "...",
  "vinNumber": "...",
  "message": "...", // keep it short and helpful
  "service": "...", // from known services
  "request_description": "...",
  "show_services": true/false,
  "show_guide": true/false,
  "offerId": "...",
  "repairGuide": {
    "toolsRequired": [...],
    "partsRequired": [...],
    "timeEstimate": "...",
    "costEstimate": "...",
    "sources": [...]
  }
}

---


### 🔍 INTENT MAPPING RULES

- "Park a vehicle" → intent: **add_vehicle**
- Mentions of "My Garage" → refers to vehicle list
- "Add Image to Vehicle" → intent: **add_image_to_vehicle**
- "Service Request" → intent: **create_a_request**
- "Repair Guide" → intent: **repair_guide**
- "Nearby Services" → intent: **find_nearby_services**
- "Delete Vehicle" → intent: **delete_vehicle**

---

### 🧠 LOGIC FOR EACH INTENT


#### 🆕 add_vehicle
- If an image is attached, extract `make`, `model`, and `year` from it.
- If the vehicle year is greater than 2027, politely respond:
  _ "Sorry, we currently don’t have information for vehicles outside 2027."_ 

- If vehicle type is Passenger vehicles or Pickup trucks then ask for the submodel from the provided list and include count number and submodel in the message so user can see and select and if subModelsForSpecificMakeYearModelAndType is empty then ask for it and if user says show options or something then show them.
- Don't mark status as `complete` unless confirmed.



- Include a valid `vehicleType` from known types.

#### 🧽 add_image_to_vehicle
- Ask the user to select a vehicle from their vehicle list. If they recently added a vehicle, automatically include it and ask for confirmation. Please do not include garage IDs in the message—only include the vehicle's make, model, year, submodel (if available), and a count number.
- Return `image_type`, and set `status: "complete"` once image is accepted.

#### 🛠️ create_a_request
- Ask user to describe the issue or service needed if not provided yet.
- Ask the user to select vehicle from their vehicle list. Please do not include garage IDs in the message only include the vehicle's make, model, year, submodel (if availabe), and a count number.
- Once a service is provided and a vehicle is selected, include `vehicleId`, and `service`.
- Do not mark the status as 'complete' until don't have service.
- Inform user when the request is created: "Your request has been created and nearby service providers have been notified."
- Set status to `"complete"`.

#### 🧭 find_nearby_services
- Ask the user to select vehicle from their vehicle list. Please do not include garage IDs in the message only include the vehicle's make, model, year, submodel (if availabe), and a count number.
- Ask the user what service they're looking for.
- Use the current user location:  
- Return `show_services: true` once user confirms.


#### 🧾 repair_guide
- Ask the user to select vehicle from their vehicle list. Please do not include garage IDs in the message only include the vehicle's make, model, year, submodel (if availabe), and a count number.
- Ask the user what service they're looking for.
- Based on selected vehicle, return repair instructions in the `repairGuide` field and set show_guide to true.
- Do not include repair guide in the message.
- Cost Estimate should be in \$.
- Be specific on submodel(if availe).
- Say here is the repair guide for (Selected vehicle) and (service)




#### 🗑 delete_vehicle
- Ask the user to select vehicle from their vehicle list. Please do not include garage IDs in the message only include the vehicle's make, model, year, submodel (if availabe), and a count number.
- Once confirmed, set intent and status accordingly.
- See that vehicle as delete.


---

Call the user by their name:
Respond in a conversational tone.
'''),
        model: 'gemini-2.0-flash',
      );
      _chatSession = generativeModel.startChat(
        generationConfig: GenerationConfig(
            responseMimeType: 'application/json', responseSchema: jsonSchema),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  bool isSending = false;
  changeIsLoading(bool value) {
    isSending = value;
    notifyListeners();
  }

  sendImageMessage(
      String mime,
      Uint8List bytes,
      GarageProvider garageProvider,
      File file,
      FirebaseStorageProvider firebaseStorageProvider,
      UserModel userModel,
      OffersProvider offersProvider) async {
    isSending = true;

    _addUserMessage('', file);
    scrollToBottom();

    notifyListeners();
    final mixPanelController = Get.find<MixPanelController>();

    Uint8List compressBytes =
        await FirebaseStorageProvider().compressFileandGetList(file);
    String? imageUrl = await firebaseStorageProvider.uploadMedia(file, false);
    // generativeModel.makeRequest(task, params, parse);
    final imagePart = InlineDataPart('image/jpeg', compressBytes);
    List userQueries = userModel.aiQuestions;
    userQueries.add({
      'question': imageUrl,
      'sentAt': DateTime.now().toUtc().toIso8601String(),
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.userId)
        .update({
      'aiQuestion': userQueries,
    });
    final prompt = TextPart(
        " ${userPrompt('also attatch this url as imageUrl $imageUrl', garageProvider, userModel, offersProvider)}");

    try {
      var response =
          await _chatSession!.sendMessage(Content.multi([prompt, imagePart]));

      var textResponse = response.text;
      final Map<String, dynamic> chatResponse = jsonDecode(textResponse ?? '');

      var guide = chatResponse['response'];
      logResponseFields(guide);
      mixPanelController.trackEvent(
          eventName: 'userImagePrompt ', data: {'prompt': 'Image upload'});

      mixPanelController.trackEvent(eventName: 'aiImageResponse ', data: guide);

      String garageId = guide['vehicleId'];

      if (guide['intent'] == 'add_image_to_vehicle' &&
          garageId.isNotEmpty &&
          guide['status'] == 'complete') {
        log('update vehicle image');

        garageProvider.updateGarageImage(
            userModel.userId, garageId, guide['imageUrl']);
      }

      _addBotMessage(guide['message'], guide['intent']);
    } catch (e) {
      isSending = false;

      print(e);
    } finally {
      scrollToBottom();

      isSending = false;
      notifyListeners();
    }
  }

  List<VehicleModel> subModels = [];

  Future<String?> _fetchVehicleData(String vin) async {
    final url =
        'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/$vin?format=json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> results = data['Results'];

        String make = results.firstWhere((e) => e['Variable'] == 'Make',
                orElse: () => null)?['Value'] ??
            'Unknown';
        String model = results.firstWhere((e) => e['Variable'] == 'Model',
                orElse: () => null)?['Value'] ??
            'Unknown';
        String year = results.firstWhere((e) => e['Variable'] == 'Model Year',
                orElse: () => null)?['Value'] ??
            'Unknown';

        String vehicleType = results.firstWhere(
                (e) => e['Variable'] == 'Vehicle Type',
                orElse: () => null)?['Value'] ??
            'Unknown';
        VehicleType? mappedType = mapVehicleType(vehicleType);
        // Fetch trims from Car API
        String carApiUrl =
            'https://carapi.app/api/trims?year=$year&make=$make&model=$model';
        String jwtToken = await getJwtToken(); // Replace with your token

        final carApiResponse = await http.get(Uri.parse(carApiUrl), headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        });

        String trims = 'No trims found';
        log(carApiResponse.body.toString());

        if (carApiResponse.statusCode == 200) {
          final carApiData = json.decode(carApiResponse.body);
          List<dynamic> trimsList = carApiData['data'] ?? [];
          if (trimsList.isNotEmpty) {
            trims = trimsList.first['description'];
          }
        } else {
          print('Failed to fetch trims: ${carApiResponse.statusCode}');
        }

        String vehicleInfo =
            'Make: $make\nModel: $model\nYear: $year\nVehicle Type: ${mappedType?.title ?? "Unknown"}\nTrims: $trims';
        return vehicleInfo;
      } else {
        // throw Exception('Failed to load vehicle data');
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
    return null;
  }

  sendVINMessage(
    String vin,
    String? userText,
    GarageProvider garageController,
    UserModel userModel,
    OffersProvider offersProvider,
  ) async {
    _addUserMessage('Scanned VIN: $vin', null);
    scrollToBottom();
    isSending = true;
    notifyListeners();
    _addBotMessage(
      'Decoding VIN....',
      'add_vehicle',
    );
    String decodedVINData = await _fetchVehicleData(vin) ?? '';

    if (decodedVINData == '') {
      isSending = false;
      _addBotMessage(
        'Unable to find your vehicle. Please check the VIN or try again later.',
        'unknown',
      );
      notifyListeners();
      return;
    }

    String prompt = userPrompt(
        'Here is the VIN detected vehicle details ask the user if something is missing: $decodedVINData',
        garageController,
        userModel,
        offersProvider);
    try {
      List userQueries = userModel.aiQuestions;
      userQueries.add({
        'question': decodedVINData,
        'sentAt': DateTime.now().toUtc().toIso8601String(),
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.userId)
          .update({
        'aiQuestion': userQueries,
      });

      GenerateContentResponse response =
          await _chatSession!.sendMessage(Content.text(prompt));

      var textResponse = response.text;

      final Map<String, dynamic> chatResponse = jsonDecode(textResponse ?? '');

      // Accessing the guide properties directly
      var guide = chatResponse['response'];
      logResponseFields(guide);
      String garageId = guide['vehicleId'];
      final mixPanelController = Get.find<MixPanelController>();
      mixPanelController.trackEvent(
          eventName: 'userPrompt ', data: {'prompt': decodedVINData});

      mixPanelController.trackEvent(eventName: 'aiResponse ', data: guide);
      final intent = guide['intent'];
      final status = guide['status'];
      final vehicleType = guide['vehicleType'];
      final vehicleModel = guide['vehicleModel'];
      final vehicleYear = guide['vehicleYear'];
      final vehicleMake = guide['vehicleMake'];
      final selectedSubmodel = guide['selected_submodel'] ?? '';

      final service = guide['service'] ?? '';
      final showServices = guide['show_services'] == true;
      final message = guide['message'];
      final offerId = guide['offerId'];
      final imageUrl = guide['imageUrl'];
      final repairGuide = guide['repairGuide'];
      final showGuide = guide['show_guide'] ?? false;

// Handle trim fetching
      final isAddVehicleIntent = intent == 'add_vehicle';
      final hasRequiredVehicleInfo = (vehicleModel?.isNotEmpty == true &&
              vehicleYear?.isNotEmpty == true &&
              vehicleMake?.isNotEmpty == true) &&
          (vehicleType == 'Passenger vehicles' ||
              vehicleType == 'Pickup Trucks');

      if (isAddVehicleIntent && hasRequiredVehicleInfo) {
        final jwtToken = await getJwtToken();
        subModels = await getTrims(
            vehicleMake, vehicleYear, vehicleType, vehicleModel, jwtToken);
        notifyListeners();
      }

// Add vehicle to garage
      if (isAddVehicleIntent && status == 'complete') {
        String garage = await garageController.addGarage(
          GarageModel(
            ownerId: userModel.userId,
            isCustomModel: selectedSubmodel.isEmpty,
            isCustomMake: selectedSubmodel.isEmpty,
            submodel: selectedSubmodel,
            title: '',
            imageUrl: imageUrl,
            bodyStyle: vehicleType,
            make: vehicleMake,
            year: vehicleYear,
            model: vehicleModel,
            vin: '',
            garageId: '',
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
          userModel.userId,
        );
        _addBotMessage(
          message,
          intent,
          showVehicle: true,
          garageId: garage,
        );
      } else

// Delete vehicle
      if (intent == 'delete_vehicle' &&
          status == 'complete' &&
          garageId.isNotEmpty &&
          garageId != 'string') {
        deleteVehicle(userModel, garageController, garageId);
        _addBotMessage(
          message,
          intent,
        );
      } else

// Create a service request
      if (intent == 'create_a_request' &&
          status == 'complete' &&
          garageId.isNotEmpty &&
          garageId != 'string' &&
          service.isNotEmpty &&
          service != 'unknown') {
        String requestId =
            await createRequest(garageId, '', service, userModel);
        _addBotMessage(
          message,
          intent,
          offerId: requestId,
        );
      } else

// Find nearby services
      if (intent == 'find_nearby_services' &&
          showServices &&
          service != 'unknown') {
        await getProviders(service, userModel);
        _addBotMessage(
          message,
          intent,
          showServices: true,
          offerId: offerId,
          garageId: garageId,
          service: service,
        );
      } else

// Repair guide
      if (intent == 'repair_guide' && repairGuide != null && showGuide) {
        _addBotMessage(
          message,
          intent,
          showServices: false,
          repairGuide: Map<String, dynamic>.from(repairGuide),
          showGuide: true,
        );
      } else {
        _addBotMessage(message, intent, showServices: false);
      }
      _aiChats.removeWhere((test) => test.response == 'Decoding VIN....');
    } catch (e) {
      log(e.toString());
      isSending = false;

      _addBotMessage(
          'ClientException with SocketException: Failed host lookup \'vehypeai.cloud\'.....',
          'unknown');
    } finally {
      scrollToBottom();

      isSending = false;
      notifyListeners();
    }
  }

  sendMessage(
      String text,
      GarageProvider garageController,
      UserModel userModel,
      FirebaseStorageProvider firebaseStorageProvider,
      OffersProvider offersProvider) async {
    _addUserMessage(text, null);
    scrollToBottom();

    String prompt =
        userPrompt(text, garageController, userModel, offersProvider);
    isSending = true;
    notifyListeners();

    try {
      List userQueries = userModel.aiQuestions;
      userQueries.add({
        'question': text,
        'sentAt': DateTime.now().toUtc().toIso8601String(),
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.userId)
          .update({
        'aiQuestion': userQueries,
      });

      GenerateContentResponse response =
          await _chatSession!.sendMessage(Content.text(prompt));

      var textResponse = response.text;

      final Map<String, dynamic> chatResponse = jsonDecode(textResponse ?? '');

      // Accessing the guide properties directly
      var guide = chatResponse['response'];
      logResponseFields(guide);
      String garageId = guide['vehicleId'];
      final mixPanelController = Get.find<MixPanelController>();
      mixPanelController
          .trackEvent(eventName: 'userPrompt ', data: {'prompt': text});

      mixPanelController.trackEvent(eventName: 'aiResponse ', data: guide);
      final intent = guide['intent'];
      final status = guide['status'];
      final vehicleType = guide['vehicleType'];
      final vehicleModel = guide['vehicleModel'];
      final vehicleYear = guide['vehicleYear'];
      final vehicleMake = guide['vehicleMake'];
      final selectedSubmodel = guide['selected_submodel'] ?? '';

      final service = guide['service'] ?? '';
      final showServices = guide['show_services'] == true;
      final message = guide['message'];
      final offerId = guide['offerId'];
      final imageUrl = guide['imageUrl'];
      final repairGuide = guide['repairGuide'];
      final showGuide = guide['show_guide'] ?? false;

// Handle trim fetching
      final isAddVehicleIntent = intent == 'add_vehicle';
      final hasRequiredVehicleInfo = (vehicleModel?.isNotEmpty == true &&
              vehicleYear?.isNotEmpty == true &&
              vehicleMake?.isNotEmpty == true) &&
          (vehicleType == 'Passenger vehicles' ||
              vehicleType == 'Pickup Trucks');

      if (isAddVehicleIntent && hasRequiredVehicleInfo) {
        final jwtToken = await getJwtToken();
        subModels = await getTrims(
            vehicleMake, vehicleYear, vehicleType, vehicleModel, jwtToken);
        notifyListeners();
      }

// Add vehicle to garage
      if (isAddVehicleIntent && status == 'complete') {
        String garage = await garageController.addGarage(
          GarageModel(
            ownerId: userModel.userId,
            isCustomModel: selectedSubmodel.isEmpty,
            isCustomMake: selectedSubmodel.isEmpty,
            submodel: selectedSubmodel,
            title: '',
            imageUrl: imageUrl,
            bodyStyle: vehicleType,
            make: vehicleMake,
            year: vehicleYear,
            model: vehicleModel,
            vin: '',
            garageId: '',
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
          userModel.userId,
        );
        _addBotMessage(
          message,
          intent,
          showVehicle: true,
          garageId: garage,
        );
      } else

// Delete vehicle
      if (intent == 'delete_vehicle' &&
          status == 'complete' &&
          garageId.isNotEmpty &&
          garageId != 'string') {
        deleteVehicle(userModel, garageController, garageId);
        _addBotMessage(
          message,
          intent,
        );
      } else

// Create a service request
      if (intent == 'create_a_request' &&
          status == 'complete' &&
          garageId.isNotEmpty &&
          garageId != 'string' &&
          service.isNotEmpty &&
          service != 'unknown') {
        String requestId =
            await createRequest(garageId, '', service, userModel);
        _addBotMessage(
          message,
          intent,
          offerId: requestId,
        );
      } else

// Find nearby services
      if (intent == 'find_nearby_services' &&
          showServices &&
          service != 'unknown') {
        await getProviders(service, userModel);
        _addBotMessage(
          message,
          intent,
          showServices: true,
          offerId: offerId,
          garageId: garageId,
          service: service,
        );
      } else

// Repair guide
      if (intent == 'repair_guide' && repairGuide != null && showGuide) {
        _addBotMessage(
          message,
          intent,
          showServices: false,
          repairGuide: Map<String, dynamic>.from(repairGuide),
          showGuide: true,
        );
      } else {
        _addBotMessage(message, intent, showServices: false);
      }
    } catch (e) {
      log(e.toString());
      isSending = false;

      _addBotMessage(
          'ClientException with SocketException: Failed host lookup \'vehypeai.cloud\'.....',
          'unknown');
    } finally {
      scrollToBottom();

      isSending = false;
      notifyListeners();
    }
  }

  Future<String> getAiImageUrl(String imageQuery) async {
    List<ImagenInlineImage> images =
        await GeneratePhotoProvider().generateImage(imageQuery);
    if (images.isNotEmpty) {
      ImagenInlineImage inlineImage = images[0];
      File file = await convertUint8ListToFile(
          inlineImage.bytesBase64Encoded, '$imageQuery.png');
      String? imageurl =
          await FirebaseStorageProvider().uploadMedia(file, false);
      return imageurl ?? '';
    }

    return '';
  }

  void logField(String key, dynamic value) {
    log('$key: ${value ?? 'null'}');
  }

  void logResponseFields(Map<String, dynamic> response) {
    log('\n================= Gemini Response =================');
    log(response.toString());

    // logField('intent', response['intent']);
    // logField('message', response['message']);

    // logField('status', response['status']);
    // logField('imageUrl', response['imageUrl']);
    // logField('vehicleId', response['vehicleId']);
    // logField('image_type', response['image_type']);
    // logField('vehicleType', response['vehicleType']);
    // logField('vehicleMake', response['vehicleMake']);
    // logField('vehicleModel', response['vehicleModel']);
    // logField('vehicleYear', response['vehicleYear']);
    // logField('vinNumber', response['vinNumber']);
    // logField('service', response['service']);
    // logField('request_description', response['request_description']);
    // logField('show_services', response['show_services']);
    // logField('offerId', response['offerId']);

    // if (response['repairGuide'] != null) {
    //   log('\n--- Repair Guide ---');
    //   final repair = response['repairGuide'] as Map<String, dynamic>;
    //   logField('toolsRequired', repair['toolsRequired']);
    //   logField('partsRequired', repair['partsRequired']);
    //   logField('timeEstimate', repair['timeEstimate']);
    //   logField('costEstimate', repair['costEstimate']);

    //   logField('sources', repair['sources']);
    //   logField('show_guide', repair['show_guide']);
    //   logField('steps', repair['steps']);
    // }

    log('==================================================\n');
  }

  Future<String> createRequest(
    String garageId,
    String description,
    String service,
    UserModel userModel,
  ) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('offers')
        .where('garageId', isEqualTo: garageId)
        .where('status', whereIn: ['active', 'inProgress'])

        // .where('issue',
        //     isEqualTo: garageController.selectedIssue)
        .get();
    List<OffersModel> offers = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> documentsnap
        in snapshot.docs) {
      offers.add(OffersModel.fromJson(documentsnap));
    }

    List<OffersModel> filterByVehicle =
        offers.where((offer) => offer.garageId == garageId).toList();
    List<OffersModel> filterByService =
        filterByVehicle.where((offer) => offer.issue == service).toList();
    bool anyDiffirence = filterByService.any((offer) => areLocationsDifferent(
          userModel.lat,
          userModel.long,
          offer.lat,
          offer.long,
          1,
        ));

    if (anyDiffirence) {
      _addBotMessage('Duplicate Request Found!', 'unknown');
      return '';
    } else {
      String _desc = description.trim() == 'string' ? '' : description.trim();
      String requestId = await GarageController().saveRequest(
          _desc,
          LatLng(userModel.lat, userModel.long),
          userModel.userId,
          null,
          garageId,
          service);

      getUserProviders(requestId, service, userModel);
      return requestId;
    }
  }

  List<UserModel> providers = [];

  Future<void> getProviders(String issue, UserModel userModel) async {
    // Clear previous list if needed
    providers.clear();

    try {
      // Fetch providers who offer the specific service (issue)
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('accountType', isEqualTo: 'provider')
          .where('services', arrayContains: issue)
          .get();

      // Map the snapshot data to UserModel list
      List<UserModel> fetchedProviders =
          snapshot.docs.map((doc) => UserModel.fromJson(doc)).toList();

      // Filter out blocked users
      List<UserModel> unblockedProviders = fetchedProviders
          .where(
              (provider) => !userModel.blockedUsers.contains(provider.userId))
          .toList();

      // Apply location-based filtering
      providers = UserController().filterProviders(
        unblockedProviders,
        userModel.lat,
        userModel.long,
        100,
      );

      notifyListeners();
    } catch (e) {
      log('Error fetching providers: $e');
    }
  }

  Future getUserProviders(
      String requestId, String issue, UserModel userModel) async {
    List<UserModel> providers = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('accountType', isEqualTo: 'provider')
        .where('services', arrayContains: issue)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      providers.add(UserModel.fromJson(element));
    }

    List<UserModel> blockedUsers = providers
        .where((element) => !userModel.blockedUsers.contains(element.userId))
        .toList();
    List<UserModel> filterProviders = UserController()
        .filterProviders(blockedUsers, userModel.lat, userModel.long, 100);

    // Check opening hours
    DateTime now = DateTime.now();
    String currentDay = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][now.weekday % 7]; // Ensure Sunday is at index 0

    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    List<String> userIds = [];
    List addNotifications = [];

    for (var provider in filterProviders) {
      userIds.add(provider.userId);
      // if (provider.workingHours != {} &&
      //     provider.workingHours.containsKey(currentDay)) {
      //   String hours = provider.workingHours[currentDay];

      //   if (hours == '24 Hours') {
      //     // Add directly if open 24/7
      //   } else {
      //     // Parse opening and closing times
      //     List<String> times = hours.split(' - ');
      //     TimeOfDay openingTime = _parseTime(times[0]);
      //     TimeOfDay closingTime = _parseTime(times[1]);

      //     // Check if current time is within the working hours
      //     if (_isWithinWorkingHours(currentTime, openingTime, closingTime)) {
      //       userIds.add(provider.userId);
      //     }
      //   }
      // }
    }

    // Send notifications only to providers who are currently open
    NotificationController().sendNotification(
        offerId: requestId,
        userIds: userIds,
        requestId: '',
        title: 'Opportunity Alert: New Request',
        subtitle:
            'A nearby vehicle owner has submitted a new request. Click here to see more and respond quickly.');

    for (String userId in userIds) {
      addNotifications.add({
        'checkById': userId,
        'isRead': false,
        'title': 'Opportunity Alert: New Request',
        'subtitle':
            'Opportunity Alert: New Request. Tap to see more and respond quickly.',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'senderId': userModel.userId,
      });
    }

    await FirebaseFirestore.instance
        .collection('offers')
        .doc(requestId)
        .update({
      'checkByList': addNotifications,
    });
  }

// Helper function to parse TimeOfDay from string
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);
    String period = parts[1].split(' ')[1].toLowerCase();

    if (period == 'pm' && hour != 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

// Helper function to check if current time is within working hours
  bool _isWithinWorkingHours(
      TimeOfDay current, TimeOfDay opening, TimeOfDay closing) {
    int currentMinutes = current.hour * 60 + current.minute;
    int openingMinutes = opening.hour * 60 + opening.minute;
    int closingMinutes = closing.hour * 60 + closing.minute;

    if (closingMinutes < openingMinutes) {
      // Handles overnight shifts (e.g., 10 PM - 6 AM)
      return currentMinutes >= openingMinutes ||
          currentMinutes <= closingMinutes;
    } else {
      return currentMinutes >= openingMinutes &&
          currentMinutes <= closingMinutes;
    }
  }

  deleteVehicle(UserModel userModel, GarageProvider garageProvider,
      String garageId) async {
    QuerySnapshot<Map<String, dynamic>> offersSnap = await FirebaseFirestore
        .instance
        .collection('offers')
        .where('garageId', isEqualTo: garageId)
        .where('status', whereIn: ['active', 'inProgress']).get();
    List<OffersModel> vehicleOffers = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> element
        in offersSnap.docs) {
      vehicleOffers.add(OffersModel.fromJson(element));
    }
    for (OffersModel offersModel in vehicleOffers) {
      if (offersModel.status == 'active') {
        QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
            await FirebaseFirestore.instance
                .collection('offersReceived')
                .where('offerId', isEqualTo: offersModel.offerId)
                .get();
        for (var element in offersReceivedSnap.docs) {
          await FirebaseFirestore.instance
              .collection('offersReceived')
              .doc(element.id)
              .update({
            'checkByList': [],
            'status': 'Rejected',
          });
        }
        await FirebaseFirestore.instance
            .collection('offers')
            .doc(offersModel.offerId)
            .update({
          'status': 'inactive',
          'offersReceived': [],
          'checkByList': [],
        });
      } else {
        QuerySnapshot<Map<String, dynamic>> offersReceivedSnap =
            await FirebaseFirestore.instance
                .collection('offersReceived')
                .where('offerId', isEqualTo: offersModel.offerId)
                .get();
        for (QueryDocumentSnapshot<Map<String, dynamic>> element
            in offersReceivedSnap.docs) {
          OffersReceivedModel offersReceivedModel =
              OffersReceivedModel.fromJson(element);
          OffersController().cancelOfferByOwner(
              offersReceivedModel, 'The request was automatically canceled.');
          DocumentSnapshot<Map<String, dynamic>> offerByQuery =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(offersReceivedModel.offerBy)
                  .get();
          NotificationController().sendNotification(
              userIds: [UserModel.fromJson(offerByQuery).userId],
              offerId: offersModel.offerId,
              requestId: offersReceivedModel.id,
              title: 'Offer Cancelled',
              subtitle:
                  '${userModel!.name} has cancelled the request. Click here to review.');
          QuerySnapshot<Map<String, dynamic>> chatsSnap =
              await FirebaseFirestore.instance
                  .collection('chats')
                  .where('offerId', isEqualTo: offersModel.offerId)
                  .get();

          for (var element in chatsSnap.docs) {
            await ChatController()
                .updateChatToClose(element.id, 'The request has been deleted.');
          }
          OffersController().updateNotificationForOffers(
              offerId: offersModel.offerId,
              userId: offersReceivedModel.offerBy,
              senderId: userModel!.userId,
              isAdd: true,
              offersReceived: offersReceivedModel.id,
              checkByList: offersModel.checkByList,
              notificationTitle: '${userModel.name} has cancelled the request.',
              notificationSubtitle:
                  '${userModel.name} has cancelled the request. Tap to review.');
        }
      }
    }

    await FirebaseFirestore.instance
        .collection('garages')
        .doc(garageId)
        .update({
      'ownerId': '',
      'deleteId': userModel.userId,
    });
    await garageProvider.fetchGarages(userModel.userId);
  }

  Future<File> convertUint8ListToFile(
      Uint8List uint8List, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(uint8List);
    return file;
  }
// Get Vehicle Types for Make by Name

  void _addUserMessage(String text, File? file) {
    _aiChats.add(AiChatModel(
      intent: '',
      showServices: false,
      response: text,
      isUser: true,
      showVehicle: false,
      showGuide: false,
      repairGuide: {},
      offerId: '',
      garageId: '',
      service: '',
      hasSuggestions: false,
      imageUrl: '',
      file: file,
    ));
    notifyListeners();
  }

  void _addBotMessage(String message, String intent,
      {String imageUrl = '',
      bool showServices = false,
      String offerId = '',
      String garageId = '',
      String service = '',
      bool showGuide = false,
      Map<String, dynamic> repairGuide = const {},
      bool showVehicle = false}) {
    _aiChats.add(AiChatModel(
      intent: intent,
      showServices: showServices,
      showGuide: showGuide,
      repairGuide: repairGuide,
      showVehicle: showVehicle,
      response: message,
      imageUrl: imageUrl,
      offerId: offerId,
      service: service,
      garageId: garageId,
      isUser: false,
      hasSuggestions: intent == 'unknown',
      file: null,
    ));
    notifyListeners();
  }

  String userPrompt(String text, GarageProvider garageProvider,
      UserModel userModel, OffersProvider offersProvider) {
    List<GarageModel> garages = garageProvider.garages
        .where((garage) => garage.ownerId.isNotEmpty)
        .toList();
    double lat = userModel.lat;
    double long = userModel.long;

    String garagesList = garages.map((garage) => garage.getString()).join('\n');
    String subModelsForSpecificMakeYearModelAndType =
        subModels.map((garage) => garage.getString()).join('\n');
    // List<OffersModel> activeOffers = offersProvider.ownerOffers
    //     .where((offer) => offer.status == 'active')
    //     .toList();

    // String openRequests =
    //     activeOffers.map((offer) => offer.getString()).join('\n');

    return '''

- SubModels: $subModelsForSpecificMakeYearModelAndType

- Current user's full name:

  ${userModel.name}

- Current user location:  
  Latitude: $lat  
  Longitude: $long  
---

### 🚗 SAVED VEHICLES:
$garagesList

---

### 💬 USER INPUT:
"$text"
''';
  }
}

Map<String, List<RegExp>> intentPatterns = {
  "park_vehicle": [
    // General phrases to add/park/store/save a vehicle
    RegExp(
        r"\b(add|park|store|save|register|record|set up|input|enter|log|keep|track)\b",
        caseSensitive: false),

    // Keywords related to vehicles, including alternative names
    RegExp(
        r"\b(car|vehicle|truck|motorcycle|bike|SUV|van|jeep|sedan|coupe|convertible|pickup|EV|electric car|hybrid|ride|automobile|motorbike|minivan|crossover|hatchback|wagon)\b",
        caseSensitive: false),

    // Variations that might include "my", "a", or "the" before the vehicle
    RegExp(
        r"\b(my|a|an|the|one)?\s*(car|vehicle|truck|motorcycle|bike|SUV|van|jeep|sedan|coupe|convertible|pickup|EV|electric car|hybrid|ride|automobile|motorbike|minivan|crossover|hatchback|wagon)\b",
        caseSensitive: false),

    // Specific makes and models (Example: "Honda Civic 2023")
    RegExp(r"\b([A-Z][a-z]+)\s+([A-Z]?[a-z0-9]+)\s*(\d{4})?\b",
        caseSensitive: false),

    // Queries specifying a new vehicle purchase
    RegExp(
        r"\b(just bought|purchased|got|added|acquired|picked up|brought home) (a|my) (new|used|pre-owned|certified pre-owned)?\s*(car|vehicle|truck|SUV|sedan|motorcycle|bike)\b",
        caseSensitive: false),

    // Queries where users want to add a car with missing details
    RegExp(
        r"\b(I want to|I need to|I'd like to|Can I|Help me) (add|park|store|save|register|record|set up|input|enter|log) (a|my) (car|vehicle|truck|SUV|sedan|bike|motorcycle|ride|automobile)\b",
        caseSensitive: false),

    // Casual phrasings and conversational language
    RegExp(
        r"\b(Put|Store|Keep|Save|Log) (my|a|the) (car|ride|vehicle|truck|bike|SUV|motorcycle|automobile) (in|inside|to|on) (my|the) (garage|account|profile|list|records|system)\b",
        caseSensitive: false),

    // "Adding" or "registering" a vehicle in a more casual way
    RegExp(
        r"\b(just got|recently got|finally got|picked up) (a|my) (car|truck|SUV|bike|motorcycle|ride)\b",
        caseSensitive: false),

    // Requests that indirectly imply adding a vehicle
    RegExp(
        r"\b(I have|I own|I drive|I got) (a|my) ([A-Z][a-z]+)\s+([A-Z]?[a-z0-9]+)\s*(\d{4})?\b",
        caseSensitive: false),
    RegExp(
        r"\b(Adding|Registering|Logging|Saving) my (car|truck|SUV|vehicle) details\b",
        caseSensitive: false),

    // Sentences where users refer to "their garage"
    RegExp(
        r"\b(Add|Park|Save|Log|Register) (my|a|the) (car|truck|vehicle|SUV|motorcycle) (to|in|inside) (my|the) garage\b",
        caseSensitive: false),

    // Requests that imply setting up a vehicle
    RegExp(
        r"\b(Set up|Configure|Prepare|Organize) my (car|truck|SUV|vehicle) in my profile\b",
        caseSensitive: false),
  ],
};
