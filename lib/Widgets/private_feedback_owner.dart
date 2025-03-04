import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/pdf_generator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/offers_controller.dart';
import 'choose_gallery_camera.dart';
import 'loading_dialog.dart';
// import 'package:vehype/app.dart';

class PrivateFeedbackOwner extends StatefulWidget {
  // final UserModel serviceProfile;
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;
  const PrivateFeedbackOwner({
    super.key,
    required this.offersModel,
    required this.offersReceivedModel,
    // required this.serviceProfile,
  });

  @override
  State<PrivateFeedbackOwner> createState() => _PrivateFeedbackOwnerState();
}

class _PrivateFeedbackOwnerState extends State<PrivateFeedbackOwner> {
  File? image;
  double rating = 1.0;
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Private Feedback',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Private feedback will be submitted to VEHYPE\'s support team and will only be visible to our team. The service owner will not be informed about this, and you will be notified of our decision via in-app notifications and your registered email address. Thank you for supporting our efforts to keep VEHYPE\'s community safe.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Add Image (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 220,
                      width: Get.width,
                      child: image == null
                          ? InkWell(
                              onTap: () async {
                                Get.bottomSheet(
                                  ChooseGalleryCamera(
                                    onTapCamera: () async {
                                      XFile? selectedImage = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.camera);
                                      Get.dialog(LoadingDialog(),
                                          barrierDismissible: false);
                                      if (selectedImage != null) {
                                        image = File(selectedImage.path);

                                        setState(() {});
                                        Get.close(1);
                                      }

                                      Get.close(1);
                                    },
                                    onTapGallery: () async {
                                      XFile? selectedImage = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      Get.dialog(LoadingDialog(),
                                          barrierDismissible: false);
                                      if (selectedImage != null) {
                                        image = File(selectedImage.path);
                                        setState(() {});
                                        Get.close(1);
                                      }

                                      Get.close(1);
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
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.2))),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 70,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: userController.isDark
                                          ? Colors.white.withOpacity(0.2)
                                          : primaryColor.withOpacity(0.2))),
                              child: Stack(
                                children: [
                                  Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                    height: 220,
                                    width: Get.width,
                                  ),
                                  Positioned(
                                      right: 0,
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                              right: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                              color: Colors.white,
                                            ),
                                            child: IconButton(
                                                onPressed: () {
                                                  Get.bottomSheet(
                                                    ChooseGalleryCamera(
                                                      onTapCamera: () async {
                                                        XFile? selectedImage =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                    source: ImageSource
                                                                        .camera);
                                                        // print(selectedImage);
                                                        // Get.dialog(
                                                        //     LoadingDialog(),
                                                        //     barrierDismissible:
                                                        //         false);
                                                        if (selectedImage !=
                                                            null) {
                                                          image = File(
                                                              selectedImage
                                                                  .path);

                                                          setState(() {});
                                                          // Get.close(1);
                                                        }

                                                        Get.close(1);
                                                      },
                                                      onTapGallery: () async {
                                                        // Get.dialog(
                                                        //     LoadingDialog(),
                                                        //     barrierDismissible:
                                                        //         false);
                                                        // print('selectedImage');

                                                        XFile? selectedImage =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                    source: ImageSource
                                                                        .gallery);
                                                        print('selectedImage');

                                                        // Get.close(1);

                                                        // Get.dialog(
                                                        //     LoadingDialog(),
                                                        //     barrierDismissible:
                                                        //         false);
                                                        // print(selectedImage);

                                                        if (selectedImage !=
                                                            null) {
                                                          image = File(
                                                              selectedImage
                                                                  .path);
                                                          setState(() {});
                                                        }

                                                        Get.close(1);
                                                      },
                                                    ),
                                                    backgroundColor:
                                                        userController.isDark
                                                            ? primaryColor
                                                            : Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                color: primaryColor,
                                                icon: Icon(
                                                  Icons.edit,
                                                )),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            )),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Feedback *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      maxLines: 5,
                      maxLength: 256,
                      controller: commentController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      onChanged: (u) {
                        // setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your feedback...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          // color: Colors.grey[400],
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Rating *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (ratings) {
                      // Update the rating value
                      setState(() {
                        rating = ratings;
                      });
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {});
                  if (commentController.text.isEmpty) {
                    toastification.show(
                      context: context,
                      title: Text('Feedback field is required!'),
                      autoCloseDuration: Duration(seconds: 3),
                    );
                    return;
                  }
                  Get.dialog(LoadingDialog(), barrierDismissible: false);
                  String url = image == null
                      ? ''
                      : await UserController()
                          .uploadImage(image!, userModel.userId);
                  print(url);
                  DocumentReference<Map<String, dynamic>> feedbackId =
                      await FirebaseFirestore.instance
                          .collection('privateFeedback')
                          // .doc(widget.offersReceivedModel.offerBy)
                          .add({
                    'ownerId': userModel.userId,
                    'rating': rating,
                    'comment': commentController.text.trim(),
                    'status': 'Pending',
                    'serviceId': widget.offersReceivedModel.offerBy,
                    'offerReceivedId': widget.offersReceivedModel.id,
                    'images': url,
                    'at': DateTime.now().toUtc().toIso8601String(),
                  });
                  await FirebaseFirestore.instance
                      .collection('offersReceived')
                      .doc(widget.offersReceivedModel.id)
                      .update({
                    'feedbackId': feedbackId.id,
                  });

                  Get.close(2);
                  await PDFGenerator.sendEmailForReport(
                      userModel,
                      userModel,
                      widget.offersReceivedModel,
                      widget.offersModel,
                      feedbackId.id,
                      userController,
                      commentController.text,
                      rating.toString());
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                    elevation: 0.0,
                    fixedSize: Size(Get.width * 0.9, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    )),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
