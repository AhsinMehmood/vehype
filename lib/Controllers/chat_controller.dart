// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/notification_controller.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/message_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
// import 'package:vehype/Pages/offers_received_details.dart';
import 'package:path/path.dart' as p;
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:video_compress/video_compress.dart';
// import 'package:';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'user_controller.dart';

class ChatController with ChangeNotifier {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages');
  updateChatRequestId(String chatId, String offerId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'offerRequestId': offerId,
    });
  }

  Future updateChatToClose(
    String chatId,
    String closeReason,
  ) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'isClosed': true,
      'closeReason': closeReason,
    });
  }

  Future<String> createChat(
      UserModel currentUser,
      UserModel secondUser,
      String offerRequestId,
      OffersModel offersModel,
      String notificationTitle,
      String notificationSubtitle,
      String type) async {
    DocumentReference<Map<String, dynamic>> reference =
        await FirebaseFirestore.instance.collection('chats').add({
      'members': [
        currentUser.userId,
        secondUser.userId,
    ],
      'lastOpen': {
        currentUser.userId: DateTime.now().toUtc().toIso8601String(),
        secondUser.userId: DateTime.now().toUtc().toIso8601String()
      },
      'offerId': offersModel.offerId,
      'offerRequestId': offerRequestId,
      'lastMessageMe': currentUser.userId,
      'lastMessageAt': DateTime.now().toUtc().toIso8601String(),
      'text': 'Start the chat with',
    });

    await _messagesRef.child(reference.id).child('systemMessage').set({
      'sentAt': DateTime.now().toUtc().toIso8601String(),
      'sentById': currentUser.userId,
      'isSystemMessage': true,
      'text': 'Start the chat with',
      'pushToken': secondUser.pushToken,
      'senderName': currentUser.name,
      'chatId': currentUser.userId + secondUser.userId + offersModel.offerId,
      'state': 0,
    });

    return reference.id;
  }

  Future<ChatModel?> getChat(
      String currentUserId, String secondUserId, String offerId) async {
    // print(secondUser.id);
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('chats')
          .where('members', arrayContains: currentUserId)
          .where('offerId', isEqualTo: offerId)
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      } else {
        List<ChatModel> chats = [];
        for (var element in snapshot.docs) {
          chats.add(ChatModel.fromJson(element));
        }

        ChatModel? chatModel = chats.firstWhereOrNull(
            (element) => element.members.contains(secondUserId));
        return chatModel;
      }
    } catch (e) {
      return null;
    }
  }

  Stream<ChatModel> getSingleChatStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((event) => ChatModel.fromJson(event));
  }

  Future<ChatModel?> getSingleChat(String chatId) async {
    return await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get()
        .then((event) => ChatModel.fromJson(event));
  }

  String? lastMessageKey;
  Stream<List<MessageModel>> paginatedMessageStream(
    String userId,
    String chatId,
    int limit,
  ) {
    StreamController<List<MessageModel>> streamController =
        StreamController<List<MessageModel>>();

    var query = _messagesRef.child(chatId).orderByChild('sentAt');

    query.onValue.listen((event) {
      if (event.snapshot.value == null) {
        streamController.add(<MessageModel>[]);
        // print('sdkss;d');
        return;
      }

      final Map<dynamic, dynamic> messageData =
          event.snapshot.value as Map<dynamic, dynamic>;
      final List<MessageModel> messages = [];

      messageData.forEach((key, data) {
        // print(data);

        final message = MessageModel(
          isSystemMessage: data['isSystemMessage'] ?? false,
          isLocation: data['isLocation'] ?? false,
          lat: data['lat'] ?? 0.0,
          long: data['long'] ?? 0.0,
          isAudio: data['isAudio'] ?? false,
          audioUrl: data['audioUrl'] ?? '',
          id: key,
          sentAt: data['sentAt'] ?? '',
          sentById: data['sentById'] ?? '',
          text: data['text'] ?? "",
          thumbnailUrl: data['thumbnailUrl'] ?? '',
          mediaUrl: data['mediaUrl'] ?? '',
          isVideo: data['isVideo'] ?? false,
          state: data['state'] ?? 1,
        );
        messages.add(message);
        // print(message);
      });
      messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));

      streamController.add(messages);
    }, onError: (error) {
      print(error);
    });

    return streamController.stream;
  }

  getUnread(String sentAt, String lastOpen, BuildContext context) {
    bool unreadMessage = DateTime.parse(sentAt)
            .toLocal()
            .difference(DateTime.parse(lastOpen).toLocal())
            .inSeconds >
        0;
    Provider.of<UserController>(context, listen: false)
        .changeRead(unreadMessage);

    // return unreadMessage;
  }

  Stream<List<ChatModel>> chatsStream(
    String userId,
    BuildContext context,
  ) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      // print(chatsData.values.first['messages']);
      List<ChatModel> chats = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> element
          in querySnapshot.docs) {
        chats.add(ChatModel.fromJson(element));
      }
      chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      // for (var element in chats) {
      //   getUnread(element.lastMessageAt, element.lastOpen[userId], context);
      // }
      return chats;
    }).handleError((errors) {});
  }

  List<MediaModel> pickedMedia = [];
  bool uploading = false;
  bool isVideo = false;

  bool isImageOrVideo(String? filePath) {
    if (filePath == null) {
      return false;
    }

    String extension = p.extension(filePath).toLowerCase();

    List<String> imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp'];
    List<String> videoExtensions = ['.mp4', '.avi', '.mov', '.mkv', '.wmv'];
    if (imageExtensions.contains(extension)) {
      return false;
    }
    return videoExtensions.contains(extension);
  }

  String mediaUrl = '';
  String thumnailUrlCr = '';
  cleanController() {
    pickedMedia = [];
    uploading = false;
    isVideo = false;
    mediaUrl = '';
    thumnailUrlCr = '';
    notifyListeners();
  }

  pickMediaMessage(UserModel userModel) async {
    isVideo = false;
    notifyListeners();
    final ImagePicker picker = ImagePicker();

    // final XFile? media = await picker.pickMedia();
    List<XFile> medias = await picker.pickMultipleMedia(
      imageQuality: 50,
    );
    if (medias.isNotEmpty) {
      for (var i = 0; i < medias.length; i++) {
        XFile element = medias[i];
        pickedMedia.add(MediaModel(
            uploading: true,
            id: i,
            thumbnailUrl: '',
            uploadedUrl: '',
            isVideo: isImageOrVideo(element.path),
            file: File(element.path)));
        notifyListeners();
      }

      for (var i = 0; i < pickedMedia.length; i++) {
        MediaModel mediaModel = pickedMedia[i];

        if (isImageOrVideo(mediaModel.file.path)) {
          MediaInfo? mediaInfo = await VideoCompress.compressVideo(
            mediaModel.file.path,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false, // It's false by default
          );
          String url = await uploadMedia(mediaInfo!.file!, userModel.userId);

          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath = tempDir.path;

          final String thumbnailPath =
              '$tempPath/${DateTime.now().microsecondsSinceEpoch}.png';

          // Generate thumbnail
          await FFmpegKit.execute(
              '-i ${mediaModel.file.path} -ss 00:00:01.000 -vframes 1 $thumbnailPath');

          String thumnailUrl =
              await uploadMedia(File(thumbnailPath), userModel.userId);

          pickedMedia.removeAt(i);
          pickedMedia.insert(
              i,
              MediaModel(
                  id: i,
                  thumbnailUrl: thumnailUrl,
                  uploading: false,
                  uploadedUrl: url,
                  isVideo: true,
                  file: mediaModel.file));

          notifyListeners();
        } else {
          String url =
              await uploadMedia(File(mediaModel.file.path), userModel.userId);
          pickedMedia.removeAt(i);
          pickedMedia.insert(
              i,
              MediaModel(
                  id: i,
                  thumbnailUrl: '',
                  uploading: false,
                  uploadedUrl: url,
                  isVideo: false,
                  file: mediaModel.file));
          notifyListeners();
        }
      }
    }
  }

  removeMedia(MediaModel mediaModel) {
    pickedMedia.remove(mediaModel);
    notifyListeners();
  }

  Future<String> uploadMedia(File file, String userId) async {
    final storageRef = FirebaseStorage.instance.ref();
    final extension = p.extension(file.path); // '.dart'
    final poiImageRef = storageRef.child(
        "users/$userId/${DateTime.now().microsecondsSinceEpoch}$extension");
    await poiImageRef.putData(file.readAsBytesSync());
    // uploadTaskOne!.
    String imageUrl = await poiImageRef.getDownloadURL();

    // uploading = false;
    // notifyListeners();
    return imageUrl;
  }

  updateChatTime(
    UserModel currentUser,
    ChatModel chatModel,
  ) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatModel.id)
        .update({
      'lastOpen.${currentUser.userId}':
          DateTime.now().toUtc().toIso8601String(),
    });
  }

  sendMessage(
      UserModel currentUser,
      ChatModel chatModel,
      String message,
      UserModel secondUser,
      String mediaUrls,
      String thumbnailUrl,
      bool isVide,
      OffersModel offersModel,
      bool isAudio,
      String audioUrl,
      {LatLng? latlng,
      bool isLocation = false}) async {
    DatabaseReference reference = _messagesRef.child(chatModel.id).push();
    await reference.set({
      'sentAt': DateTime.now().toUtc().toIso8601String(),
      'sentById': currentUser.userId,
      'isAudio': isAudio,
      'audioUrl': audioUrl,
      'text': message,
      'mediaUrl': mediaUrls,
      'isVideo': isVide,
      'thumbnailUrl': thumbnailUrl,
      'senderName': currentUser.name,
      'pushToken': secondUser.pushToken,
      'chatId': chatModel.id,
      'state': 0,
      'isLocation': isLocation,
      'lat': latlng != null ? latlng.latitude : 0.2,
      'long': latlng != null ? latlng.longitude : 0.2,
    });

    NotificationController().sendMessageNotification(
        senderUser: secondUser,
        receiverUser: currentUser,
        offersModel: offersModel,
        chatId: chatModel.id,
        messageId: reference.key!);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatModel.id)
        .update({
      'lastMessageAt': DateTime.now().toUtc().toIso8601String(),
      'text': message,
      'lastMessageMe': currentUser.userId,
    });
  }

  Dio dio = Dio();

  Future<File?> saveVideoAndGetFile(String videoUrl) async {
    String fileName = videoUrl.split('/').last;

    try {
      String savePath = Platform.isIOS
          ? '${(await getApplicationDocumentsDirectory()).path}/$fileName'
          : '${(await getApplicationDocumentsDirectory()).path}/$fileName';

      File file = File.fromUri(Uri.parse(savePath));
      if (await file.exists()) {
        return file;
      } else {
        await dio.download(videoUrl, savePath);

        file = File.fromUri(Uri.parse(savePath));
        return file;
      }
    } catch (exception) {
      // await Sentry.captureException(
      //   exception,
      //   stackTrace: stackTrace,
      // );
      return null;
    }
  }

  deleteChat(String chatId) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
    Get.close(1);
  }

  updateMessage(String chatId, String messageId, int state) async {
    await _messagesRef.child(chatId).child(messageId).update({
      'state': 1,
    });
  }
}

class MediaModel {
  final bool uploading;
  final String uploadedUrl;
  final bool isVideo;
  final File file;
  final int id;
  final String thumbnailUrl;

  MediaModel(
      {required this.id,
      required this.thumbnailUrl,
      required this.uploading,
      required this.uploadedUrl,
      required this.isVideo,
      required this.file});
}
