// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import 'package:flutter/widgets.dart';
// import 'package:flutter_link_previewer/flutter_link_previewer.dart' as lnp;
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_select/image_selector.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/message_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/request_chat_details.dart';
import 'package:vehype/Pages/request_details_seeker_chat_page.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/Widgets/video_player.dart';
import 'package:vehype/bad_words.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';
import 'repair_page.dart';

class MessagePage extends StatefulWidget {
  final ChatModel chatModel;
  final UserModel secondUser;
  const MessagePage(
      {super.key, required this.chatModel, required this.secondUser});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController textMessageController = TextEditingController();
  ScrollController messageScrollController = ScrollController();

  // UserModel? secondUser;
  ChatModel? chatModel;
  int messagesLengthTotal = 0;
  bool loading = true;
  late StreamSubscription<ChatModel> subscription;
  @override
  void initState() {
    super.initState();
    // getSecondUserToken();
    getChatModel();
  }

  getChatModel() async {
    subscription = ChatController()
        .getSingleChatStream(widget.chatModel.id)
        .listen((event) {
      chatModel = event;
      setState(() {});
    });

    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    // String offerId =
    //     ;

    UserModel userModel = userController.userModel!;
    ChatController().updateChatTime(userModel, widget.chatModel);
  }

  // getSecondUserToken() async {
  //   final UserController userController =
  //       Provider.of<UserController>(context, listen: false);

  //   UserModel userModel = userController.userModel!;
  //   DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //       .instance
  //       .collection('users')
  //       .doc(widget.chatModel.members
  //           .firstWhere((element) => element != userModel.userId))
  //       .get();

