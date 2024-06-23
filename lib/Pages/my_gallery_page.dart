import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Widgets/choose_gallery_camera.dart';

class MyGalleryPage extends StatelessWidget {
  const MyGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  final ImagePicker picker = ImagePicker();

                  Get.bottomSheet(
                    ChooseGalleryCamera(
                      onTapCamera: () async {
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          Get.dialog(LoadingDialog(),
                              useSafeArea: false, barrierDismissible: false);
                          String imageUrl = await userController.uploadImage(
                              File(image.path), userModel.userId);
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userModel.userId)
                              .update({
                            'gallery': FieldValue.arrayUnion([imageUrl])
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
                            useSafeArea: false, barrierDismissible: false);
                        for (Asset asset in pickImages) {
                          ByteData getFile = await asset.getByteData();
                          File file = await GarageController()
                              .writeToFile(getFile, asset.name);

                          images.add(file);
                        }
                        for (var element in images) {
                          String imageUrl = await userController.uploadImage(
                              element, userModel.userId);
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userModel.userId)
                              .update({
                            'gallery': FieldValue.arrayUnion([imageUrl])
                          });
                        }
                        Get.close(2);
                      },
                    ),
                    backgroundColor:
                        userController.isDark ? primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add_a_photo_outlined,
                  color: userController.isDark ? Colors.white : primaryColor,
                )),
          ),
        ],
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'My Gallery',
          style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor),
        ),
      ),
      body: PhotosTab(profile: userModel),
    );
  }
}
