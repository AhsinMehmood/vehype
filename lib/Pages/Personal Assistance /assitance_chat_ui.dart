import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/ai_chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/In%20App%20Purchase%20/in_app_purchase_page.dart';

// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:vehype/Pages/owner_active_request_details.dart';

import 'package:vehype/const.dart';
import 'package:vehype/providers/firebase_storage_provider.dart';
import 'package:vehype/providers/garage_provider.dart';

import '../../Controllers/chat_controller.dart';
import '../../Controllers/garage_controller.dart';
import '../../Controllers/offers_provider.dart';
import '../../Models/chat_model.dart';
import '../../Widgets/choose_gallery_camera.dart';
import '../../Widgets/loading_dialog.dart';
import '../../providers/assistance_chat_provider.dart';
import '../Add Manage Vehicle/add_vehicle.dart';
import '../Add Manage Vehicle/scan_vin.dart';
import '../full_image_view_page.dart';
import '../message_page.dart';
import '../second_user_profile.dart';
import '../send_request_invite_page.dart'; // For Get SnackBar

class SiriWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  SiriWaveformPainter(
      {required this.amplitudes, this.color = Colors.blueAccent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    final centerY = size.height / 2;
    final widthStep = size.width / (amplitudes.length - 1);

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * widthStep;
      final y = centerY - (amplitudes[i] * centerY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.quadraticBezierTo(
          x - widthStep / 2,
          centerY,
          x,
          y,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SiriWaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes;
  }
}

class SiriWaveform extends StatelessWidget {
  final List<double> amplitudes;

  const SiriWaveform({super.key, required this.amplitudes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SiriWaveformPainter(amplitudes: amplitudes),
      size: const Size(double.infinity, 100),
    );
  }
}

///
///Every family has that one son that spends money faster than he makes it, flirts with death, and is obsessed with one beautiful girl.
///- I'm that son.
///
///
///
// 126 + 15.5 + 21 = 162.5 * 20 = 3250 * 280 = 910,000/-
class AssistanceChatUI extends StatefulWidget {
  const AssistanceChatUI({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AssistanceChatUIState createState() => _AssistanceChatUIState();
}

class _AssistanceChatUIState extends State<AssistanceChatUI> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeChat();
    _textController.addListener(() {
      setState(() {});
    });
  }

  initializeChat() {
    final AssistanceChatProvider chatProvider =
        Provider.of<AssistanceChatProvider>(context, listen: false);
    if (chatProvider.chatSession == null) {
      chatProvider.startChatSession();
    }
  }

  void _handleVINScan(
      AssistanceChatProvider chatProvider,
      GarageProvider garageProvider,
      UserModel userModel,
      firebaseStorageProvider,
      OffersProvider offersProvider) async {
    // log(chatProvider.uiIntentDataForVehicle.toString());

    final now = DateTime.now();
    final oneDayAgo = now.subtract(aiQuestionsDuration);
    List userQueries = userModel.aiQuestions;
    List aiAskedInPast7Days = userQueries
        .where((offer) => DateTime.parse(offer['sentAt']).isAfter(oneDayAgo))
        .toList();
    if (userModel.plan == 'free' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsFree) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }
    if (userModel.plan == 'pro' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsPro) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }

    // String? scannedVin = await Get.to(() => VinScannerPage(
    //       fromAi: true,
    //     ));
    final scannedVin = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => const ExtractVINFromImageAndCameraUsingAI(
                imageSource: ImageSource.camera,
              )),
    );

