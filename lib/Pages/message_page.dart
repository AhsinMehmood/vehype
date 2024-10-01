// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

// import 'package:flutter/widgets.dart';
// import 'package:flutter_link_previewer/flutter_link_previewer.dart' as lnp;
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_select/image_selector.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/garage_model.dart';

import 'package:vehype/Models/message_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/owner_active_request_details.dart';
import 'package:vehype/Pages/owner_request_details_inprogress_inactive_page.dart';
import 'package:vehype/Pages/service_request_details.dart';

import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Widgets/delete_chat_confirmation_sheet.dart';
// import 'package:vehype/Widgets/offer_request_details.dart';

import 'package:vehype/Widgets/video_player.dart';

import 'package:vehype/const.dart';

import '../Widgets/report_confirmation_sheet.dart';

class MessagePage extends StatefulWidget {
  final ChatModel chatModel;
  final UserModel secondUser;
  final GarageModel garageModel;
  final OffersModel offersModel;
  const MessagePage(
      {super.key,
      required this.chatModel,
      required this.secondUser,
      required this.garageModel,
      required this.offersModel});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController textMessageController = TextEditingController();
  ScrollController messageScrollController = ScrollController();

  // UserModel? secondUser;

  @override
  void initState() {
    super.initState();

    getChatModel();
  }

  getChatModel() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    UserModel userModel = userController.userModel!;
    ChatController().updateChatTime(userModel, widget.chatModel);
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final ChatController chatController = Provider.of<ChatController>(context);
    // String offerId =
    //     ;

    UserModel userModel = userController.userModel!;