  //   secondUser = UserModel.fromJson(snapshot);
  //   setState(() {
  //     loading = false;
  //   });
  // }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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
        ChatController().updateChatTime(userModel, widget.chatModel);

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
        body: SafeArea(
            child: Column(
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
                if (widget.chatModel.offerId != '')
                  StreamBuilder<OffersModel>(
                      stream: FirebaseFirestore.instance
                          .collection('offers')
                          .doc(chatModel == null
                              ? widget.chatModel.offerId
                              : chatModel!.offerId)
                          .snapshots()
                          .map((event) => OffersModel.fromJson(event)),
                      builder: (context, snapshot) {
                        // if(snapshot.)
                        if (snapshot.hasData && snapshot.data != null) {
                          OffersModel offersModel = snapshot.data!;
                          String title = offersModel.vehicleId != ''
                              ? '${offersModel.vehicleId.split(',')[1]} ${offersModel.vehicleId.split(',')[3]}'
                              : '';

                          return title == ''
                              ? SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(14),
                                      ),
                                      // border: Bord,
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (offersModel.imageOne != '')
                                            InkWell(
                                              onTap: () {
                                                Get.to(() => FullImagePageView(
                                                      urls: [
                                                        offersModel.imageOne
                                                      ],
                                                      currentIndex: 0,
                                                    ));
                                              },
                                              child: ExtendedImage.network(
                                                offersModel.imageOne,
                                                height: 65,
                                                width: 65,
                                                // fit: BoxFit.cover,
                                                cache: true,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title.trim(),
                                                style: TextStyle(
                                                  // color: Colors.black,
                                                  fontFamily: 'Avenir',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                      getServices()
                                                          .firstWhere(
                                                              (element) =>
                                                                  element
                                                                      .name ==
                                                                  offersModel
                                                                      .issues.first)
                                                          .image,
                                                      color:
                                                          userController.isDark
                                                              ? Colors.white
                                                              : primaryColor,
                                                      height: 25,
                                                      width: 25),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    'Issue: ',
                                                    style: TextStyle(
                                                      // color: Colors.black,
                                                      fontFamily: 'Avenir',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    offersModel.issues.first,
                                                    style: TextStyle(
                                                      // color: Colors.black,
                                                      fontFamily: 'Avenir',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              if (chatModel != null)
                                                StreamBuilder<
                                                        OffersReceivedModel>(
                                                    stream: userModel.userId ==
                                                            offersModel.ownerId
                                                        ? FirebaseFirestore.instance
                                                            .collection(
                                                                'offersReceived')
                                                            .where('ownerId',
                                                                isEqualTo: userModel
                                                                    .userId)
                                                            .where('offerId',
                                                                isEqualTo: offersModel
                                                                    .offerId)
                                                            .snapshots()
                                                            .map((event) =>
                                                                OffersReceivedModel.fromJson(event
                                                                    .docs
                                                                    .first))
                                                        : FirebaseFirestore.instance
                                                            .collection('offersReceived')
                                                            .where('offerBy', isEqualTo: userModel.userId)
                                                            .where('offerId', isEqualTo: offersModel.offerId)
                                                            .snapshots()
                                                            .map((event) => OffersReceivedModel.fromJson(event.docs.first)),
                                                    builder: (context, AsyncSnapshot<OffersReceivedModel> snapshot) {
                                                      if (snapshot.hasData ==
                                                          false) {
                                                        if (userModel.userId !=
                                                            offersModel
                                                                .ownerId) {
                                                          return ElevatedButton(
                                                              onPressed: () {
                                                                Get.to(
                                                                  () =>
                                                                      SelectDateAndPrice(
                                                                    offersModel:
                                                                        offersModel,
                                                                    chatId: widget
                                                                        .chatModel
                                                                        .id,
                                                                    ownerModel:
                                                                        widget
                                                                            .secondUser,
                                                                    offersReceivedModel:
                                                                        null,
                                                                  ),
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                minimumSize:
                                                                    Size(120,
                                                                        40),
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        28,
                                                                        131,
                                                                        31),
                                                              ),
                                                              child: Text(
                                                                'Send Offer',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                              ));
                                                        } else {
                                                          return Container();
                                                        }
                                                      }
                                                      OffersReceivedModel
                                                          offersReceivedModel =
                                                          snapshot.data!;
                                                      if (offersReceivedModel
                                                                  .ownerId ==
                                                              userModel
                                                                  .userId &&
                                                          offersReceivedModel
                                                                  .status ==
                                                              'Pending') {
                                                        return RequestDetailsButtonOwner(
                                                          widget: widget,
                                                          offersReceivedModel:
                                                              offersReceivedModel,
                                                          offersModel:
                                                              offersModel,
                                                          userModel: userModel,
                                                        );
                                                      } else if (offersReceivedModel
                                                              .status ==
                                                          'Pending') {
                                                        return RequestDetailsButtonProvider(
                                                          widget: widget,
                                                          offersReceivedModel:
                                                              offersReceivedModel,
                                                          offersModel:
                                                              offersModel,
                                                          userModel: userModel,
                                                        );
                                                      } else {
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                    })
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                        height: 1,
                                        width: Get.width,
                                      ),
                                    ],
                                  ),
                                );
                        }
                        return Container();
                      }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                  stream: ChatController().paginatedMessageStream(
                      userModel.userId, widget.chatModel.id, 3),
                  builder:
                      (context, AsyncSnapshot<List<MessageModel>> snapshot) {
                    Map<String, List<MessageModel>> groupedMessages = {};
                    if (!snapshot.hasData) {
                      return Text('');
                    }
                    for (MessageModel message in snapshot.data!) {
                      String formattedDate = DateFormat('E, MMM d, yyyy')
                          .format(DateTime.parse(message.sentAt).toLocal());

                      if (!groupedMessages.containsKey(formattedDate)) {
                        groupedMessages[formattedDate] = [];
                      }

                      groupedMessages[formattedDate]!.add(message);
                    }

                    // if(snapshot)
                    return ListView.builder(
                        itemCount: groupedMessages.length,
                        shrinkWrap: true,
                        controller: messageScrollController,
                        reverse: true,
                        itemBuilder: (context, dateIndex) {
                          String date =
                              groupedMessages.keys.elementAt(dateIndex);
                          List<MessageModel> messagesForDate =
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
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Avenir',
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: userController.isDark
                                      ? Colors.white
                                      : changeColor(color: '797979'),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                  itemCount: messagesForDate.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    MessageModel message =
                                        messagesForDate[index];
                                    if (message.isSystemMessage) {
                                      return systemMessage(
                                          'Start the chat with',
                                          widget.secondUser,
                                          userModel);
                                    }

                                    if (message.sentById == userModel.userId) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          currentUserMessage(
                                              message,
                                              chatModel == null
                                                  ? widget.chatModel
                                                  : chatModel!,
                                              widget.secondUser),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          secondUserMessage(
                                              message, widget.secondUser),
                                        ],
                                      );
                                    }
                                  }),
                            ],
                          );
                        });
                  }),
            ),
            Container(
              // height: 50,
              width: Get.width,
              // color: Colors.green,

              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chatController.pickedMedia.isNotEmpty)
                    Container(
                      height: 200,
                      width: Get.width,
                      decoration: BoxDecoration(
                        // color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: chatController.pickedMedia.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          MediaModel mediaModel =
                              chatController.pickedMedia[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: Stack(
                              children: [
                                if (mediaModel.isVideo == false)
                                  ExtendedImage.file(
                                    mediaModel.file,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(12),
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: Get.width * 0.45,
                                  )
                                else
                                  VideoPlayerLocal(
                                      height: 200,
                                      widht: Get.width * 0.45,
                                      file: mediaModel.file),

                                Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          chatController
                                              .removeMedia(mediaModel);
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            // size: 90,
                                            color: userController.isDark
                                                ? primaryColor
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (mediaModel.uploading)
                                  Positioned(
                                    // alignment: Alignment.center,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    // width: 40,
                                    // height: 40,
                                    top: 0,
                                    child: Container(
                                      alignment: Alignment.center,
                                      // color: Colors.white,
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                // Positioned(child: )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (chatController.pickedMedia.isNotEmpty)
                    const SizedBox(
                      height: 5,
                    ),
                  Row(
                    children: [
                      // if (chatController.pickedMedia.isEmpty)
                      IconButton(
                          onPressed: () async {
                            chatController.pickMediaMessage(userModel);
                          },
                          icon: Icon(Icons.attach_file)),
                      Expanded(
                        child: CupertinoTextField(
                          padding: const EdgeInsets.all(15),
                          // autofocus: true,
                          onTapOutside: (s) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          onSubmitted: (s) {
                            if (checkBadWords(s).isNotEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message:
                                    'Vulgar language detected in your input. Please refrain from using inappropriate language.',
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            } else {
                              if (chatController.pickedMedia.isEmpty) {
                                if (s.isNotEmpty) {
                                  // chatController.cleanController();
                                  chatController.sendMessage(
                                      userModel,
                                      widget.chatModel,
                                      s.trim(),
                                      widget.secondUser,
                                      '',
                                      '',
                                      false);

                                  messageScrollController.jumpTo(0);
                                  // MixpanelProvider().messageSentEvent(
                                  //     senderUser: userModel,
                                  //     receiverUser: secondUser!,
                                  //     messageText: s.trim(),
                                  //     totalMessages: messagesLengthTotal);
                                  textMessageController.clear();
                                }
                              } else {
                                for (MediaModel element
                                    in chatController.pickedMedia) {
                                  chatController.sendMessage(
                                      userModel,
                                      widget.chatModel,
                                      s.trim(),
                                      widget.secondUser,
                                      element.uploadedUrl,
                                      element.thumbnailUrl,
                                      element.isVideo);
                                  messageScrollController.jumpTo(0);
                                  chatController.removeMedia(element);
                                  // MixpanelProvider().messageSentEvent(
                                  //     senderUser: userModel,
                                  //     receiverUser: secondUser!,
                                  //     messageText: s.trim(),
                                  //     totalMessages: messagesLengthTotal);
                                  textMessageController.clear();
                                }
                              }
                            }
                          },
                          textCapitalization: TextCapitalization.sentences,
                          placeholder: 'Send a message',
                          // maxLength: 200,
                          // cou
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          controller: textMessageController,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(46),
                              border: Border.all(
                                color: changeColor(color: 'A9A9A9'),
                                width: 2,
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
                      if (chatController.pickedMedia.isNotEmpty &&
                          chatController.pickedMedia.firstWhereOrNull(
                                  (element) => element.uploading == true) !=
                              null)
                        InkWell(
                          // onTap: () {},
                          child: Container(
                            height: 30,
                            margin: const EdgeInsets.all(6),
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                            child: CupertinoActivityIndicator(
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        )
                      else
                        IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              if (checkBadWords(textMessageController.text)
                                  .isNotEmpty) {
                                Get.showSnackbar(GetSnackBar(
                                  message:
                                      'Vulgar language detected in your input. Please refrain from using inappropriate language.',
                                  duration: const Duration(seconds: 3),
                                  snackPosition: SnackPosition.TOP,
                                ));
                                return;
                              }
                              if (chatController.pickedMedia.isEmpty) {
                                if (textMessageController.text.isNotEmpty) {
                                  chatController.sendMessage(
                                      userModel,
                                      widget.chatModel,
                                      textMessageController.text.trim(),
                                      widget.secondUser,
                                      '',
                                      '',
                                      false);

                                  messageScrollController.jumpTo(0);
                                  // MixpanelProvider().messageSentEvent(
                                  //     senderUser: userModel,
                                  //     receiverUser: secondUser!,
                                  //     messageText: s.trim(),
                                  //     totalMessages: messagesLengthTotal);
                                  textMessageController.clear();

                                  // chatController.cleanController();
                                }
                              } else {
                                List<MediaModel> copiedList =
                                    List.from(chatController.pickedMedia);
                                for (MediaModel element in copiedList) {
                                  chatController.sendMessage(
                                      userModel,
                                      widget.chatModel,
                                      textMessageController.text.trim(),
                                      widget.secondUser,
                                      element.uploadedUrl,
                                      element.thumbnailUrl,
                                      element.isVideo);

                                  messageScrollController.jumpTo(0);
                                  chatController.removeMedia(element);
                                  // MixpanelProvider().messageSentEvent(
                                  //     senderUser: userModel,
                                  //     receiverUser: secondUser!,
                                  //     messageText: s.trim(),
                                  //     totalMessages: messagesLengthTotal);
                                  textMessageController.clear();
                                }
                              }
                            },
                            icon: Image.asset(
                              'assets/send.png',
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ))
                    ],
                  ),
                ],
              ),
            )
          ],
        )),
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
              child: ExtendedImage.network(
                secondUser.profileUrl,
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
    RegExp urlRegExp = RegExp(r'https?://\S+');
    RegExp phoneRegExp = RegExp(
        r"\b(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})\b");

    List<InlineSpan> textSpans = [];
    int currentIndex = 0;

    Iterable<Match> urlMatches = urlRegExp.allMatches(message);
    Iterable<Match> phoneMatches = phoneRegExp.allMatches(message);

    // Combine URL and phone matches into a single iterable
    Iterable<Match> allMatches = [...urlMatches, ...phoneMatches];

    // Sort matches by their start position in the text
    List<Match> sortedMatches = allMatches.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    for (Match match in sortedMatches) {
      if (match.start > currentIndex) {
        textSpans
            .add(TextSpan(text: message.substring(currentIndex, match.start)));
      }

      String matchText = match.group(0)!;
      if (urlRegExp.hasMatch(matchText)) {
        textSpans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await launchUrl(Uri.parse(matchText));
              },
          ),
        );
      } else if (phoneRegExp.hasMatch(matchText)) {
        textSpans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await launchUrl(Uri.parse("tel:$matchText"));
              },
          ),
        );
      }

      currentIndex = match.end;
    }

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
              fontFamily: 'Avenir',
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
                    fontFamily: 'Avenir',
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
                path: 'recipient@example.com',
                query: 'subject=VEHYPE Support - ${userModel.name}',
              );
              String url = params.toString();
              launchUrlString(url);
            },
            child: Text(
              'Report an issue',
              style: const TextStyle(
                fontFamily: 'Avenir',
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w400,
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

class RequestDetailsButtonOwner extends StatelessWidget {
  const RequestDetailsButtonOwner({
    super.key,
    required this.widget,
    required this.offersModel,
    required this.userModel,
    required this.offersReceivedModel,
  });

  final MessagePage widget;
  final OffersModel offersModel;

  final UserModel userModel;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Get.dialog(AcceptOfferConfirm(
          offersModel: offersModel,
          offersReceivedModel: offersReceivedModel,
        ));
        // Get.dialog(LoadingDialog(), barrierDismissible: false);
        // await FirebaseFirestore.instance
        //     .collection('offersReceived')
        //     .doc(offersReceivedModel.id)
        //     .update({
        //   'status': 'Upcoming',
        // });
        // await FirebaseFirestore.instance
        //     .collection('offers')
        //     .doc(offersModel.offerId)
        //     .update({
        //   'status': 'inProgress',
        // });
        // sendNotification(
        //     offersReceivedModel.offerBy,
        //     userModel.name,
        //     'Offer Update',
        //     '${userModel.name}, Accepted the offer',
        //     offersReceivedModel.id,
        //     'Offer',
        //     '');
        // Get.close(1);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.withOpacity(0.2),
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          )),
      child: Text(
        'Accept Offer',
        style: TextStyle(
          color: Colors.green,
          fontSize: 14,
        ),
      ),
    );
  }
}

