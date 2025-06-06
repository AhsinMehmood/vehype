import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/offers_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../const.dart';
import 'choose_gallery_camera.dart';
import 'loading_dialog.dart';

class OwnerToServiceRatingSheet extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;

  const OwnerToServiceRatingSheet({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<OwnerToServiceRatingSheet> createState() =>
      _OwnerToServiceRatingSheetState();
}

class _OwnerToServiceRatingSheetState extends State<OwnerToServiceRatingSheet> {
  File? image;
  double rating = 1.0;
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.close(1);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Rate Your Experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Enter Feedback*',
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
                          hintText: 'Share your experience and any feedback...',
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
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Add Image',
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
                                        XFile? selectedImage =
                                            await ImagePicker().pickImage(
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
                                        XFile? selectedImage =
                                            await ImagePicker().pickImage(
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
                                                          Get.dialog(
                                                              LoadingDialog(),
                                                              barrierDismissible:
                                                                  false);
                                                          if (selectedImage !=
                                                              null) {
                                                            image = File(
                                                                selectedImage
                                                                    .path);

                                                            setState(() {});
                                                            Get.close(1);
                                                          }

                                                          Get.close(1);
                                                        },
                                                        onTapGallery: () async {
                                                          XFile? selectedImage =
                                                              await ImagePicker()
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .gallery);
                                                          Get.dialog(
                                                              LoadingDialog(),
                                                              barrierDismissible:
                                                                  false);
                                                          if (selectedImage !=
                                                              null) {
                                                            image = File(
                                                                selectedImage
                                                                    .path);
                                                            setState(() {});
                                                            Get.close(1);
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
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
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
                        'Select Rating*',
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
                  onPressed: commentController.text.trim().isEmpty
                      ? () {
                          toastification.show(
                            context: context,
                            title: Text('Feedback field is required!'),
                            autoCloseDuration: Duration(seconds: 3),
                          );
                        }
                      : () async {
                          Get.dialog(LoadingDialog(),
                              barrierDismissible: false);

                          if (image == null) {
                            // String url = await UserController()
                            //     .uploadImage(image!, userModel.userId);
                            setState(() {});
                            await FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(widget.offersReceivedModel.id)
                                .update({
                              // 'status': 'finish',
                              'ratingOne': rating,
                              'commentOne': commentController.text.trim(),

                              'ratingOneImage': '',
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.offersReceivedModel.offerBy)
                                .update({
                              'ratings': FieldValue.arrayUnion([
                                {
                                  'id': userModel.userId,
                                  'rating': rating,
                                  'comment': commentController.text.trim(),
                                  'service': widget.offersModel.issue,
                                  // 'images': url,
                                  'at':
                                      DateTime.now().toUtc().toIso8601String(),
                                }
                              ])
                            });
                          } else {
                            String url = await UserController()
                                .uploadImage(image!, userModel.userId);
                            setState(() {});
                            await FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(widget.offersReceivedModel.id)
                                .update({
                              // 'status': 'finish',
                              'ratingOne': rating,
                              'commentOne': commentController.text.trim(),
                              'ratingOneImage': url,
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.offersReceivedModel.offerBy)
                                .update({
                              'ratings': FieldValue.arrayUnion([
                                {
                                  'id': userModel.userId,
                                  'rating': rating,
                                  'comment': commentController.text.trim(),
                                  'service': widget.offersModel.issue,
                                  'images': url,
                                  'at':
                                      DateTime.now().toUtc().toIso8601String(),
                                }
                              ])
                            });
                          }
                          DocumentSnapshot<Map<String, dynamic>> ownerSnap =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.offersReceivedModel.offerBy)
                                  .get();

                          NotificationController().sendNotification(
                              userIds: [UserModel.fromJson(ownerSnap).userId],
                              offerId: widget.offersModel.offerId,
                              requestId: widget.offersReceivedModel.id,
                              title:
                                  'Feedback Received: ${userController.userModel!.name}',
                              subtitle:
                                  '${userController.userModel!.name} has rated your service request. Review their feedback and rating.');

                          OffersController().updateNotificationForOffers(
                              offerId: widget.offersModel.offerId,
                              userId: widget.offersReceivedModel.offerBy,
                              isAdd: true,
                              senderId: userController.userModel!.userId,
                              offersReceived: widget.offersReceivedModel.id,
                              checkByList: widget.offersModel.checkByList,
                              notificationTitle:
                                  'Feedback Received: ${userController.userModel!.name}',
                              notificationSubtitle:
                                  '${userController.userModel!.name} has rated your service request. Review their feedback and rating.');

                          Get.close(2);
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
                      color:
                          userController.isDark ? primaryColor : Colors.white,
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
      ),
    );
  }
}