// await FlutterBarcodeScanner.scanBarcode(
//         '#FF2F53', 'Cancel', true, ScanMode.DEFAULT)
    if (scannedVin != null) {
      isVinValid = scannedVin.length == 17;
      setState(() {});
      if (isVinValid) {
        await chatProvider.sendVINMessage(
            scannedVin, null, garageProvider, userModel, offersProvider);
      }
    } else {
      //  setState(() {

      //   if (isVinValid) {
      //     vinController.text = scannedVin;
      //   } else {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('No VIN found in the barcode')),
      //     );
      //   }
      // });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('No VIN found in the barcode')),
      // );
    }
  }

  bool isVinValid = false;
  bool _isValidVin(String vin) {
    final vinRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$', caseSensitive: false);
    return vinRegex.hasMatch(vin);
  }

  void _handleSubmitted(
      String text,
      AssistanceChatProvider chatProvider,
      GarageProvider garageProvider,
      UserModel userModel,
      firebaseStorageProvider,
      OffersProvider offersProvider) async {
    // log(chatProvider.uiIntentDataForVehicle.toString());
    if (text.trim().isEmpty) {
      // Get.snackbar("Error", "Please enter a message.");
      return;
    }

    final vinRegex = RegExp(r'\b[A-HJ-NPR-Z0-9]{17}\b', caseSensitive: false);

    final vinMatch = vinRegex.firstMatch(text);

    final now = DateTime.now();
    final oneDayAgo = now.subtract(aiQuestionsDuration);
    List userQueries = userModel.aiQuestions;
    List aiAskedInPast7Days = userQueries
        .where((offer) => DateTime.parse(offer['sentAt']).isAfter(oneDayAgo))
        .toList();
    if (userModel.plan == 'free' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsFree) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }
    if (userModel.plan == 'pro' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsPro) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }
    // if (vinMatch != null) {
    //   final detectedVin = vinMatch.group(0);
    //   // Proceed to fetch vehicle data for VIN
    //   await chatProvider.sendVINMessage(
    //       detectedVin!, text.trim(), garageProvider, userModel, offersProvider);
    // } else {

    // }
    _textController.clear();
    await chatProvider.sendMessage(text.trim(), garageProvider, userModel,
        firebaseStorageProvider, offersProvider);
  }

  _handleImageMessage(
      AssistanceChatProvider chatProvider,
      GarageProvider garageProvider,
      UserModel userModel,
      firebaseStorageProvider,
      File file,
      Uint8List bytes,
      OffersProvider offersProvider) async {
    final now = DateTime.now();
    final oneDayAgo = now.subtract(aiQuestionsDuration);
    List userQueries = userModel.aiQuestions;
    List aiAskedInPast7Days = userQueries
        .where((offer) => DateTime.parse(offer['sentAt']).isAfter(oneDayAgo))
        .toList();
    if (userModel.plan == 'free' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsFree) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }
    if (userModel.plan == 'pro' &&
        aiAskedInPast7Days.isNotEmpty &&
        aiAskedInPast7Days.length >= maxQuestionsPro) {
      Get.to(() => SubscriptionPlansPage(
            title: "Select a Plan to\nAsk More Questions",
          ));
      return;
    }
    await chatProvider.sendImageMessage('', bytes, garageProvider, file,
        firebaseStorageProvider, userModel, offersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AssistanceChatProvider chatProvider =
        Provider.of<AssistanceChatProvider>(context);
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    final FirebaseStorageProvider firebaseStorageProvider =
        Provider.of<FirebaseStorageProvider>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    final UserController userController = Provider.of<UserController>(context);
    return WillPopScope(
      onWillPop: () async {
        // chatProvider.clearChats();

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'VEHYPE\'s AI Assistant',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                // chatProvider.clearChats();
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
              )),
        ),
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        body: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              // Container(
              //   height: 100,
              //   width: double.infinity,
              //   margin: const EdgeInsets.symmetric(horizontal: 16),
              //   child: SiriWaveform(amplitudes: chatProvider.soundWave),
              // ),
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: chatProvider.isListening
              //       ? chatProvider.stopListening
              //       : () {
              //           chatProvider.startListening(
              //               garageProvider,
              //               userController.userModel!,
              //               firebaseStorageProvider,
              //               offersProvider);
              //         },
              //   child: Text(chatProvider.isListening
              //       ? "Stop Listening"
              //       : "Start Listening"),
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.aiChats.length + 1,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    bottom: 120,
                  ),
                  controller: chatProvider.scrollController,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (index == chatProvider.aiChats.length) {
                      return _buildEmptyChatPage(
                          context,
                          chatProvider,
                          garageProvider,
                          userController.userModel!,
                          firebaseStorageProvider,
                          userController,
                          offersProvider);
                    } else {
                      AiChatModel aiChatModel = chatProvider.aiChats[index];
                      return ChatMessage(
                        aiChatModel: aiChatModel,
                        userController: userController,
                      );
                    }
                  },
                ),
              ),
              _buildDefaultChatInput(
                  chatProvider,
                  garageProvider,
                  userController.userModel!,
                  firebaseStorageProvider,
                  userController,
                  offersProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChatPage(
      BuildContext context,
      AssistanceChatProvider chatProvider,
      GarageProvider garageProvider,
      UserModel userModel,
      FirebaseStorageProvider firebaseStorageProvider,
      UserController userController,
      OffersProvider offersProvider) {
    return SizedBox(
      height: Get.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Welcome to VEHYPE's AI Assistant!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "How can I assist you today?",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color, // Adapt to theme
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionButton(context, "Park a vehicle 🚗"),
                  _buildSuggestionButton(context, "Delete a vehicle 🚗"),
                  _buildSuggestionButton(
                      context, "Create a service request 🔧"),
                  _buildSuggestionButton(context, "Find nearby services 🏪"),
                  _buildSuggestionButton(
                      context, "Add an image to my vehicle 📸"),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionButton(BuildContext context, String suggestion) {
    final AssistanceChatProvider chatProvider =
        Provider.of<AssistanceChatProvider>(context);
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    final FirebaseStorageProvider firebaseStorageProvider =
        Provider.of<FirebaseStorageProvider>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    final UserController userController = Provider.of<UserController>(context);
    return ElevatedButton(
      onPressed: () {
        // Handle suggestion click here
        // For instance, send the suggestion to the chatProvider
        // chatProvider.sendMessage(suggestion);
        _handleSubmitted(suggestion, chatProvider, garageProvider,
            userController.userModel!, firebaseStorageProvider, offersProvider);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor, // Adapt to theme
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Text(suggestion),
    );
  }

  Widget _buildDefaultChatInput(
      AssistanceChatProvider chatProvider,
      GarageProvider garageProvider,
      UserModel userModel,
      firebaseStorageProvider,
      UserController userController,
      OffersProvider offersProvider) {
    // final TextEditingController _textController = TextEditingController();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 22.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // if (_isLoading)
          //   LinearProgressIndicator(
          //     color: userController.isDark ? Colors.white : primaryColor,
          //   ),
          const Divider(height: 1.0),
          Row(
            children: [
              if (_textController.text.isEmpty)
                IconButton(
                  icon: Icon(Icons.photo_outlined,
                      color:
                          userController.isDark ? Colors.white : primaryColor),
                  onPressed: chatProvider.isSending
                      ? null
                      : () async {
                          Get.bottomSheet(ChooseGalleryCamera(onTapVINScan: () {
                            Get.close(1);

                            _handleVINScan(
                                chatProvider,
                                garageProvider,
                                userModel,
                                firebaseStorageProvider,
                                offersProvider);
                          }, onTapCamera: () async {
                            // Get.close(1);
                            Get.close(1);
                            XFile? xFile = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (xFile != null) {
                              Uint8List bytes = await xFile.readAsBytes();
                              File file = File(xFile.path);
                              _handleImageMessage(
                                  chatProvider,
                                  garageProvider,
                                  userModel,
                                  firebaseStorageProvider,
                                  file,
                                  bytes,
                                  offersProvider);
                            }
                          }, onTapGallery: () async {
                            Get.close(1);
                            XFile? xFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (xFile != null) {
                              Uint8List bytes = await xFile.readAsBytes();
                              File file = File(xFile.path);
                              _handleImageMessage(
                                  chatProvider,
                                  garageProvider,
                                  userModel,
                                  firebaseStorageProvider,
                                  file,
                                  bytes,
                                  offersProvider);
                            }
                          }));
                        },
                ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onTapOutside: (s) {
                    FocusScope.of(context).unfocus();
                  },
                  maxLines: null,
                  maxLength: 200,
                  onSubmitted: chatProvider.isSending
                      ? null
                      : (String text) {
                          _handleSubmitted(
                              text,
                              chatProvider,
                              garageProvider,
                              userModel,
                              firebaseStorageProvider,
                              offersProvider);
                        },
                  decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: InputBorder.none,
                      counter: const SizedBox.shrink()),
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
              ),
              if (chatProvider.isSending)
                Container(
                    height: 24,
                    width: 24,
                    margin: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    ))
              else if (_textController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.send,
                      color:
                          userController.isDark ? Colors.white : primaryColor),
                  onPressed: chatProvider.isSending
                      ? null
                      : () => _handleSubmitted(
                          _textController.text,
                          chatProvider,
                          garageProvider,
                          userModel,
                          firebaseStorageProvider,
                          offersProvider),
                )
              else if (chatProvider.isConverting)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    chatProvider.isListening ? Icons.mic : Icons.mic_none,
                    color: chatProvider.isListening
                        ? Colors.redAccent
                        : (userController.isDark ? Colors.white : primaryColor),
                  ),
                  onPressed: chatProvider.isSending
                      ? null
                      : () async {
                          if (chatProvider.isListening) {
                            chatProvider.stopListening();
                          } else {
                            String? recognized =
                                await chatProvider.startListening(
                              garageProvider,
                              userModel,
                              firebaseStorageProvider,
                              offersProvider,
                            );
                            print(recognized);
                            if (recognized != null) {
                              _textController.text = recognized;
                              setState(() {});
                            }
                          }
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.aiChatModel,
    required this.userController,
  });
  final AiChatModel aiChatModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: aiChatModel.isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!aiChatModel.isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: Image.asset(
                'assets/icon.png',
                height: 25,
                width: 25,
                fit: BoxFit.cover,
              ),
            ),
          ),
        aiChatModel.file != null
            ? Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    aiChatModel.file!,
                    height: 200,
                    width: Get.width * 0.7,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: aiChatModel.isUser
                        ? Colors.blueAccent
                        : userController.isDark
                            ? Colors.white
                            : primaryColor,
                    borderRadius: aiChatModel.isUser
                        ? BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          )
                        : BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          )),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // minWidth: 40, // Minimum height when empty
                    maxWidth:
                        Get.width * 0.75, // Maximum height to prevent overflow
                  ),
                  child: Text(
                    aiChatModel.response,
                    style: TextStyle(
                      color: aiChatModel.isUser
                          ? Colors.white
                          : userController.isDark
                              ? primaryColor
                              : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
        if (aiChatModel.isUser)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: CachedNetworkImage(
                imageUrl: userController.userModel!.profileUrl,
                height: 20,
                width: 20,
              ),
            ),
          ),
        if (aiChatModel.hasSuggestions)
          _buildSuggestionButtons(context)
        else if (aiChatModel.garageId != 'string' &&
            aiChatModel.garageId.isNotEmpty &&
            aiChatModel.showServices)
          _buildServicesButtons(
              context, aiChatModel.service, aiChatModel.garageId)
        else if (aiChatModel.showGuide && aiChatModel.repairGuide.isNotEmpty)
          Column(
            children: [
              ExpansionTile(
                title: Text('Repair Guide',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color:
                          userController.isDark ? Colors.white : Colors.black,
                    )),
                children: [
                  buildSection('Tools Required',
                      aiChatModel.repairGuide['toolsRequired'], Icons.build),
                  buildSection(
                      'Parts Required',
                      aiChatModel.repairGuide['partsRequired'],
                      Icons.lightbulb),
                  buildSection('Step-by-Step Guide',
                      aiChatModel.repairGuide['steps'], Icons.directions_car),
                  buildSection('Time Estimate',
                      aiChatModel.repairGuide['timeEstimate'], Icons.timer),
                  buildSection(
                      'Cost Breakdown',
                      aiChatModel.repairGuide['costEstimate'],
                      Icons.attach_money),
                  buildSection('Sources', aiChatModel.repairGuide['sources'],
                      Icons.info_outline),
                ],
              )
            ],
          )
        else if (aiChatModel.showVehicle)
          buildVehicleCard(aiChatModel, context)
        else if (aiChatModel.offerId.isNotEmpty)
          buildRequestWidget(aiChatModel, context)
      ],
    );
  }

  Widget buildRequestWidget(AiChatModel aiChatModel, BuildContext context) {
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    UserModel userModel = userController.userModel!;
    List<OffersModel> offersPosted = offersProvider.ownerOffers
        .where((offer) => offer.status == 'active')
        .toList();
    OffersModel? offersModel = offersPosted
        .firstWhereOrNull((test) => test.offerId == aiChatModel.offerId);
    GarageModel? garageModel = garageProvider.garages.firstWhereOrNull(
        (garage) => garage.garageId == '${offersModel?.garageId}');

    return offersModel == null
        ? const SizedBox.shrink()
        : InkWell(
            onTap: () async {
              // final GarageController garageController =
              //     Provider.of<GarageController>(context, listen: false);
              // Get.dialog(LoadingDialog(), barrierDismissible: false);
              // await garageController.initVehicle(garageModel);
              // Get.close(1);
              Get.to(() => OwnerActiveRequestDetails(offersModel: offersModel));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // minWidth: 40, // Minimum height when empty
                  maxWidth:
                      Get.width * 0.85, // Maximum height to prevent overflow
                ),
                child: Card(
                  color: userController.isDark ? Colors.blueGrey : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: garageModel!.imageUrl,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                garageModel.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    getServices()
                                        .firstWhere((test) =>
                                            test.name == offersModel.issue)
                                        .image,
                                    height: 25,
                                    width: 25,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    offersModel.issue,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                              // const SizedBox(
                              //   height: 10,
                              // ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward_ios_outlined),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget buildVehicleCard(AiChatModel aiChatModel, BuildContext context) {
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);

    GarageModel? garageModel = garageProvider.garages
        .firstWhereOrNull((garage) => garage.garageId == aiChatModel.garageId);
    return garageModel == null
        ? const SizedBox.shrink()
        : InkWell(
            onTap: () async {
              final GarageController garageController =
                  Provider.of<GarageController>(context, listen: false);
              Get.dialog(LoadingDialog(), barrierDismissible: false);
              await garageController.initVehicle(garageModel);
              Get.close(1);
              Get.to(() => AddVehicle(garageModel: garageModel));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.85,
                ),
                child: Card(
                  color: userController.isDark ? Colors.blueGrey : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: garageModel.imageUrl,
                              errorWidget: (context, url, error) {
                                return Container();
                              },
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: Get.width * 0.85 - 120),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        garageModel.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                garageModel.bodyStyle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward_ios_outlined),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

// 1. Update buildSection to handle different data types
  Widget buildSection(String title, dynamic content, IconData icon) {
    if (content == null) return Container();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      color: userController.isDark ? primaryColor : Colors.white,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blueAccent),
        // initiallyExpanded: true,
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: userController.isDark ? Colors.white : Colors.black,
            )),
        children: _buildContentChildren(content, title),
      ),
    );
  }