class AcceptOfferConfirm extends StatelessWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;

  const AcceptOfferConfirm(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    UserModel userModel = userController.userModel!;
    return Dialog(
      // insetPadding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                'Confirm Offer Acceptance',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OfferRequestDetails(
                          userController: userController,
                          offersReceivedModel: offersReceivedModel),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.close(1);
                      },
                      child: Text('Cancel'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    TextButton(
                      onPressed: () async {
                        // Get.dialog(AcceptOfferConfirm());
                        Get.dialog(LoadingDialog(), barrierDismissible: false);
                        await FirebaseFirestore.instance
                            .collection('offersReceived')
                            .doc(offersReceivedModel.id)
                            .update({
                          'status': 'Upcoming',
                        });
                        await FirebaseFirestore.instance
                            .collection('offers')
                            .doc(offersModel.offerId)
                            .update({
                          'status': 'inProgress',
                        });
                        UserController().addToNotifications(
                            userModel,
                            offersReceivedModel.offerBy,
                            'offer',
                            offersReceivedModel.id,
                            'Offer Update',
                            '${userModel.name}, Accepted your offer');
                        sendNotification(
                            offersReceivedModel.offerBy,
                            userModel.name,
                            'Offer Update',
                            '${userModel.name}, Accepted your offer',
                            offersReceivedModel.id,
                            'offer',
                            '');
                        Get.close(1);
                        Get.close(1);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          )),
                      child: Text(
                        'Accept Offer',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'You can review our rating policy here.',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse('https://vehype.com/help#'));
                },
                child: Text(
                  'Rating Policy',
                  style: TextStyle(
                      color: Colors.red, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestDetailsButtonProvider extends StatelessWidget {
  const RequestDetailsButtonProvider({
    super.key,
    required this.widget,
    required this.offersModel,
    required this.userModel,
    required this.offersReceivedModel,
  });

  final MessagePage widget;
  final OffersModel offersModel;

  final UserModel userModel;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    return offersModel.ownerId != userModel.userId
        ? TextButton(
            onPressed: () {
              Get.to(
                () => SelectDateAndPrice(
                  offersModel: offersModel,
                  ownerModel: userModel,
                  offersReceivedModel: offersReceivedModel,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.2),
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                )),
            child: Text(
              'Update Offer',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          )
        : TextButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.2),
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                )),
            child: Text(
              'Request Details',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
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
        borderRadius: BorderRadius.circular(14),
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
                  borderRadius: BorderRadius.circular(14),
                  color: changeColor(color: 'F1F1F1'),
                ),
                child: RichText(
                  text: TextSpan(
                    children: textSpans,
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      color: Colors.black,
                      fontSize: 17,
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
                    child: Container(
                      height: 200,
                      width: Get.width * 0.75,
                      child: Stack(
                        // fit: StackFit.expand,
                        children: [
                          SizedBox(
                            child: ExtendedImage.network(
                              message.thumbnailUrl,
                              shape: BoxShape.rectangle,
                              borderRadius: message.text != ''
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                    )
                                  : BorderRadius.circular(14),
                              fit: BoxFit.cover,
                              height: 200,
                              width: Get.width * 0.75,
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
                    child: ExtendedImage.network(
                      message.mediaUrl,
                      shape: BoxShape.rectangle,
                      borderRadius: message.text != ''
                          ? BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            )
                          : BorderRadius.circular(14),
                      fit: BoxFit.cover,
                      height: 200,
                      width: Get.width * 0.75,
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
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      color: changeColor(color: 'F1F1F1'),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: textSpans,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          color: Colors.black,
                          fontSize: 17,
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
              width: 10,
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
                    child: ExtendedImage.network(
                      secondUser.profileUrl,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    secondUser.name,
                    style: TextStyle(
                      // color: Colors.black,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
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
                                        userId: userModel.userId));
                                  },
                                  child: Text(
                                    'View Profile',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 22,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.close(1);

                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        builder: (context) {
                                          return reportBottomSheet(
                                            userModel,
                                          );
                                        });
                                  },
                                  child: Text(
                                    'Block & Report',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 22,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.close(1);
                                    showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        context: context,
                                        backgroundColor: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        builder: (context) {
                                          return BottomSheet(
                                              onClosing: () {},
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              builder: (s) {
                                                return Container(
                                                  width: Get.width,
                                                  decoration: BoxDecoration(
                                                    color: userController.isDark
                                                        ? primaryColor
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          'Are you sure? You won\'t be able to contact each other anymore',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Avenir',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            Get.close(1);
                                                            Get.close(1);

                                                            chatController
                                                                .deleteChat(widget
                                                                    .chatModel
                                                                    .id);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            elevation: 1.0,
                                                            maximumSize: Size(
                                                                Get.width * 0.6,
                                                                50),
                                                            minimumSize: Size(
                                                                Get.width * 0.6,
                                                                50),
                                                          ),
                                                          child: Text(
                                                            'Confirm',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Get.close(1);
                                                          },
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Avenir',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        });
                                  },
                                  child: Text(
                                    'Delete Chat',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w500,
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
              Icons.more_horiz_outlined,
              size: 24,
            ))
      ],
    );
  }

  reportBottomSheet(UserModel userModel) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        builder: (context) {
          return Container(
            // height: Get.height * 0.,
            width: Get.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'What’s wrong with this\nprofile?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: changeColor(color: '888888'),
                        fontSize: 22,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
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
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          builder: (context) {
                            return BottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onClosing: () {},
                                builder: (contexr) {
                                  return Container(
                                    // height: Get.height * 0.25,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Are you sure? You won\'t be able to contact each other anymore',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.close(1);
                                              Get.close(1);
                                              userController.blockAndReport(
                                                  widget.chatModel.id,
                                                  userModel.userId,
                                                  widget.secondUser.userId,
                                                  widget.secondUser,
                                                  'Distasteful');
                                              Get.to(
                                                  () => ReportConfirmation());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              elevation: 1.0,
                                              maximumSize:
                                                  Size(Get.width * 0.6, 50),
                                              minimumSize:
                                                  Size(Get.width * 0.6, 50),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.close(1);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
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
                                });
                          });
                    },
                    child: Text(
                      'Distasteful',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.close(1);
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          builder: (context) {
                            return BottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onClosing: () {},
                                builder: (c) {
                                  return Container(
                                    // height: 260,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Are you sure? You won\'t be able to contact each other anymore',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.close(1);
                                              Get.close(1);
                                              userController.blockAndReport(
                                                  widget.chatModel.id,
                                                  userModel.userId,
                                                  widget.secondUser.userId,
                                                  widget.secondUser,
                                                  'Fake or Scam');
                                              Get.to(
                                                  () => ReportConfirmation());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              maximumSize:
                                                  Size(Get.width * 0.6, 50),
                                              minimumSize:
                                                  Size(Get.width * 0.6, 50),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.close(1);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
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
                                });
                          });
                    },
                    child: Text(
                      'Fake or Scam',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.close(1);
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          context: context,
                          builder: (context) {
                            return BottomSheet(
                                onClosing: () {},
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Are you sure? You won\'t be able to contact each other anymore',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.close(1);
                                              Get.close(1);
                                              userController.blockAndReport(
                                                  widget.chatModel.id,
                                                  userModel.userId,
                                                  widget.secondUser.userId,
                                                  widget.secondUser,
                                                  'Other');
                                              Get.to(
                                                  () => ReportConfirmation());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              elevation: 1.0,
                                              maximumSize:
                                                  Size(Get.width * 0.6, 50),
                                              minimumSize:
                                                  Size(Get.width * 0.6, 50),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.close(1);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
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
                                });
                          });
                    },
                    child: Text(
                      'Other',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.close(1);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
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
        });
  }
}

