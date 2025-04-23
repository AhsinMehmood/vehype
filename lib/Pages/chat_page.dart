// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/chat_widget.dart';
import 'package:vehype/providers/garage_provider.dart';

import '../const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String searchQuery = '';
  GarageModel? selectedVehicle;
  Service? selectedService;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final GarageProvider garageProvider = Provider.of<GarageProvider>(context);
    UserModel userModel = userController.userModel!;

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Chats',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: userModel.accountType == 'provider'
            ? null
            : [
                // Vehicle Icon Action with Red Dot
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.directions_car,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                      onPressed: () =>
                          _showVehicleDialog(garageProvider.garages),
                    ),
                    if (selectedVehicle != null)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                // Service Icon Action with Red Dot
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.build,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                      onPressed: () => _showServiceDialog(),
                    ),
                    if (selectedService != null)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: StreamBuilder<List<ChatModel>>(
                stream: ChatController().chatsStream(userModel.userId, context),
                builder: (context, AsyncSnapshot<List<ChatModel>> snap) {
                  if (snap.data == null || snap.data!.isEmpty) {
                    return Center(child: Text('No Chats!'));
                  }

                  List<ChatModel> chats = snap.data ?? [];
                  chats.sort(
                      (a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

                  // Apply filters
                  List<ChatModel> filteredChats = chats.where((chat) {
                    bool matchesSearch = searchQuery.isEmpty ||
                        chat.text
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());

                    bool matchesVehicle = selectedVehicle == null ||
                        selectedVehicle?.garageId == chat.garageId;
                    bool matchesService = selectedService == null ||
                        selectedService?.name == chat.serviceName;
                    return matchesSearch && matchesVehicle && matchesService;
                  }).toList();

                  return filteredChats.isEmpty
                      ? Center(child: Text('No Chats'))
                      : ListView.builder(
                          itemCount: filteredChats.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            ChatModel chat = filteredChats[index];
                            return ChatWidget(user: userModel, chat: chat);
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Chips Below AppBar for Selected Vehicle and Service**
  Widget _buildSearchAndFilters() {
    final UserController userController = Provider.of<UserController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // **Search Bar**
          TextField(
            decoration: InputDecoration(
              hintText: "Search chats...",
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          // const SizedBox(height: 4),

          // **Selected Filters as Chips**
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              if (selectedVehicle != null)
                Chip(
                  label: Text(
                    selectedVehicle!.title,
                    style: TextStyle(
                      color: primaryColor,
                    ),
                  ),
                  backgroundColor: Colors.green.shade100,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                    color: primaryColor,
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedVehicle = null;
                    });
                  },
                ),
              if (selectedService != null)
                Chip(
                  label: Text(
                    selectedService!.name,
                    style: TextStyle(
                      color: primaryColor,
                    ),
                  ),
                  backgroundColor: Colors.green.shade100,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                    color: primaryColor,
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedService = null;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// **Vehicle Selection Dialog**
  void _showVehicleDialog(List<GarageModel> garages) {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          insetPadding: EdgeInsets.zero, // Ensures no default padding
          child: Container(
            width: Get.width * 0.8,
            height: Get.height * 0.8,
            child: Column(children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Select Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: garages.map((garage) {
                      return ListTile(
                        isThreeLine: true,
                        title: Column(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: garage.imageUrl,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  width: Get.width,
                                  // width: 50,
                                )),
                            const SizedBox(width: 8),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(garage.title)),
                          ],
                        ),
                        subtitle: Text(garage.submodel),
                        onTap: () {
                          setState(() {
                            selectedVehicle = garage;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                      label: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showServiceDialog() {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          insetPadding: EdgeInsets.zero, // Ensures no default padding
          child: Container(
            width: Get.width * 0.8,
            height: Get.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Select Service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: getServices().map((service) {
                        return ListTile(
                          title: Row(
                            children: [
                              SvgPicture.asset(
                                service.image,
                                height: 40,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                width: 40,
                              ),
                              const SizedBox(width: 8),
                              Text(service.name),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedService = service;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.close,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                        label: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 16,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
