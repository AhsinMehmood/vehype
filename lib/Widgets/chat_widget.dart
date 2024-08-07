// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/const.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.user,
    required this.chat,
  });

  final UserModel user;
  final ChatModel chat;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime lastMessageAt = DateTime.parse(widget.chat.lastMessageAt);
    DateTime lastOpen =
        DateTime.parse(widget.chat.lastOpen[widget.user.userId]);

    FontWeight fontWeight =
        lastMessageAt != lastOpen ? FontWeight.w800 : FontWeight.w400;

    return StreamBuilder<UserModel>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.chat.members
                .firstWhere((element) => element != widget.user.userId))
            .snapshots()
            .map((event) => UserModel.fromJson(event)),
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.data != null) {
            UserModel secondUserData = snapshot.data!;
            return InkWell(
              onTap: () {
                if (getUnread(widget.chat.lastMessageAt,
                    widget.chat.lastOpen[widget.user.userId], context)) {
                  FlutterAppBadger.removeBadge();
                }
                Get.to(() => MessagePage(
                      chatModel: widget.chat,
                      secondUser: secondUserData,
                    ));
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() =>
                              SecondUserProfile(userId: secondUserData.userId));
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: ExtendedImage.network(
                                secondUserData.profileUrl,
                                fit: BoxFit.cover,
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            RatingBarIndicator(
                              rating: secondUserData.rating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 12.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    secondUserData.name,
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontFamily: 'Avenir',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.chat.text
                                            .contains('Start the chat with')
                                        ? '${widget.chat.text} ' +
                                            secondUserData.name
                                        : getText(
                                            widget.chat.text,
                                            widget.chat.lastMessageMe ==
                                                widget.user.userId),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontFamily: 'Avenir',
                                      fontSize: 14,
                                      fontWeight: getUnread(
                                              widget.chat.lastMessageAt,
                                              widget.chat
                                                  .lastOpen[widget.user.userId],
                                              context)
                                          ? FontWeight.bold
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            height: 85,
                            width: 90,
                            child: Stack(
                              children: [
                                if (widget.chat.offerId != '')
                                  Positioned(
                                    bottom: 0,
                                    child: StreamBuilder<OffersModel>(
                                        stream: FirebaseFirestore.instance
                                            .collection('offers')
                                            .doc(widget.chat.offerId)
                                            .snapshots()
                                            .map((event) =>
                                                OffersModel.fromJson(event)),
                                        builder: (context,
                                            AsyncSnapshot<OffersModel>
                                                snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            OffersModel offersModel =
                                                snapshot.data!;
                                            String title =
                                                offersModel.vehicleId != ''
                                                    ? offersModel.vehicleId
                                                        .split(',')[1]
                                                    : '';
                                            return Container(
                                              child: offersModel.imageOne == ''
                                                  ? SizedBox.shrink()
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ExtendedImage.network(
                                                          offersModel.imageOne,
                                                          height: 45,
                                                          width: 70,
                                                          fit: BoxFit.cover,
                                                          cache: true,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          title.trim(),
                                                          style: TextStyle(
                                                            // color: Colors.black,
                                                            fontFamily:
                                                                'Avenir',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                                getServices()
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .name ==
                                                                        offersModel
                                                                            .issue)
                                                                    .image,
                                                                color: userController
                                                                        .isDark
                                                                    ? Colors
                                                                        .white
                                                                    : primaryColor,
                                                                height: 15,
                                                                width: 15),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                              offersModel.issue,
                                                              style: TextStyle(
                                                                // color: Colors.black,
                                                                fontFamily:
                                                                    'Avenir',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                            );
                                          }
                                          return Container();
                                        }),
                                  ),
                                if (getUnread(
                                    widget.chat.lastMessageAt,
                                    widget.chat.lastOpen[widget.user.userId],
                                    context))
                                  Positioned(
                                    top: 1,
                                    right: 0,
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                      height: 0.5,
                      margin: const EdgeInsets.all(10),
                      width: Get.width,
                      color: Colors.grey.shade300),
                ],
              ),
            );
          } else {
            return Container(
              child: CupertinoActivityIndicator(),
            );
          }
        });
  }

  getText(String text, bool byMe) {
    if (byMe) {
      return text != '' ? 'You: ' + text : 'You: Sent Media';
    } else {
      return text != '' ? text : 'Media Message';
    }
  }

  bool getUnread(String sentAt, String lastOpen, BuildContext context) {
    bool unreadMessage = DateTime.parse(sentAt)
            .toLocal()
            .difference(DateTime.parse(lastOpen).toLocal())
            .inSeconds >
        0;

    return unreadMessage;
  }
}