    return WillPopScope(
      onWillPop: () async {
        chatController.cleanController();

        // FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(userModel.userId)
        //     .update({
        //   'unread': false,
        // });

        return true;
      },
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        body: StreamBuilder<ChatModel>(
            initialData: widget.chatModel,
            stream: ChatController().getSingleChatStream(widget.chatModel.id),
            builder: (context, AsyncSnapshot<ChatModel> chatSnap) {
              if (!chatSnap.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              ChatModel chatModel = chatSnap.data ?? widget.chatModel;
              ChatController().updateChatTime(userModel, widget.chatModel);

              return SafeArea(
                  child: StreamBuilder<OffersModel>(
                      initialData: widget.offersModel,
                      stream: FirebaseFirestore.instance
                          .collection('offers')
                          .doc(widget.offersModel.offerId)
                          .snapshots()
                          .map((event) => OffersModel.fromJson(event)),
                      builder: (context, snapshot) {
                        OffersModel offersModel =
                            snapshot.data ?? widget.offersModel;
                        String vehicleId = offersModel.vehicleId;
                        return StreamBuilder<OffersReceivedModel>(
                            // s
                            stream: FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(chatModel.offerRequestId == ''
                                    ? 'null'
                                    : chatModel.offerRequestId)
                                .snapshots()
                                .map((convert) =>
                                    OffersReceivedModel.fromJson(convert)),
                            builder: (context, offerSnap) {
                              OffersReceivedModel? offersReceivedModel =
                                  offerSnap.data;
                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      TopBarMessage(
                                          chatController: chatController,
                                          userController: userController,
                                          widget: widget,
                                          userModel: userModel,
                                          secondUser: widget.secondUser),
                                      InkWell(
                                        onTap: () {
                                          if (userModel.userId ==
                                              offersModel.ownerId) {
                                            if (offersModel.status ==
                                                'active') {
                                              if (offersReceivedModel == null) {
                                                Get.to(() =>
                                                    OwnerActiveRequestDetails(
                                                        offersModel:
                                                            offersModel));
                                              } else {
                                                Get.to(() =>
                                                    OwnerRequestDetailsInprogressInactivePage(
                                                      offersModel: offersModel,
                                                      chatId:
                                                          widget.chatModel.id,
                                                      garageModel:
                                                          widget.garageModel,
                                                      offersReceivedModel:
                                                          offersReceivedModel,
                                                    ));
                                              }
                                            } else if (offersModel.status ==
                                                    'inProgress' ||
                                                offersModel.status ==
                                                    'inactive') {
                                              if (offersModel
                                                  .offersReceived.isNotEmpty) {
                                                Get.to(() =>
                                                    OwnerRequestDetailsInprogressInactivePage(
                                                      offersModel: offersModel,
                                                      chatId:
                                                          widget.chatModel.id,
                                                      garageModel:
                                                          widget.garageModel,
                                                      offersReceivedModel:
                                                          offersReceivedModel!,
                                                    ));
                                              } else {
                                                toastification.show(
                                                  context: context,
                                                  title: Text(
                                                      'This request was deleted.'),
                                                  autoCloseDuration:
                                                      const Duration(
                                                          seconds: 3),
                                                );
                                              }
                                            }
                                          } else {
                                            // if(){}
                                            if (offersModel.status ==
                                                    'active' &&
                                                offersReceivedModel == null) {
                                              Get.to(() =>
                                                  ServiceRequestDetails(
                                                    offersModel: offersModel,
                                                    chatId: chatModel.id,
                                                  ));
                                            } else {
                                              if (offersReceivedModel != null) {
                                                Get.to(() =>
                                                    ServiceRequestDetails(
                                                      offersModel: offersModel,
                                                      chatId: chatModel.id,
                                                      offersReceivedModel:
                                                          offersReceivedModel,
                                                    ));
                                              } else {
                                                toastification.show(
                                                  context: context,
                                                  title: Text(
                                                      'This request was deleted.'),
                                                  autoCloseDuration:
                                                      const Duration(
                                                          seconds: 3),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          margin: const EdgeInsets.all(0),
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, right: 12, top: 12),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(() =>
                                                            FullImagePageView(
                                                              urls: [
                                                                widget
                                                                    .garageModel
                                                                    .imageUrl
                                                              ],
                                                              currentIndex: 0,
                                                            ));
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        child:
                                                            CachedNetworkImage(
                                                          placeholder:
                                                              (context, url) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const SizedBox
                                                                  .shrink(),
                                                          imageUrl: widget
                                                              .garageModel
                                                              .imageUrl,
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            widget.garageModel
                                                                .title,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              // color: Colors.black,

                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 15,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                                  height: 25,
                                                                  width: 25),
                                                              const SizedBox(
                                                                width: 3,
                                                              ),
                                                              Text(
                                                                ' ',
                                                                style:
                                                                    TextStyle(
                                                                  // color: Colors.black,

                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              Text(
                                                                offersModel
                                                                    .issue,
                                                                style:
                                                                    TextStyle(
                                                                  // color: Colors.black,

                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                        onPressed: () async {
                                                          if (userModel
                                                                  .userId ==
                                                              offersModel
                                                                  .ownerId) {
                                                            if (offersModel
                                                                    .status ==
                                                                'active') {
                                                              if (offersReceivedModel ==
                                                                  null) {
                                                                Get.to(() =>
                                                                    OwnerActiveRequestDetails(
                                                                        offersModel:
                                                                            offersModel));
                                                              } else {
                                                                Get.to(() =>
                                                                    OwnerRequestDetailsInprogressInactivePage(
                                                                      offersModel:
                                                                          offersModel,
                                                                      chatId: widget
                                                                          .chatModel
                                                                          .id,
                                                                      garageModel:
                                                                          widget
                                                                              .garageModel,
                                                                      offersReceivedModel:
                                                                          offersReceivedModel,
                                                                    ));
                                                              }
                                                            } else if (offersModel
                                                                        .status ==
                                                                    'inProgress' ||
                                                                offersModel
                                                                        .status ==
                                                                    'inactive') {
                                                              if (offersModel
                                                                  .offersReceived
                                                                  .isNotEmpty) {
                                                                Get.to(() =>
                                                                    OwnerRequestDetailsInprogressInactivePage(
                                                                      offersModel:
                                                                          offersModel,
                                                                      chatId: widget
                                                                          .chatModel
                                                                          .id,
                                                                      garageModel:
                                                                          widget
                                                                              .garageModel,
                                                                      offersReceivedModel:
                                                                          offersReceivedModel!,
                                                                    ));
                                                              } else {
                                                                toastification
                                                                    .show(
                                                                  context:
                                                                      context,
                                                                  title: Text(
                                                                      'This request was deleted.'),
                                                                  autoCloseDuration:
                                                                      const Duration(
                                                                          seconds:
                                                                              3),
                                                                );
                                                              }
                                                            }
                                                          } else {
                                                            if (offersModel
                                                                .offersReceived
                                                                .isNotEmpty) {
                                                              Get.to(() =>
                                                                  ServiceRequestDetails(
                                                                    offersModel:
                                                                        offersModel,
                                                                    chatId:
                                                                        chatModel
                                                                            .id,
                                                                    offersReceivedModel:
                                                                        offersReceivedModel,
                                                                  ));
                                                            } else {
                                                              if (offersReceivedModel ==
                                                                  null) {
                                                                Get.to(() =>
                                                                    ServiceRequestDetails(
                                                                      offersModel:
                                                                          offersModel,
                                                                      chatId:
                                                                          chatModel
                                                                              .id,
                                                                      offersReceivedModel:
                                                                          offersReceivedModel,
                                                                    ));
                                                              } else {
                                                                toastification
                                                                    .show(
                                                                  context:
                                                                      context,
                                                                  title: Text(
                                                                      'This request was deleted.'),
                                                                  autoCloseDuration:
                                                                      const Duration(
                                                                          seconds:
                                                                              3),
                                                                );
                                                              }
                                                            }
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 22,
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: StreamBuilder<List<MessageModel>>(
                                        stream: ChatController()
                                            .paginatedMessageStream(
                                                userModel.userId,
                                                widget.chatModel.id,
                                                3),
                                        builder: (context,
                                            AsyncSnapshot<List<MessageModel>>
                                                snapshot) {
                                          Map<String, List<MessageModel>>
                                              groupedMessages = {};
                                          if (!snapshot.hasData) {
                                            return Text('');
                                          }
                                          for (MessageModel message
                                              in snapshot.data!) {
                                            String formattedDate =
                                                DateFormat('E, MMM d, yyyy')
                                                    .format(DateTime.parse(
                                                            message.sentAt)
                                                        .toLocal());

                                            if (!groupedMessages
                                                .containsKey(formattedDate)) {
                                              groupedMessages[formattedDate] =
                                                  [];
                                            }

                                            groupedMessages[formattedDate]!
                                                .add(message);
                                          }

                                          // if(snapshot)
                                          return ListView.builder(
                                              itemCount: groupedMessages.length,
                                              shrinkWrap: true,
                                              controller:
                                                  messageScrollController,
                                              reverse: true,
                                              itemBuilder:
                                                  (context, dateIndex) {
                                                String date = groupedMessages
                                                    .keys
                                                    .elementAt(dateIndex);
                                                List<MessageModel>
                                                    messagesForDate =
                                                    groupedMessages[date]!;
                                                // messagesLengthTotal = messagesForDate.length;

                                                return Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      date,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 15,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : changeColor(
                                                                color:
                                                                    '797979'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    ListView.builder(
                                                        itemCount:
                                                            messagesForDate
                                                                .length,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        reverse: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          MessageModel message =
                                                              messagesForDate[
                                                                  index];
                                                          if (message
                                                              .isSystemMessage) {
                                                            return systemMessage(
                                                                'Start the chat with',
                                                                widget
                                                                    .secondUser,
                                                                userModel);
                                                          }

                                                          if (message
                                                                  .sentById ==
                                                              userModel
                                                                  .userId) {
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                currentUserMessage(
                                                                    message,
                                                                    chatModel,
                                                                    widget
                                                                        .secondUser),
                                                              ],
                                                            );
                                                          } else {
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                secondUserMessage(
                                                                    message,
                                                                    widget
                                                                        .secondUser),
                                                              ],
                                                            );
                                                          }
                                                        }),
                                                  ],
                                                );
                                              });
                                        }),
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        // height: 50,
                                        width: Get.width,
                                        // color: Colors.green,

                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (chatController
                                                .pickedMedia.isNotEmpty)
                                              Container(
                                                height: 200,
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                  // color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: ListView.builder(
                                                  itemCount: chatController
                                                      .pickedMedia.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    MediaModel mediaModel =
                                                        chatController
                                                            .pickedMedia[index];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 7),
                                                      child: Stack(
                                                        children: [
                                                          if (mediaModel
                                                                  .isVideo ==
                                                              false)
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              child: Image.file(
                                                                mediaModel.file,
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 200,
                                                                width:
                                                                    Get.width *
                                                                        0.45,
                                                              ),
                                                            )
                                                          else
                                                            VideoPlayerLocal(
                                                                height: 200,
                                                                widht:
                                                                    Get.width *
                                                                        0.45,
                                                                file: mediaModel
                                                                    .file),

                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    chatController
                                                                        .removeMedia(
                                                                            mediaModel);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              200),
                                                                      color: userController
                                                                              .isDark
                                                                          ? Colors
                                                                              .white
                                                                          : primaryColor,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      // size: 90,
                                                                      color: userController
                                                                              .isDark
                                                                          ? primaryColor
                                                                          : Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (mediaModel
                                                              .uploading)
                                                            Positioned(
                                                              // alignment: Alignment.center,
                                                              right: 0,
                                                              left: 0,
                                                              bottom: 0,
                                                              // width: 40,
                                                              // height: 40,
                                                              top: 0,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                // color: Colors.white,
                                                                height: 40,
                                                                width: 40,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                          // Positioned(child: )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            if (chatController
                                                .pickedMedia.isNotEmpty)
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            if (chatModel.isClosed)
                                              Container(
                                                width: Get.width,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                // color: Colors.red,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                  color: userController.isDark
                                                      ? Colors.white
                                                          .withOpacity(0.4)
                                                      : primaryColor
                                                          .withOpacity(0.4),
                                                )),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      chatModel.closeReason,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Get.bottomSheet(
                                                              DeleteChatConfirmationSheet(
                                                                  chatId:
                                                                      chatModel
                                                                          .id));
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            minimumSize: Size(
                                                                Get.width * 0.6,
                                                                45),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6)),
                                                            backgroundColor:
                                                                userController
                                                                        .isDark
                                                                    ? Colors
                                                                        .white
                                                                    : primaryColor),
                                                        child: Text(
                                                          'Delete Chat',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: userController
                                                                    .isDark
                                                                ? primaryColor
                                                                : Colors.white,
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              )
                                            else
                                              Row(
                                                children: [
                                                  // if (chatController.pickedMedia.isEmpty)
                                                  IconButton(
                                                      onPressed: () async {
                                                        chatController
                                                            .pickMediaMessage(
                                                                userModel);
                                                      },
                                                      icon: Icon(
                                                          Icons.attach_file)),
                                                  Expanded(
                                                    child: CupertinoTextField(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      // autofocus: true,
                                                      onTapOutside: (s) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FocusNode());
                                                      },
                                                      onSubmitted: (s) {
                                                        if (checkBadWords(s)
                                                            .isNotEmpty) {
                                                          Get.showSnackbar(
                                                              GetSnackBar(
                                                            message:
                                                                'Vulgar language detected in your input. Please refrain from using inappropriate language.',
                                                            duration:
                                                                const Duration(
                                                                    seconds: 3),
                                                            snackPosition:
                                                                SnackPosition
                                                                    .TOP,
                                                          ));
                                                          return;
                                                        } else {
                                                          if (chatController
                                                              .pickedMedia
                                                              .isEmpty) {
                                                            if (s.isNotEmpty) {
                                                              // chatController.cleanController();
                                                              chatController.sendMessage(
                                                                  userModel,
                                                                  widget
                                                                      .chatModel,
                                                                  s.trim(),
                                                                  widget
                                                                      .secondUser,
                                                                  '',
                                                                  '',
                                                                  false,
                                                                  offersModel);

                                                              messageScrollController
                                                                  .jumpTo(0);
                                                              // MixpanelProvider().messageSentEvent(
                                                              //     senderUser: userModel,
                                                              //     receiverUser: secondUser!,
                                                              //     messageText: s.trim(),
                                                              //     totalMessages: messagesLengthTotal);
                                                              textMessageController
                                                                  .clear();
                                                            }
                                                          } else {
                                                            for (MediaModel element
                                                                in chatController
                                                                    .pickedMedia) {
                                                              chatController.sendMessage(
                                                                  userModel,
                                                                  widget
                                                                      .chatModel,
                                                                  s.trim(),
                                                                  widget
                                                                      .secondUser,
                                                                  element
                                                                      .uploadedUrl,
                                                                  element
                                                                      .thumbnailUrl,
                                                                  element
                                                                      .isVideo,
                                                                  offersModel);
                                                              messageScrollController
                                                                  .jumpTo(0);
                                                              chatController
                                                                  .removeMedia(
                                                                      element);
                                                              // MixpanelProvider().messageSentEvent(
                                                              //     senderUser: userModel,
                                                              //     receiverUser: secondUser!,
                                                              //     messageText: s.trim(),
                                                              //     totalMessages: messagesLengthTotal);
                                                              textMessageController
                                                                  .clear();
                                                            }
                                                          }
                                                        }
                                                      },
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      placeholder:
                                                          'Send a message',
                                                      // maxLength: 200,
                                                      // cou
                                                      style: TextStyle(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      controller:
                                                          textMessageController,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          border: Border.all(
                                                            color: changeColor(
                                                                color:
                                                                    'A9A9A9'),
                                                            width: 0.5,
                                                          )),
                                                    ),
                                                  ),
                                                  // const SizedBox(
                                                  //   width: 8,
                                                  // ),
                                                  // InkWell(
                                                  //   onTap: () {

                                                  //   },
                                                  //   child: Container(
                                                  //     height: 50,
                                                  //     width: 50,
                                                  //     decoration: BoxDecoration(
                                                  //       borderRadius: BorderRadius.circular(200),
                                                  //       color: Colors.white,
                                                  //     ),
                                                  //     child: ,
                                                  //   ),
                                                  // ),
                                                  if (chatController.pickedMedia
                                                          .isNotEmpty &&
                                                      chatController.pickedMedia
                                                              .firstWhereOrNull(
                                                                  (element) =>
                                                                      element
                                                                          .uploading ==
                                                                      true) !=
                                                          null)
                                                    InkWell(
                                                      // onTap: () {},
                                                      child: Container(
                                                        height: 30,
                                                        margin: const EdgeInsets
                                                            .all(6),
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: userController
                                                                  .isDark
                                                              ? Colors.white
                                                              : primaryColor,
                                                        ),
                                                        child:
                                                            CupertinoActivityIndicator(
                                                          color: userController
                                                                  .isDark
                                                              ? primaryColor
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    InkWell(
                                                        onTap: () {
                                                          if (chatController
                                                              .pickedMedia
                                                              .isEmpty) {
                                                            if (textMessageController
                                                                .text
                                                                .isNotEmpty) {
                                                              chatController.sendMessage(
                                                                  userModel,
                                                                  widget
                                                                      .chatModel,
                                                                  textMessageController
                                                                      .text
                                                                      .trim(),
                                                                  widget
                                                                      .secondUser,
                                                                  '',
                                                                  '',
                                                                  false,
                                                                  offersModel);

                                                              messageScrollController
                                                                  .jumpTo(0);
                                                              // MixpanelProvider().messageSentEvent(
                                                              //     senderUser: userModel,
                                                              //     receiverUser: secondUser!,
                                                              //     messageText: s.trim(),
                                                              //     totalMessages: messagesLengthTotal);
                                                              textMessageController
                                                                  .clear();

                                                              // chatController.cleanController();
                                                            }
                                                          } else {
                                                            List<MediaModel>
                                                                copiedList =
                                                                List.from(
                                                                    chatController
                                                                        .pickedMedia);
                                                            for (MediaModel element
                                                                in copiedList) {
                                                              chatController.sendMessage(
                                                                  userModel,
                                                                  widget
                                                                      .chatModel,
                                                                  textMessageController
                                                                      .text
                                                                      .trim(),
                                                                  widget
                                                                      .secondUser,
                                                                  element
                                                                      .uploadedUrl,
                                                                  element
                                                                      .thumbnailUrl,
                                                                  element
                                                                      .isVideo,
                                                                  offersModel);

                                                              messageScrollController
                                                                  .jumpTo(0);
                                                              chatController
                                                                  .removeMedia(
                                                                      element);
                                                              // MixpanelProvider().messageSentEvent(
                                                              //     senderUser: userModel,
                                                              //     receiverUser: secondUser!,
                                                              //     messageText: s.trim(),
                                                              //     totalMessages: messagesLengthTotal);
                                                              textMessageController
                                                                  .clear();
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: userController
                                                                      .isDark
                                                                  ? Colors.white
                                                                  : primaryColor),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Center(
                                                            child: Image.asset(
                                                              'assets/send.png',
                                                              height: 34,
                                                              width: 28,
                                                              color: userController
                                                                      .isDark
                                                                  ? primaryColor
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                          ),
                                                        ))
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      // if (chatModel!.offerRequestId != '' ||
                                      //     chatController.pickedMedia.isEmpty)
                                    ],
                                  )
                                ],
                              );
                            });
                      }));
            }),
      ),
    );
  }

