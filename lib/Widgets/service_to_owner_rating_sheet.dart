import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Pages/repair_page.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import '../Models/user_model.dart';
import '../const.dart';
import 'choose_gallery_camera.dart';
import 'loading_dialog.dart';

class ServiceToOwnerRatingSheet extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;

  const ServiceToOwnerRatingSheet({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<ServiceToOwnerRatingSheet> createState() =>
      _ServiceToOwnerRatingSheetState();
}

class _ServiceToOwnerRatingSheetState extends State<ServiceToOwnerRatingSheet> {
  File? image;
  double rating = 1.0;
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return BottomSheet(
        backgroundColor: widget.isDark ? primaryColor : Colors.white,
        onClosing: () {},
        constraints: BoxConstraints(
          minHeight: Get.height * 0.9,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        builder: (cc) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isDark ? primaryColor : Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          'Please rate your experience and provide any comments and relevent images to help others.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                            height: Get.width * 0.4,
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
                                              File compressedFile =
                                                  await FlutterNativeImage
                                                      .compressImage(
                                                File(selectedImage.path)
                                                    .absolute
                                                    .path,
                                                quality: 100,
                                                percentage: 50,
                                              );
                                              image = compressedFile;

                                              setState(() {});
                                              Get.close(1);
                                            }

                                            Get.close(1);
                                          },
                                          onTapGallery: () async {
                                            XFile? selectedImage =
                                                await ImagePicker().pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            Get.dialog(LoadingDialog(),
                                                barrierDismissible: false);
                                            if (selectedImage != null) {
                                              File compressedFile =
                                                  await FlutterNativeImage
                                                      .compressImage(
                                                File(selectedImage.path)
                                                    .absolute
                                                    .path,
                                                quality: 100,
                                                percentage: 50,
                                              );

                                              image = compressedFile;
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
                                    child: Card(
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 70,
                                      ),
                                    ),
                                  )
                                : Card(
                                    child: Stack(
                                      children: [
                                        ExtendedImage.file(
                                          image!,
                                          fit: BoxFit.cover,
                                          width: Get.width,
                                          height: Get.width * 0.4,
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
                                                        BorderRadius.circular(
                                                            200),
                                                    color: Colors.white,
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Get.bottomSheet(
                                                          ChooseGalleryCamera(
                                                            onTapCamera:
                                                                () async {
                                                              XFile?
                                                                  selectedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.camera);
                                                              Get.dialog(
                                                                  LoadingDialog(),
                                                                  barrierDismissible:
                                                                      false);
                                                              if (selectedImage !=
                                                                  null) {
                                                                File
                                                                    compressedFile =
                                                                    await FlutterNativeImage
                                                                        .compressImage(
                                                                  File(selectedImage
                                                                          .path)
                                                                      .absolute
                                                                      .path,
                                                                  quality: 100,
                                                                  percentage:
                                                                      50,
                                                                );
                                                                image =
                                                                    compressedFile;

                                                                setState(() {});
                                                                Get.close(1);
                                                              }

                                                              Get.close(1);
                                                            },
                                                            onTapGallery:
                                                                () async {
                                                              XFile?
                                                                  selectedImage =
                                                                  await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                              Get.dialog(
                                                                  LoadingDialog(),
                                                                  barrierDismissible:
                                                                      false);
                                                              if (selectedImage !=
                                                                  null) {
                                                                File
                                                                    compressedFile =
                                                                    await FlutterNativeImage
                                                                        .compressImage(
                                                                  File(selectedImage
                                                                          .path)
                                                                      .absolute
                                                                      .path,
                                                                  quality: 100,
                                                                  percentage:
                                                                      50,
                                                                );

                                                                image =
                                                                    compressedFile;
                                                                setState(() {});
                                                                Get.close(1);
                                                              }

                                                              Get.close(1);
                                                            },
                                                          ),
                                                          backgroundColor:
                                                              userController
                                                                      .isDark
                                                                  ? primaryColor
                                                                  : Colors
                                                                      .white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(20),
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
                          height: 30,
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
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
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
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            onChanged: (u) {
                              // setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Share your experience and any feedback...',
                              hintStyle: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: commentController.text.isEmpty
                          ? () {
                              toastification.show(
                                context: context,
                                title: Text('Comment field is required!'),
                                autoCloseDuration: Duration(seconds: 3),
                              );
                            }
                          : () async {
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              await UserController().addToNotifications(
                                userModel,
                                widget.offersReceivedModel.ownerId,
                                'offer',
                                widget.offersReceivedModel.id,
                                'Offer Update',
                                '${userModel.name}, Rated the Request',
                              );

                              await sendNotification(
                                  widget.offersReceivedModel.ownerId,
                                  userModel.name,
                                  'Offer Update',
                                  '${userModel.name}, Rated the Request',
                                  widget.offersReceivedModel.id,
                                  'offer',
                                  '');

                              if (image == null) {
                                // String url = await UserController()
                                //     .uploadImage(image!, userModel.userId);
                                setState(() {});
                                await FirebaseFirestore.instance
                                    .collection('offersReceived')
                                    .doc(widget.offersReceivedModel.id)
                                    .update({
                                  // 'status': 'finish',
                                  'ratingTwo': rating,
                                  'commentTwo': commentController.text.trim(),
                                  'media': '',
                                });
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.offersReceivedModel.ownerId)
                                    .update({
                                  'ratings': FieldValue.arrayUnion([
                                    {
                                      'id': userModel.userId,
                                      'rating': rating,
                                      'comment': commentController.text.trim(),
                                      // 'images': url,
                                      'at': DateTime.now()
                                          .toUtc()
                                          .toIso8601String(),
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
                                  'ratingTwo': rating,
                                  'commentTwo': commentController.text.trim(),
                                  'media': url,
                                });
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.offersReceivedModel.ownerId)
                                    .update({
                                  'ratings': FieldValue.arrayUnion([
                                    {
                                      'id': userModel.userId,
                                      'rating': rating,
                                      'comment': commentController.text.trim(),
                                      'images': url,
                                      'at': DateTime.now()
                                          .toUtc()
                                          .toIso8601String(),
                                    }
                                  ])
                                });
                              }

                              // await userController.getRequestsHistoryProvider();

                              Get.close(2);
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          elevation: 0.0,
                          fixedSize: Size(Get.width * 0.8, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontSize: 18,
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
        });
  }
}
