import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_your_image/crop_your_image.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';

import '../Widgets/loading_dialog.dart';
import '../const.dart';

class CropImagePage extends StatefulWidget {
  final File imageData;
  final String imageField;

  const CropImagePage(
      {super.key, required this.imageData, required this.imageField});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = Provider.of<UserController>(context).userModel!;

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
            )),
        title: Text(
          'Crop Profile Image',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
                baseColor: Colors.black,
                initialSize: 1,
                image: widget.imageData.readAsBytesSync(),
                radius: 0,
                aspectRatio: 1,
                controller: _controller,
                withCircleUi: true,
                onCropped: (image) async {
                  File fromBytes = await widget.imageData.writeAsBytes(image);

                  String imageUrl = await UserController()
                      .uploadImage(fromBytes, userModel.userId);
                  Get.close(1);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userModel.userId)
                      .update({'profileUrl': imageUrl});
                  // await EditProfileProvider().saveImage(
                  //     compressedFile.readAsBytesSync(),
                  //     widget.imageField,
                  //     userModel);

                  // do something with
                  // image data
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.dialog(LoadingDialog(), barrierDismissible: false);

              _controller.crop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                maximumSize: Size(Get.width * 0.8, 50),
                minimumSize: Size(Get.width * 0.8, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                )),
            child: Text(
              'Save',
              style: TextStyle(
                color: userController.isDark ? primaryColor : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class CropImageAndSelect extends StatefulWidget {
  final Uint8List imageData;
  // final String imageField;
  final Function(Uint8List croppedImageData) onSave;
  const CropImageAndSelect(
      {super.key, required this.imageData, required this.onSave});

  @override
  State<CropImageAndSelect> createState() => _CropImageAndSelectState();
}

class _CropImageAndSelectState extends State<CropImageAndSelect> {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    // final UserModel userModel = Provider.of<UserModel>(context);
    UserModel userModel = Provider.of<UserController>(context).userModel!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            )),
        title: Text(
          'Crop Image',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
                baseColor: Colors.black,
                initialSize: 0.7,
                image: widget.imageData,
                aspectRatio: 1,
                radius: 0,
                controller: _controller,
                onCropped: (image) async {
                  await widget.onSave(image);
                  // await EditProfileProvider()
                  //     .saveImage(image, widget.imageField, userModel);
                  // do something with image data
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.dialog(LoadingDialog(), barrierDismissible: false);

              _controller.crop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                maximumSize: Size(Get.width * 0.8, 55),
                minimumSize: Size(Get.width * 0.8, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