  Widget currentUserMessage(
      MessageModel message, ChatModel chatModel, UserModel userModel) {
    List<InlineSpan> textSpans = _getClickableTextSpans(message.text);
    DateTime now = DateTime.parse(message.sentAt).toLocal();
    String formattedTime = DateFormat.jm().format(now);
    bool unreadMessage = DateTime.parse(message.sentAt)
            .toLocal()
            .difference(
                DateTime.parse(chatModel.lastOpen[userModel.userId]).toLocal())
            .inSeconds >
        0;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.75,
      ),
      child: Container(
          // margin: const EdgeInsets.all(7),
          padding: const EdgeInsets.only(
            right: 12,
            top: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // color: changeColor(color: '767AD8'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MessageWidget(
                textSpans: textSpans,
                message: message,
              ),
              const SizedBox(
                height: 5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      IndexedStack(
                        index: unreadMessage == false ? 1 : message.state,
                        children: [
                          Icon(
                            Icons.done,
                            size: 20,
                            color: unreadMessage
                                ? Colors.grey
                                : changeColor(color: '767AD8'),
                          ),
                          Icon(
                            Icons.done_all,
                            size: 20,
                            color: unreadMessage
                                ? Colors.grey
                                : changeColor(color: '767AD8'),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              )
            ],
          )),
    );
  }

  Widget secondUserMessage(MessageModel message, UserModel secondUser) {
    List<InlineSpan> textSpans = _getClickableTextSpans(message.text);
    DateTime now = DateTime.parse(message.sentAt).toLocal();
    String formattedTime = DateFormat.jm().format(now);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 8,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: CachedNetworkImage(
                placeholder: (context, url) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorWidget: (context, url, error) => const SizedBox.shrink(),
                imageUrl: secondUser.profileUrl,
                height: 22,
                width: 22,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SecondUserMessageWidget(
                  textSpans: textSpans,
                  message: message,
                ),
                const SizedBox(
                  height: 5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, left: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            formattedTime,
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _getClickableTextSpans(String message) {
    RegExp urlRegExp = RegExp(r'(https?:\/\/)?([\w\-]+\.)+[\w]{2,}(\/\S*)?');
    RegExp emailRegExp =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b');

    RegExp phoneRegExp = RegExp(
        r"\b(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})\b");

    List<InlineSpan> textSpans = [];
    int currentIndex = 0;

    Iterable<Match> urlMatches = urlRegExp.allMatches(message);
    Iterable<Match> phoneMatches = phoneRegExp.allMatches(message);
    Iterable<Match> emailMatches = emailRegExp.allMatches(message);

    // Combine URL and phone matches into a single iterable
    Iterable<Match> allMatches = [
      ...emailMatches,
      ...urlMatches,
      ...phoneMatches
    ];

    // Sort matches by their start position in the text
    List<Match> sortedMatches = allMatches.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    // Process the sorted matches
    for (Match match in sortedMatches) {
      if (match.start > currentIndex) {
        textSpans
            .add(TextSpan(text: message.substring(currentIndex, match.start)));
      }

      String matchText = match.group(0)!;

      // Check for URL match
      if (urlRegExp.hasMatch(matchText)) {
        textSpans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                String url = matchText.startsWith('http')
                    ? matchText
                    : 'http://$matchText';
                await launchUrlString(url);
              },
          ),
        );
      }
      // Check for phone number match
      else if (phoneRegExp.hasMatch(matchText)) {
        textSpans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                String telUrl = "tel:$matchText";
                await launchUrlString(telUrl);
              },
          ),
        );
      }
      // Check for email match
      else if (emailRegExp.hasMatch(matchText)) {
        textSpans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                String mailUrl = "mailto:$matchText";
                await launchUrlString(mailUrl);
              },
          ),
        );
      }

      currentIndex = match.end;
    }

    // Add any remaining text after the last match
    if (currentIndex < message.length) {
      textSpans.add(TextSpan(text: message.substring(currentIndex)));
    }

    return textSpans;
  }

  Widget systemMessage(
      String message, UserModel secondUser, UserModel userModel) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: changeColor(color: 'F1F1F1'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Avoid suspicious activity',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'If you see any links or messages that look unsual, don\'t click or respond to them. You can report them by contacting our Customer Service',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    // overflow: TextO,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () async {
              final Uri params = Uri(
                scheme: 'mailto',
                path: 'support@vehype.com',
                query: 'subject=VEHYPE Support - ${userModel.name}',
              );
              String url = params.toString();
              launchUrlString(url);
            },
            child: Text(
              'Report an issue',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                // overflow: TextO,
                fontStyle: FontStyle.normal,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SecondUserMessageWidget extends StatelessWidget {
  const SecondUserMessageWidget({
    super.key,
    required this.textSpans,
    required this.message,
  });

  final List<InlineSpan> textSpans;
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(
      //   left: 12,
      //   top: 12,
      // ),
      margin: const EdgeInsets.only(top: 12, left: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: changeColor(color: 'F1F1F1'),
      ),
      child: message.mediaUrl == ''
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.75,
              ),
              child: Container(
                // margin: const EdgeInsets.all(7),
                padding: const EdgeInsets.all(12),
                // width: Get.width * 0.75,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: changeColor(color: 'F1F1F1'),
                ),
                child: RichText(
                  text: TextSpan(
                    children: textSpans,
                    style: TextStyle(
                      // fontFamily: 'Avenir',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (message.isVideo)
                  InkWell(
                    onTap: () {
                      Get.to(() => VideoPlayerNetwork(url: message.mediaUrl));
                    },
                    child: SizedBox(
                      height: 200,
                      width: Get.width * 0.75,
                      child: Stack(
                        // fit: StackFit.expand,
                        children: [
                          SizedBox(
                            child: ClipRRect(
                              borderRadius: message.text != ''
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    )
                                  : BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const SizedBox.shrink(),
                                imageUrl: message.thumbnailUrl,
                                fit: BoxFit.cover,
                                height: 200,
                                width: Get.width * 0.75,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              // onTap: () {},
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  // size: 90,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      Get.to(() => FullImagePageView(urls: [message.mediaUrl]));
                    },
                    child: ClipRRect(
                      borderRadius: message.text != ''
                          ? BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            )
                          : BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const SizedBox.shrink(),
                        imageUrl: message.mediaUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: Get.width * 0.75,
                      ),
                    ),
                  ),
                // const SizedBox(
                //   height: 8,
                // ),
                if (message.text != '')
                  Container(
                    // margin: const EdgeInsets.all(7),
                    padding: const EdgeInsets.all(12),
                    width: Get.width * 0.75,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      color: changeColor(color: 'F1F1F1'),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: textSpans,
                        style: TextStyle(
                          // fontFamily: 'Avenir',
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
              ],
            ),
    );
  }
}

class TopBarMessage extends StatelessWidget {
  const TopBarMessage({
    super.key,
    required this.chatController,
    required this.userController,
    required this.widget,
    required this.userModel,
    required this.secondUser,
  });

  final ChatController chatController;
  final UserController userController;
  final MessagePage widget;
  final UserModel userModel;
  final UserModel secondUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () {
                  ChatController().updateChatTime(userModel, widget.chatModel);

                  chatController.cleanController();
                  // FirebaseFirestore.instance
                  //     .collection('users')
                  //     .doc(userModel.userId)
                  //     .update({
                  //   'unread': false,
                  // });
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                )),
            const SizedBox(
              width: 0,
            ),
            InkWell(
              onTap: () {
                ChatController().updateChatTime(userModel, widget.chatModel);

                Get.to(
                    () => SecondUserProfile(userId: widget.secondUser.userId));
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: CachedNetworkImage(
                      placeholder: (context, url) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                      imageUrl: secondUser.profileUrl,
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    secondUser.name,
                    style: TextStyle(
                      // color: Colors.black,
                      // fontFamily: 'Avenir',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
            onPressed: () {
              Get.bottomSheet(
                  BottomSheet(
                      onClosing: () {},
                      builder: (cc) {
                        return Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.close(1);
                                    Get.to(() => SecondUserProfile(
                                        userId: widget.secondUser.userId));
                                  },
                                  child: Text(
                                    'View Profile',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 17,
                                      // fontFamily: 'Avenir'/,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.close(1);

                                    Get.bottomSheet(
                                        reportBottomSheet(userModel, context));
                                  },
                                  child: Text(
                                    'Block & Report',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 17,
                                      // fontFamily: 'Avenir'/,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.close(1);
                                    Get.bottomSheet(DeleteChatConfirmationSheet(
                                        chatId: widget.chatModel.id));
                                  },
                                  child: Text(
                                    'Delete Chat',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 17,
                                      // fontFamily: 'Avenir'/,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  isScrollControlled: true);
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 24,
            ))
      ],
    );
  }

  reportBottomSheet(UserModel userModel, BuildContext context) {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    return Container(
      height: Get.height * 0.8,
      width: Get.width,
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'What’s wrong with this profile?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 1,
              width: Get.width * 0.8,
              color: changeColor(color: 'D9D9D9'),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Fake or Scam',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Fake or Scam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Harassment or Abuse',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Harassment or Abuse',
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 16,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Inappropriate Content',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Inappropriate Content',
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 16,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Fraudulent Activity',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Fraudulent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Violation of Terms',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Violation of Terms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Unprofessional Conduct',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Unprofessional Conduct',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
                Get.bottomSheet(ReportConfirmationSheet(
                    userController: userController,
                    reason: 'Spam or Unwanted Contact',
                    widget: widget));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                width: Get.width * 0.8,
                height: 50,
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    'Spam or Unwanted Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.textSpans,
    required this.message,
  });

  final List<InlineSpan> textSpans;
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Column(
      children: [
        message.mediaUrl == ''
            ? Container(
                // margin: const EdgeInsets.all(7),

                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: userController.isDark
                      ? changeColor(color: '#444655')
                      : primaryColor,
                ),
                child: RichText(
                  text: TextSpan(
                    children: textSpans,
                    style: TextStyle(
                      // fontFamily: 'Avenir',
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (message.isVideo)
                    InkWell(
                      onTap: () {
                        Get.to(() => VideoPlayerNetwork(url: message.mediaUrl));
                      },
                      child: SizedBox(
                        height: 200,
                        width: Get.width * 0.75,
                        child: Stack(
                          // fit: StackFit.expand,
                          children: [
                            SizedBox(
                              child: ClipRRect(
                                borderRadius: message.text != ''
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      )
                                    : BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      const SizedBox.shrink(),
                                  imageUrl: message.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: Get.width * 0.75,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                // onTap: () {},
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    // size: 90,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () {
                        Get.to(
                            () => FullImagePageView(urls: [message.mediaUrl]));
                      },
                      child: ClipRRect(
                        borderRadius: message.text != ''
                            ? BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              )
                            : BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                          imageUrl: message.mediaUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: Get.width * 0.75,
                        ),
                      ),
                    ),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  if (message.text != '')
                    Container(
                      // margin: const EdgeInsets.all(7),
                      padding: const EdgeInsets.all(12),
                      width: Get.width * 0.75,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        color: userController.isDark
                            ? changeColor(color: '#444655')
                            : primaryColor,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: textSpans,
                          style: TextStyle(
                            // fontFamily: 'Avenir',
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                ],
              ),
      ],
    );
  }
}