// 2. Create content handler method
  List<Widget> _buildContentChildren(dynamic content, String title) {
    if (title == 'Step-by-Step Guide') {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              buildRepairSteps(content is List ? content.join('\n') : content),
        )
      ];
    }

    if (content is Map) {
      return content.entries
          .map((entry) => ListTile(
                leading:
                    const Icon(Icons.label_important, color: Colors.orange),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: entry.value.toString()),
                    ],
                  ),
                ),
              ))
          .toList();
    }

    if (content is List) {
      return content
          .map((item) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(item.toString()),
              ))
          .toList();
    }

    return [
      ListTile(
        leading: const Icon(Icons.info, color: Colors.blue),
        title: Text(content.toString()),
      )
    ];
  }

  Widget buildRepairSteps(String steps) {
    // Split lines to process each step
    List<String> lines = steps.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Detect titles wrapped in **
        if (line.contains('**')) {
          // Extract bold parts
          final regExp = RegExp(r'\*\*(.*?)\*\*');
          final matches = regExp.allMatches(line);
          List<TextSpan> spans = [];

          int lastMatchEnd = 0;
          for (var match in matches) {
            // Add regular text before match
            if (match.start > lastMatchEnd) {
              spans.add(TextSpan(
                text: line.substring(lastMatchEnd, match.start),
                // style: const TextStyle(color: Colors.black),
              ));
            }
            // Add bold text
            spans.add(TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
            lastMatchEnd = match.end;
          }
          // Add remaining text after last match
          if (lastMatchEnd < line.length) {
            spans.add(TextSpan(
              text: line.substring(lastMatchEnd),
              style: const TextStyle(),
            ));
          }

          return RichText(
            text: TextSpan(
              children: spans,
              style: const TextStyle(fontSize: 16),
            ),
          );
        } else {
          // Regular text line
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildServicesButtons(
      BuildContext context, String issue, String garageId) {
    final AssistanceChatProvider chatProvider =
        Provider.of<AssistanceChatProvider>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    OffersModel? offersModel = offersProvider.ownerOffers.firstWhereOrNull(
        (offer) =>
            offer.status == 'active' &&
            offer.issue == issue &&
            offer.garageId == garageId);

    GarageModel? garageModel = garageProvider.garages
        .firstWhereOrNull((garage) => garage.garageId == garageId);

    return Wrap(
      spacing: 0.0,
      children: chatProvider.providers.map((provider) {
        return ProviderWidget(
          profile: provider,
          garageModel: garageModel,
          offersModel: offersModel,
        );
      }).toList(),
    );
  }

  Widget _buildSuggestionButtons(BuildContext context) {
    final AssistanceChatProvider chatProvider =
        Provider.of<AssistanceChatProvider>(context);
    final UserController userController = Provider.of<UserController>(context);
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    final FirebaseStorageProvider firebaseStorageProvider =
        Provider.of<FirebaseStorageProvider>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    final List<String> suggestions = [
      "Park a vehicle 🚗",
      "Delete a vehicle 🚗",
      "Create a service request 🔧",
      "Find nearby services 🏪",
      "Add an image to my vehicle 📸",
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: suggestions.map((suggestion) {
          return ElevatedButton(
            onPressed: () {
              // Access the parent widget's state to handle the suggestion click
              // chatProvider.makeRequestToVertex(suggestion);
              chatProvider.sendMessage(
                  suggestion,
                  garageProvider,
                  userController.userModel!,
                  firebaseStorageProvider,
                  offersProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: Text(suggestion),
          );
        }).toList(),
      ),
    );
  }
}

class ProviderWidget extends StatefulWidget {
  final UserModel profile;
  final OffersModel? offersModel;
  final GarageModel? garageModel;
  const ProviderWidget(
      {super.key,
      required this.profile,
      required this.offersModel,
      required this.garageModel});

  @override
  State<ProviderWidget> createState() => _ProviderWidget();
}

class _ProviderWidget extends State<ProviderWidget> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: InkWell(
        onTap: () {
          Get.to(() => SecondUserProfile(userId: widget.profile.userId));
        },
        child: Container(
          width: Get.width * 0.85,
          decoration: BoxDecoration(
              color: userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: userController.isDark
                    ? Colors.white.withOpacity(0.1)
                    : primaryColor.withOpacity(0.1),
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            Get.to(() => FullImagePageView(
                                urls: [widget.profile.profileUrl]));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: CachedNetworkImage(
                              placeholder: (context, url) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorWidget: (context, url, error) =>
                                  const SizedBox.shrink(),
                              imageUrl: widget.profile.profileUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.fill,

                              //cancelToken: cancellationToken,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profile.name,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: widget.profile.rating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 18.0,
                                  direction: Axis.horizontal,
                                ),
                                // const SizedBox(
                                //   width: 8,
                                // ),
                                // Text(
                                //   '(${widget.profile.ratings.length.toString()})',
                                //   style: TextStyle(
                                //     color: userController.isDark
                                //         ? Colors.white
                                //         : primaryColor,
                                //     fontSize: 13,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              ' (${widget.profile.ratings.length} Happy Customers)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (widget.offersModel != null &&
                                widget.garageModel != null) {
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              ChatModel? chatModel = await ChatController()
                                  .getChat(
                                      userModel.userId,
                                      widget.profile.userId,
                                      widget.offersModel!.offerId);
                              if (chatModel == null) {
                                await ChatController().createChat(
                                    userModel,
                                    widget.profile,
                                    '',
                                    widget.offersModel!,
                                    'New Message',
                                    '${userModel.name} sent an inquiry for ${widget.offersModel!.vehicleId}',
                                    'Message',
                                    widget.garageModel!);
                                ChatModel? newchat = await ChatController()
                                    .getChat(
                                        userModel.userId,
                                        widget.profile.userId,
                                        widget.offersModel!.offerId);
                                Get.close(1);
                                Get.to(() => MessagePage(
                                      offersModel: widget.offersModel!,
                                      garageModel: widget.garageModel!,
                                      chatModel: newchat!,
                                      secondUser: widget.profile,
                                    ));
                              } else {
                                Get.close(1);

                                Get.to(() => MessagePage(
                                      offersModel: widget.offersModel!,
                                      garageModel: widget.garageModel!,
                                      chatModel: chatModel,
                                      secondUser: widget.profile,
                                    ));
                              }
                            } else {
                              Get.to(() => SendRequestInvitePage(
                                  profileModel: widget.profile));
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/messages.svg',
                                    height: 20,
                                    width: 20,
                                    // ignore: deprecated_member_use
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
