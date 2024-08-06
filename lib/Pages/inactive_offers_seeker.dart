// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/comments_page.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Widgets/choose_gallery_camera.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_details_button_widget.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/bad_words.dart';

import '../Controllers/garage_controller.dart';
import '../Models/user_model.dart';
import '../const.dart';
import 'repair_page.dart';

class InActiveOffersSeeker extends StatefulWidget {
  final OffersModel offersModel;
  final String tittle;
  final bool isFromNoti;
  final OffersReceivedModel offersReceivedModel;
  const InActiveOffersSeeker(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel,
      required this.tittle,
      this.isFromNoti = false});

  @override
  State<InActiveOffersSeeker> createState() => _InActiveOffersSeekerState();
}

class _InActiveOffersSeekerState extends State<InActiveOffersSeeker> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    List<String> vehicleInfo = widget.offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              // garageController.disposeController();

              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          widget.offersReceivedModel.status == 'ignore'
              ? 'Ignored'
              : widget.offersReceivedModel.status,
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<List<OffersReceivedModel>>(
          stream: FirebaseFirestore.instance
              .collection('offersReceived')
              .where('ownerId', isEqualTo: userModel.userId)
              .where('offerId', isEqualTo: widget.offersModel.offerId)
              // .where('status', isNotEqualTo: 'ignore')
              .snapshots()
              .map((event) => event.docs
                  .map((e) => OffersReceivedModel.fromJson(e))
                  .toList()),
          builder:
              (context, AsyncSnapshot<List<OffersReceivedModel>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            List<OffersReceivedModel> filter = snapshot.data ?? [];
            List<OffersReceivedModel> offers =
                filter.where((offer) => offer.status != 'Pending').toList();

            return ListView.builder(
                itemCount: offers.length,
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  OffersReceivedModel offersReceivedModel = offers[index];
                  return StreamBuilder<UserModel>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(offersReceivedModel.offerBy)
                          .snapshots()
                          .map((newEvent) => UserModel.fromJson(newEvent)),
                      builder: (context, snapshot2) {
                        if (!snapshot2.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          );
                        }
                        UserModel postedByDetails = snapshot2.data!;
                        return Container(
                          // color: Colors.white,
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              if (widget.isFromNoti)
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: VehicleDetailsRequest(
                                      userController: userController,
                                      vehicleType: vehicleType,
                                      vehicleMake: vehicleMake,
                                      vehicleYear: vehicleYear,
                                      vehicleModle: vehicleModle,
                                      offersModel: widget.offersModel),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(200),
                                    child: ExtendedImage.network(
                                      postedByDetails.profileUrl,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.fill,
                                      cache: true,
                                      // border: Border.all(color: Colors.red, width: 1.0),
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(200.0)),
                                      //cancelToken: cancellationToken,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postedByDetails.name,
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(() => CommentsPage(
                                              data: postedByDetails));
                                        },
                                        child: Row(
                                          children: [
                                            RatingBarIndicator(
                                              rating: postedByDetails.rating,
                                              itemBuilder: (context, index) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 25.0,
                                              direction: Axis.horizontal,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              postedByDetails.ratings.length
                                                  .toString(),
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: OfferRequestDetails(
                                    userController: userController,
                                    offersReceivedModel: offersReceivedModel),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              OfferDetailsButtonWidget(
                                offersReceivedModel: offersReceivedModel,
                                userModel: userModel,
                                postedByDetails: postedByDetails,
                                offersModel: widget.offersModel,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      });
                });
          }),
    );
  }
}

class OwnerToProviderRatingSheet extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;

  const OwnerToProviderRatingSheet({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<OwnerToProviderRatingSheet> createState() =>
      _OwnerToProviderRatingSheetState();
}

class _OwnerToProviderRatingSheetState
    extends State<OwnerToProviderRatingSheet> {
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
                        SizedBox(
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
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: commentController.text.isEmpty
                          ? null
                          : () async {
                              if (image == null) {
                                Get.dialog(LoadingDialog(),
                                    barrierDismissible: false);
                                // String url = await UserController()
                                //     .uploadImage(image!, userModel.userId);
                                setState(() {});
                                UserController().addToNotifications(
                                    userModel,
                                    widget.offersReceivedModel.offerBy,
                                    'offer',
                                    widget.offersReceivedModel.id,
                                    'Offer Update',
                                    '${userModel.name}, Rated the Job');

                                sendNotification(
                                    widget.offersReceivedModel.offerBy,
                                    userModel.name,
                                    'Offer Update',
                                    '${userModel.name}, Rated the Job',
                                    widget.offersReceivedModel.id,
                                    'offer',
                                    '');

                                await FirebaseFirestore.instance
                                    .collection('offersReceived')
                                    .doc(widget.offersReceivedModel.id)
                                    .update({
                                  // 'status': 'finish',
                                  'ratingOne': rating,
                                  'commentOne': commentController.text.trim(),
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
                                Get.dialog(LoadingDialog(),
                                    barrierDismissible: false);
                                String url = await UserController()
                                    .uploadImage(image!, userModel.userId);
                                setState(() {});
                                UserController().addToNotifications(
                                    userModel,
                                    widget.offersReceivedModel.offerBy,
                                    'offer',
                                    widget.offersReceivedModel.id,
                                    'Offer Update',
                                    '${userModel.name}, Rated the Job');

                                sendNotification(
                                    widget.offersReceivedModel.offerBy,
                                    userModel.name,
                                    'Offer Update',
                                    '${userModel.name}, Rated the Job',
                                    widget.offersReceivedModel.id,
                                    'offer',
                                    '');

                                await FirebaseFirestore.instance
                                    .collection('offersReceived')
                                    .doc(widget.offersReceivedModel.id)
                                    .update({
                                  // 'status': 'finish',
                                  'ratingOne': rating,
                                  'commentOne': commentController.text.trim(),
                                  'media': url,
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
                          backgroundColor: Colors.green,
                          elevation: 0.0,
                          fixedSize: Size(Get.width * 0.8, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
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

class FromProviderToOwnerRatingSheet extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;

  const FromProviderToOwnerRatingSheet({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<FromProviderToOwnerRatingSheet> createState() =>
      _FromProviderToOwnerRatingSheetState();
}

class _FromProviderToOwnerRatingSheetState
    extends State<FromProviderToOwnerRatingSheet> {
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
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: commentController.text.isEmpty
                          ? null
                          : () async {
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              await UserController().addToNotifications(
                                userModel,
                                widget.offersReceivedModel.ownerId,
                                'offer',
                                widget.offersReceivedModel.id,
                                'Offer Update',
                                '${userModel.name}, Rated the Job',
                              );

                              await sendNotification(
                                  widget.offersReceivedModel.ownerId,
                                  userModel.name,
                                  'Offer Update',
                                  '${userModel.name}, Rated the Job',
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

                              Get.close(3);
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0.0,
                          fixedSize: Size(Get.width * 0.8, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
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
