import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/const.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Controllers/user_controller.dart';

class CommentsPage extends StatelessWidget {
  final UserModel data;
  const CommentsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Reviews And Ratings',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView.builder(
          itemCount: data.ratings.length,
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          itemBuilder: (context, inde) {
            print(data.ratings[inde]['id']);
            return StreamBuilder<UserModel>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data.ratings[inde]['id'])
                    .snapshots()
                    .map((event) => UserModel.fromJson(event)),
                builder: (context, AsyncSnapshot<UserModel> snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                    );
                  }
                  UserModel commenterData = snapshot.data!;
                  return Card(
                    color: userController.isDark
                        ? Colors.blueGrey.shade700
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: ExtendedImage.network(
                            commenterData.profileUrl,
                            // height: 45,
                            shape: BoxShape.circle,
                            // borderRadius: Border,
                            // width: 45,
                          ),
                          title: Text(
                            commenterData.name,
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: data.ratings[inde]['rating'],
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 25,
                                    ),
                                    itemSize: 25,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    timeago.format(DateTime.parse(
                                        data.ratings[inde]['at'].toString())),
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ReadMoreText(
                              data.ratings[inde]['comment'],
                              trimMode: TrimMode.Line,
                              trimLines: 2,
                              colorClickableText: Colors.pink,
                              trimCollapsedText: ' Show more',
                              trimExpandedText: ' Show less',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              moreStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (data.ratings[inde]['images'] != null)
                          const SizedBox(
                            height: 5,
                          ),
                        if (data.ratings[inde]['images'] != null)
                          InkWell(
                            onTap: () {
                              List imageUrls = [];
                              for (var element in data.ratings) {
                                if (element['images'] != null) {
                                  imageUrls.add(element['images']);
                                }
                              }
                              Get.to(() => FullImagePageView(
                                    urls: imageUrls,
                                    currentIndex: inde,
                                  ));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: ExtendedImage.network(
                                data.ratings[inde]['images'],

                                height: 180,
                                // shape: BoxShape.rectangle,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                width: Get.width * 0.95,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
