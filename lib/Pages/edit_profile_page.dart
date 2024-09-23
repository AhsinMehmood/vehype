// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Pages/splash_page.dart';
import 'package:vehype/Widgets/choose_gallery_camera.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/garage_controller.dart';
import '../Controllers/offers_provider.dart';
import '../Controllers/vehicle_data.dart';
import '../google_maps_place_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  double lat = 0.0;
  double long = 0.0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    lat = userController.userModel!.lat;
    long = userController.userModel!.long;
    UserModel userModel = userController.userModel!;
    return DefaultTabController(
      length: userModel.accountType == 'provider' ? 4 : 2,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          title: Text(
            'Manage Profile',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          centerTitle: true,
          elevation: 0.0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            tabAlignment: userModel.accountType == 'provider'
                ? TabAlignment.start
                : TabAlignment.center,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: userModel.accountType == 'provider'
                ? [
                    Tab(
                      child: Text('Edit Profile'),
                    ),
                    Tab(
                      child: Text('My Services'),
                    ),
                    Tab(
                      child: Text('My Gallery'),
                    ),
                    Tab(
                      child: Text('Reviews'),
                    ),
                  ]
                : [
                    Tab(
                      child: Text('Edit Profile'),
                    ),
                    Tab(
                      child: Text('Reviews'),
                    ),
                  ],
          ),
        ),
        body: TabBarView(
            children: userModel.accountType == 'provider'
                ? [
                    EditProfileTab(),
                    ServicesTab(),
                    Scaffold(
                      backgroundColor:
                          userController.isDark ? primaryColor : Colors.white,
                      floatingActionButton: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                            onPressed: () {
                              final ImagePicker picker = ImagePicker();

                              Get.bottomSheet(
                                ChooseGalleryCamera(
                                  onTapCamera: () async {
                                    final XFile? image = await picker.pickImage(
                                        source: ImageSource.camera);
                                    if (image != null) {
                                      Get.dialog(LoadingDialog(),
                                          useSafeArea: false,
                                          barrierDismissible: false);
                                      String imageUrl =
                                          await userController.uploadImage(
                                              File(image.path),
                                              userModel.userId);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userModel.userId)
                                          .update({
                                        'gallery':
                                            FieldValue.arrayUnion([imageUrl])
                                      });
                                      Get.close(2);
                                    }
                                  },
                                  onTapGallery: () async {
                                    List<Asset> pickImages =
                                        await MultiImagePicker.pickImages(
                                            androidOptions: AndroidOptions(
                                              maxImages: 3,
                                            ),
                                            iosOptions: IOSOptions(
                                                settings: CupertinoSettings(
                                                    selection: SelectionSetting(
                                              max: 3,
                                            ))));

                                    // images.first.getByteData();
                                    // final List<XFile> images = await picker.pickMultiImage();
                                    List<File> images = [];
                                    Get.dialog(LoadingDialog(),
                                        useSafeArea: false,
                                        barrierDismissible: false);
                                    for (Asset asset in pickImages) {
                                      ByteData getFile =
                                          await asset.getByteData();
                                      File file = await GarageController()
                                          .writeToFile(getFile, asset.name);

                                      images.add(file);
                                    }
                                    for (var element in images) {
                                      String imageUrl =
                                          await userController.uploadImage(
                                              element, userModel.userId);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userModel.userId)
                                          .update({
                                        'gallery':
                                            FieldValue.arrayUnion([imageUrl])
                                      });
                                    }
                                    Get.close(2);
                                  },
                                ),
                                backgroundColor: userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            )),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: PhotosTab(profile: userModel),
                      ),
                    ),
                    ReviewsTab(userData: userModel),
                  ]
                : [
                    EditProfileTab(),
                    ReviewsTab(userData: userModel),
                  ]),
      ),
    );
  }
}

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {},
              child: Text(
                'Additional Services',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          for (AdditionalServiceModel service in getAdditionalService())
            InkWell(
              onTap: () {
                if (userController.userModel!.additionalServices
                    .contains(service.name)) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userController.userModel!.userId)
                      .update({
                    'additionalServices':
                        FieldValue.arrayRemove([service.name]),
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userController.userModel!.userId)
                      .update({
                    'additionalServices': FieldValue.arrayUnion([service.name]),
                  });
                }
                // garageController.selectAdditionalService(service.name);
                // Get.close(1);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                          activeColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          checkColor: userController.isDark
                              ? Colors.green
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          value: userController.userModel!.additionalServices
                              .contains(service.name),
                          onChanged: (s) {
                            if (userController.userModel!.additionalServices
                                .contains(service.name)) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userController.userModel!.userId)
                                  .update({
                                'additionalServices':
                                    FieldValue.arrayRemove([service.name]),
                              });
                            } else {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userController.userModel!.userId)
                                  .update({
                                'additionalServices':
                                    FieldValue.arrayUnion([service.name]),
                              });
                            }
                            // appProvider.selectPrefs(pref);
                            // garageController
                            //     .selectAdditionalService(service.name);
                            // Get.close(1);
                          }),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    SvgPicture.asset(
                        getAdditionalService()
                            .firstWhere(
                                (element) => element.name == service.name)
                            .icon,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        color: userController.isDark
                            ? Colors.white
                            : primaryColor),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      service.name,
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                final List<Service> services = getServices();
                List servicesToUpdate = [];
                for (var element in services) {
                  servicesToUpdate.add(element.name);
                }
                if (userController.userModel!.services.length ==
                    getServices().length) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userController.userModel!.userId)
                      .update({
                    'services': [],
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userController.userModel!.userId)
                      .update({
                    'services': servicesToUpdate,
                  });
                }
              },
              child: Text(
                userController.userModel!.services.length ==
                        getServices().length
                    ? 'Clear'
                    : 'Select All',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: getServices().length,
                itemBuilder: (context, index) {
                  final Service service = getServices()[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // userController.selectServices(service.name);
                          if (userController.userModel!.services
                              .contains(service.name)) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userController.userModel!.userId)
                                .update({
                              'services': FieldValue.arrayRemove([service.name])
                            });
                          } else {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userController.userModel!.userId)
                                .update({
                              'services': FieldValue.arrayUnion([service.name])
                            });
                          }

                          // appProvider.selectPrefs(pref);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                  activeColor: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  checkColor: userController.isDark
                                      ? Colors.green
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  value: userController.userModel!.services
                                      .contains(service.name),
                                  onChanged: (s) {
                                    // appProvider.selectPrefs(pref);
                                    if (userController.userModel!.services
                                        .contains(service.name)) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userController.userModel!.userId)
                                          .update({
                                        'services': FieldValue.arrayRemove(
                                            [service.name])
                                      });
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userController.userModel!.userId)
                                          .update({
                                        'services': FieldValue.arrayUnion(
                                            [service.name])
                                      });
                                    }
                                  }),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            SvgPicture.asset(service.image,
                                height: 40,
                                width: 40,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              service.name,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class EditProfileTab extends StatefulWidget {
  const EditProfileTab({super.key});

  @override
  State<EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<EditProfileTab> {
  double lat = 0.0;
  double long = 0.0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    lat = userController.userModel!.lat;
    long = userController.userModel!.long;
    UserModel userModel = userController.userModel!;
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  UserController().selectAndUploadImage(
                      context, userController.userModel!, 0);
                },
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: ExtendedImage.network(
                          userController.userModel!.profileUrl,
                          width: 125,
                          height: 125,
                          fit: BoxFit.fill,
                          cache: true,
                          // border: Border.all(color: Colors.red, width: 1.0),
                          shape: BoxShape.circle,
                          borderRadius:
                              BorderRadius.all(Radius.circular(200.0)),
                          //cancelToken: cancellationToken,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          padding: const EdgeInsets.all(2),
                          height: 24,
                          width: 24,
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      // color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    // controller: _vinController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'John Doe',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        )
                        // counter: const SizedBox.shrink(),
                        ),
                    initialValue: userController.userModel!.name,
                    onChanged: (String value) => userController.updateTexts(
                        userController.userModel!, 'name', value),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      // color: changeColor(color: '7B7B7B'),
                      fontSize: 16,
                    ),
                    // maxLength: 25,
                    // onChanged: (String value) => editProfileProvider
                    //     .updateTexts(userModel, 'name', value),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 1,
                width: Get.width,
                color: changeColor(color: 'D9D9D9'),
              ),
              const SizedBox(
                height: 15,
              ),
              if (userController.userModel!.accountType == 'provider')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Info',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      // controller: _vinController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Add your business details',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          )
                          // counter: const SizedBox.shrink(),
                          ),
                      initialValue: userController.userModel!.businessInfo,
                      onChanged: (String value) => userController.updateTexts(
                          userController.userModel!, 'businessInfo', value),
                      // textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
              if (userController.userModel!.accountType == 'provider')
                const SizedBox(
                  height: 5,
                ),
              if (userController.userModel!.accountType == 'provider')
                Container(
                  height: 1,
                  width: Get.width,
                  color: changeColor(color: 'D9D9D9'),
                ),
              if (userController.userModel!.accountType == 'provider')
                const SizedBox(
                  height: 15,
                ),
              if (userController.userModel!.accountType == 'provider')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Info',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      // controller: _vinController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        focusedBorder: InputBorder.none,
                        hintText: 'Enter your contact info',
                        // counter: const SizedBox.shrink(),
                      ),
                      initialValue: userController.userModel!.contactInfo,
                      onChanged: (String value) => userController.updateTexts(
                          userController.userModel!, 'contactInfo', value),
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
              if (userController.userModel!.accountType == 'provider')
                const SizedBox(
                  height: 5,
                ),
              if (userController.userModel!.accountType == 'provider')
                Container(
                  height: 1,
                  width: Get.width,
                  color: changeColor(color: 'D9D9D9'),
                ),
              if (userController.userModel!.accountType == 'provider')
                const SizedBox(
                  height: 15,
                ),
              if (userController.userModel!.accountType == 'provider')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Website',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      // controller: _vinController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'https://yourbusiness.com/',
                        hintStyle: TextStyle(
                          // color: userController.isDark? Colors.white
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        ),
                        // counter: const SizedBox.shrink(),
                      ),
                      initialValue: userController.userModel!.website,
                      onChanged: (String value) => userController.updateTexts(
                          userController.userModel!, 'website', value),
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
              if (userController.userModel!.accountType == 'provider')
                const SizedBox(
                  height: 5,
                ),
              if (userController.userModel!.accountType == 'provider')
                Container(
                  height: 1,
                  width: Get.width,
                  color: changeColor(color: 'D9D9D9'),
                ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Account Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(200),
                      onTap: () async {
                        UserModel userModel = userController.userModel!;
                        Get.dialog(const LoadingDialog(),
                            barrierDismissible: false);
                        // User user = FirebaseAuth.instance.currentUser;
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        String realUserId =
                            sharedPreferences.getString('userId') ?? '';
                        OffersProvider offersProvider =
                            Provider.of<OffersProvider>(context, listen: false);
                        offersProvider.stopListening();
                        OneSignal.logout();
                        userController.changeTabIndex(0);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(realUserId)
                            .update({
                          'accountType': 'provider',
                        });
                        userController.closeStream();

                        Get.close(1);
                        Get.offAll(() => SplashPage());
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                          ),
                          width: Get.width * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  // color: Colors.green,
                                ),
                              ),
                              Text(
                                'I\'m Service Owner',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color:
                                      userController.userModel!.accountType ==
                                              'provider'
                                          ? Colors.green
                                          : Colors.transparent,
                                ),
                                child: Icon(
                                  Icons.done,
                                  color:
                                      userController.userModel!.accountType ==
                                              'provider'
                                          ? Colors.white
                                          : Colors.transparent,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(200),
                      onTap: () async {
                        Get.dialog(const LoadingDialog(),
                            barrierDismissible: false);
                        // User user = FirebaseAuth.instance.currentUser;
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        String realUserId =
                            sharedPreferences.getString('userId') ?? '';
                        UserModel userModel = userController.userModel!;
                        OneSignal.logout();
                        OffersProvider offersProvider =
                            Provider.of<OffersProvider>(context, listen: false);
                        offersProvider.stopListening();
                        // offersProvider.stopListening();
                        // offersProvider.stopListening();

                        userController.changeTabIndex(0);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(realUserId)
                            .update({
                          'accountType': 'seeker',
                        });
                        userController.closeStream();
                        // userController.getUserStream(userId)/
                        Get.close(1);
                        Get.offAll(() => SplashPage());
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 0,
                            right: 0,
                          ),
                          width: Get.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Color.fromARGB(255, 3, 0, 10),
                              border: Border.all(
                                color: Color.fromARGB(255, 3, 0, 10),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  // color: Colors.green,
                                ),
                              ),
                              Text(
                                'I\'m Vehicle Owner',
                                style: TextStyle(
                                  // fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color:
                                      userController.userModel!.accountType ==
                                              'seeker'
                                          ? Colors.green
                                          : Colors.transparent,
                                ),
                                child: Icon(
                                  Icons.done,
                                  color:
                                      userController.userModel!.accountType ==
                                              'seeker'
                                          ? Colors.white
                                          : Colors.transparent,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      child: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 200,
                              width: Get.width,
                              child: userController.userModel!.lat == 0.0
                                  ? CupertinoActivityIndicator()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: GoogleMap(
                                        onMapCreated: (contr) {
                                          _controller.complete(contr);
                                        },
                                        onTap: (s) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey:
                                                    'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                                selectText: 'Pick This Place',
                                                onTapBack: () {
                                                  Get.close(1);
                                                },
                                                onPlacePicked: (result) async {
                                                  Get.dialog(LoadingDialog(),
                                                      barrierDismissible:
                                                          false);
                                                  LatLng latLng =
                                                      await getPlaceLatLng(
                                                          result.placeId ?? '');
                                                  lat = latLng.latitude;
                                                  long = latLng.longitude;
                                                  setState(() {});

                                                  final GeoFirePoint
                                                      geoFirePoint =
                                                      GeoFirePoint(
                                                          GeoPoint(lat, long));

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userController
                                                          .userModel!.userId)
                                                      .update({
                                                    'lat': lat,
                                                    'geo': geoFirePoint.data,
                                                    'long': long,
                                                  });
                                                  final GoogleMapController
                                                      controller =
                                                      await _controller.future;
                                                  await controller.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                    target: LatLng(lat, long),
                                                    zoom: 16.0,
                                                  )));
                                                  Get.close(2);
                                                },
                                                initialPosition:
                                                    LatLng(lat, long),
                                                // useCurrentLocation: true,
                                                selectInitialPosition: true,
                                                resizeToAvoidBottomInset:
                                                    false, // only works in page mode, less flickery, remove if wrong offsets
                                              ),
                                            ),
                                          );
                                        },
                                        markers: {
                                          Marker(
                                            markerId: MarkerId('current'),
                                            position: LatLng(
                                                userController.userModel!.lat,
                                                userController.userModel!.long),
                                          ),
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              userController.userModel!.lat,
                                              userController.userModel!.long),
                                          zoom: 16.0,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // if (userController.userModel!.accountType ==
                            //     'provider')
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlacePicker(
                                          apiKey:
                                              'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                          selectText: 'Pick This Place',
                                          onPlacePicked: (result) async {
                                            Get.dialog(LoadingDialog(),
                                                barrierDismissible: false);
                                            LatLng latLng =
                                                await getPlaceLatLng(
                                                    result.placeId ?? '');
                                            lat = latLng.latitude;
                                            long = latLng.longitude;
                                            setState(() {});

                                            final GeoFirePoint geoFirePoint =
                                                GeoFirePoint(
                                                    GeoPoint(lat, long));

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userController
                                                    .userModel!.userId)
                                                .update({
                                              'lat': lat,
                                              'geo': geoFirePoint.data,
                                              'long': long,
                                            });
                                            final GoogleMapController
                                                controller =
                                                await _controller.future;
                                            await controller.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                                    CameraPosition(
                                              target: LatLng(lat, long),
                                              zoom: 16.0,
                                            )));
                                            Get.close(2);
                                          },
                                          initialPosition: LatLng(lat, long),
                                          // useCurrentLocation: true,
                                          selectInitialPosition: true,
                                          resizeToAvoidBottomInset:
                                              false, // only works in page mode, less flickery, remove if wrong offsets
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: Size(Get.width * 0.9, 50),
                                  ),
                                  child: Text(
                                    'Change Location',
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                            ),
                            // if (userController.userModel!.accountType ==
                            //     'provider')
                            const SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 1,
                                width: Get.width,
                                color: changeColor(color: 'D9D9D9'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