class ReportConfirmation extends StatefulWidget {
  const ReportConfirmation({super.key});

  @override
  State<ReportConfirmation> createState() => _ReportConfirmationState();
}

class _ReportConfirmationState extends State<ReportConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: Get.height,
        width: Get.width,
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [],
              ),
              SizedBox(
                width: Get.width * 0.65,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thanks for keeping our community safe.',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Avenir',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'We’ll investigate this profile.',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Avenir',
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // UserController().addPushToken(userModel.id);
                        Get.close(1);
                        // Get.to(() => AddProfileImagesPage());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          maximumSize: Size(Get.width * 0.8, 60),
                          minimumSize: Size(Get.width * 0.8, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          )),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ],
          ),
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
    return Column(
      children: [
        message.mediaUrl == ''
            ? Container(
                // margin: const EdgeInsets.all(7),

                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: changeColor(color: '767AD8'),
                ),
                child: RichText(
                  text: TextSpan(
                    children: textSpans,
                    style: TextStyle(
                      fontFamily: 'Avenir',
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
                      child: Container(
                        height: 200,
                        width: Get.width * 0.75,
                        child: Stack(
                          // fit: StackFit.expand,
                          children: [
                            SizedBox(
                              child: ExtendedImage.network(
                                message.thumbnailUrl,
                                shape: BoxShape.rectangle,
                                borderRadius: message.text != ''
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(14),
                                      )
                                    : BorderRadius.circular(14),
                                fit: BoxFit.cover,
                                height: 200,
                                width: Get.width * 0.75,
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
                      child: ExtendedImage.network(
                        message.mediaUrl,
                        shape: BoxShape.rectangle,
                        borderRadius: message.text != ''
                            ? BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              )
                            : BorderRadius.circular(14),
                        fit: BoxFit.cover,
                        height: 200,
                        width: Get.width * 0.75,
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
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        color: changeColor(color: '767AD8'),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: textSpans,
                          style: TextStyle(
                            fontFamily: 'Avenir',
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