/**
 * 
 * // ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/const.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.user,
    required this.chat,
  });

  final UserModel user;
  final ChatModel chat;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime lastMessageAt = DateTime.parse(widget.chat.lastMessageAt);
    DateTime lastOpen =
        DateTime.parse(widget.chat.lastOpen[widget.user.userId]);

    FontWeight fontWeight =
        lastMessageAt != lastOpen ? FontWeight.w800 : FontWeight.w400;

    return StreamBuilder<UserModel>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.chat.members
                .firstWhere((element) => element != widget.user.userId))
            .snapshots()
            .map((event) => UserModel.fromJson(event)),
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.data != null) {
            UserModel secondUserData = snapshot.data!;
            return StreamBuilder<OffersModel>(
                stream: FirebaseFirestore.instance
                    .collection('offers')
                    .doc(widget.chat.offerId)
                    .snapshots()
                    .map((event) => OffersModel.fromJson(event)),
                builder: (context, AsyncSnapshot<OffersModel> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    OffersModel offersModel = snapshot.data!;
                    String title = offersModel.vehicleId != ''
                        ? offersModel.vehicleId.split(',')[1]
                        : '';
                    return InkWell(
                      onTap: () {
                        if (getUnread(
                            widget.chat.lastMessageAt,
                            widget.chat.lastOpen[widget.user.userId],
                            context)) {
                          FlutterAppBadger.removeBadge();
                        }
                        Get.to(() => MessagePage(
                              chatModel: widget.chat,
                              secondUser: secondUserData,
                            ));
                      },
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => SecondUserProfile(
                                        userId: secondUserData.userId));
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: ExtendedImage.network(
                                            offersModel.imageOne,
                                            fit: BoxFit.cover,
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            child: ExtendedImage.network(
                                              secondUserData.profileUrl,
                                              fit: BoxFit.cover,
                                              height: 25,
                                              width: 25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              secondUserData.name,
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontFamily: 'Avenir',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title.trim(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontFamily: 'Avenir',
                                                fontSize: 16,
                                                fontWeight: getUnread(
                                                        widget
                                                            .chat.lastMessageAt,
                                                        widget.chat.lastOpen[
                                                            widget.user.userId],
                                                        context)
                                                    ? FontWeight.bold
                                                    : FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.chat.text.contains(
                                                      'Start the chat with')
                                                  ? '${widget.chat.text} ' +
                                                      secondUserData.name
                                                  : getText(
                                                      widget.chat.text,
                                                      widget.chat
                                                              .lastMessageMe ==
                                                          widget.user.userId),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontFamily: 'Avenir',
                                                fontSize: 14,
                                                fontWeight: getUnread(
                                                        widget
                                                            .chat.lastMessageAt,
                                                        widget.chat.lastOpen[
                                                            widget.user.userId],
                                                        context)
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 85,
                                      // margin: const Ed,
                                      width: 90,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (getUnread(
                                              widget.chat.lastMessageAt,
                                              widget.chat
                                                  .lastOpen[widget.user.userId],
                                              context))
                                            Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                              ),
                                            )
                                          else
                                            SizedBox(),
                                          SvgPicture.asset(
                                            getServices()
                                                .firstWhere((dd) =>
                                                    dd.name ==
                                                    offersModel.issue)
                                                .image,
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                            height: 35,
                                            width: 35,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              height: 0.6,
                              margin: const EdgeInsets.all(0),
                              width: Get.width,
                              color: userController.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : primaryColor.withOpacity(0.1)),
                        ],
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        if (getUnread(
                            widget.chat.lastMessageAt,
                            widget.chat.lastOpen[widget.user.userId],
                            context)) {
                          FlutterAppBadger.removeBadge();
                        }
                        Get.to(() => MessagePage(
                              chatModel: widget.chat,
                              secondUser: secondUserData,
                            ));
                      },
                      // child: Column(
                      //   children: [
                      //     Row(
                      //       children: [
                      //         InkWell(
                      //           onTap: () {
                      //             Get.to(() => SecondUserProfile(
                      //                 userId: secondUserData.userId));
                      //           },
                      //           child: Stack(
                      //             children: [
                      //               ClipRRect(
                      //                 borderRadius: BorderRadius.circular(200),
                      //                 child: ExtendedImage.network(
                      //                   secondUserData.profileUrl,
                      //                   fit: BoxFit.cover,
                      //                   height: 40,
                      //                   width: 40,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         const SizedBox(
                      //           width: 15,
                      //         ),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   Expanded(
                      //                     child: Text(
                      //                       secondUserData.name,
                      //                       style: TextStyle(
                      //                         // color: Colors.black,
                      //                         fontFamily: 'Avenir',
                      //                         fontSize: 18,
                      //                         fontWeight: FontWeight.w700,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),

                      //               const SizedBox(
                      //                 height: 5,
                      //               ),
                      //               Row(
                      //                 children: [
                      //                   Expanded(
                      //                     child: Text(
                      //                       widget.chat.text.contains(
                      //                               'Start the chat with')
                      //                           ? '${widget.chat.text} ' +
                      //                               secondUserData.name
                      //                           : getText(
                      //                               widget.chat.text,
                      //                               widget.chat.lastMessageMe ==
                      //                                   widget.user.userId),
                      //                       overflow: TextOverflow.ellipsis,
                      //                       maxLines: 2,
                      //                       style: TextStyle(
                      //                         // color: Colors.black,
                      //                         fontFamily: 'Avenir',
                      //                         fontSize: 14,
                      //                         fontWeight: getUnread(
                      //                                 widget.chat.lastMessageAt,
                      //                                 widget.chat.lastOpen[
                      //                                     widget.user.userId],
                      //                                 context)
                      //                             ? FontWeight.bold
                      //                             : FontWeight.w400,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ),

                      //       ],
                      //     ),
                      //     Container(
                      //         height: 0.5,
                      //         margin: const EdgeInsets.all(10),
                      //         width: Get.width,
                      //         color: Colors.grey.shade300),
                      //   ],
                      // ),
                    );
                  }
                });
          } else {
            return Container(
              child: CupertinoActivityIndicator(),
            );
          }
        });
  }

  getText(String text, bool byMe) {
    if (byMe) {
      return text != '' ? 'You: ' + text : 'You: Sent Media';
    } else {
      return text != '' ? text : 'Media Message';
    }
  }

  bool getUnread(String sentAt, String lastOpen, BuildContext context) {
    bool unreadMessage = DateTime.parse(sentAt)
            .toLocal()
            .difference(DateTime.parse(lastOpen).toLocal())
            .inSeconds >
        0;

    return unreadMessage;
  }
}

 * 
 * 
 * 
 * 
 * 
 * **/