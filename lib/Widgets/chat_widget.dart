// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_app_icon_badge/flutter_app_icon_badge.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/const.dart';
import 'package:intl/intl.dart';

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
  String formatDateTime(DateTime sentAt) {
    final now = DateTime.now();
    final difference = now.difference(sentAt.toLocal());

    if (difference.inHours >= 24) {
      // Return date in format like "21 Aug"
      return DateFormat('d MMM').format(sentAt);
    } else {
      // Return time in format like "4:26 PM"
      return DateFormat('h:mm a').format(sentAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime lastMessageAt = DateTime.parse(widget.chat.lastMessageAt);
    DateTime lastOpen =
        DateTime.parse(widget.chat.lastOpen[widget.user.userId]);

    FontWeight fontWeight =
        lastMessageAt != lastOpen ? FontWeight.w800 : FontWeight.w400;
    print(widget.chat.id);
    return StreamBuilder<UserModel>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.chat.members
                .firstWhere((element) => element != widget.user.userId))
            .snapshots()
            .map((event) => UserModel.fromJson(event)),
        builder: (context, AsyncSnapshot<UserModel> userSnap) {
          if (userSnap.data != null) {
            UserModel secondUserData = userSnap.data!;
            return StreamBuilder<OffersModel>(
                stream: FirebaseFirestore.instance
                    .collection('offers')
                    .doc(widget.chat.offerId)
                    .snapshots()
                    .map((event) => OffersModel.fromJson(event)),
                builder: (context, AsyncSnapshot<OffersModel> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    OffersModel offersModel = snapshot.data!;

                    return StreamBuilder<GarageModel>(
                        stream: FirebaseFirestore.instance
                            .collection('garages')
                            .doc(offersModel.garageId)
                            .snapshots()
                            .map((convert) => GarageModel.fromJson(convert)),
                        builder:
                            (context, AsyncSnapshot<GarageModel> garageSnap) {
                          if (garageSnap.hasData && garageSnap.data != null) {
                            final GarageModel garageModel = garageSnap.data!;
                            return InkWell(
                              onTap: () {
                                if (getUnread(
                                    widget.chat.lastMessageAt,
                                    widget.chat.lastOpen[widget.user.userId],
                                    context)) {
                                  // FlutterAppBadger.removeBadge();
                                  // FlutterAppIconBadge.removeBadge();
                                }
                                Get.to(() => MessagePage(
                                      chatModel: widget.chat,
                                      garageModel: garageModel,
                                      secondUser: secondUserData,
                                      offersModel: offersModel,
                                    ));
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.to(() => SecondUserProfile(
                                                userId: secondUserData.userId));
                                          },
                                          child: SizedBox(
                                            height: 55,
                                            width: 55,
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        garageModel.imageUrl,
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
                                                        BorderRadius.circular(
                                                            200),
                                                    child: CachedNetworkImage(
                                                      imageUrl: secondUserData
                                                          .profileUrl,
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
                                              Text(
                                                secondUserData.name,
                                                style: TextStyle(
                                                  color: userController.isDark
                                                      ? Colors.white
                                                      : primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
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
                                                      garageModel.title,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                              secondUserData
                                                                  .name
                                                          : getText(
                                                              widget.chat.text,
                                                              widget.chat
                                                                      .lastMessageMe ==
                                                                  widget.user
                                                                      .userId),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                        fontSize: 14,
                                                        fontWeight: getUnread(
                                                                widget.chat
                                                                    .lastMessageAt,
                                                                widget.chat
                                                                        .lastOpen[
                                                                    widget.user
                                                                        .userId],
                                                                context)
                                                            ? FontWeight.bold
                                                            : FontWeight.w700,
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
                                            SizedBox(
                                              height: 70,
                                              // margin: const Ed,
                                              width: 90,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  if (getUnread(
                                                      widget.chat.lastMessageAt,
                                                      widget.chat.lastOpen[
                                                          widget.user.userId],
                                                      context))
                                                    Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(200),
                                                      ),
                                                    ),
                                                  Text(
                                                    formatDateTime(
                                                      DateTime.parse(widget.chat
                                                              .lastMessageAt)
                                                          .toLocal(),
                                                    ),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                    getServices()
                                                        .firstWhere((dd) =>
                                                            dd.name ==
                                                            offersModel.issue)
                                                        .image,
                                                    color: userController.isDark
                                                        ? Colors.white
                                                        : primaryColor,
                                                    height: 30,
                                                    width: 30,
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
                                    height: 0,
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
                            return Container();
                          }
                        });
                  } else {
                    return SizedBox();
                  }
                });
          } else {
            return Container();
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
