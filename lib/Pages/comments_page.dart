import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/const.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vehype/providers/copy_vehicle_data.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';

class CommentsPage extends StatefulWidget {
  final UserModel data;
  const CommentsPage({super.key, required this.data});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String selectedIssue = '';

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final filteredRatings = selectedIssue.isEmpty
        ? widget.data.ratings
        : widget.data.ratings
            .where((rating) => rating['service'] == selectedIssue)
            .toList();
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Reviews And Ratings',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  child: Text(
                    'Filter reviews by service',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 60,
            // color: Colors.red,
            child: ListView.builder(
                itemCount: getServices().length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                itemBuilder: (context, index) {
                  Service service = getServices()[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () {
                        if (selectedIssue == service.name) {
                          setState(() {
                            selectedIssue = '';
                          });
                        } else {
                          setState(() {
                            selectedIssue = service.name;
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            service.image,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            height: 50,
                            width: 50,
                          ),
                          if (selectedIssue == service.name)
                            Positioned(
                              right: 2,
                              top: 3,
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          if (selectedIssue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Chip(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    label: Text(
                      selectedIssue,
                    ),
                    labelStyle: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                    ),
                    deleteIcon: Icon(Icons.close),
                    deleteIconColor:
                        userController.isDark ? primaryColor : Colors.white,
                    onDeleted: () {
                      setState(() {
                        selectedIssue = ''; // Reset to default
                        // _sortAndFilterOffers();
                      });
                    },
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredRatings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.reviews, // A relevant icon
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No reviews found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            // color: Co,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text(
                        //   "Be the first to leave a review for this service!",
                        //   style: TextStyle(fontSize: 14, color: Colors.grey),
                        // ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRatings.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    shrinkWrap: true,
                    itemBuilder: (context, inde) {
                      return StreamBuilder<UserModel>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(filteredRatings[inde]['id'])
                              .snapshots()
                              .map((event) => UserModel.fromJson(event)),
                          builder:
                              (context, AsyncSnapshot<UserModel> snapshot) {
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
                            return InkWell(
                              onTap: () async {
                                QuerySnapshot<Map<String, dynamic>> users =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .get();
                                for (var element in users.docs) {
                                  log(element.data()['ratings'].toString());
                                  await VehicleDataProvider()
                                      .addRandomServiceToRatings(
                                          ownerId: UserModel.fromJson(element)
                                              .userId);
                                }
                              },
                              child: CommentWidget(
                                  commenterData: commenterData,
                                  data: widget.data,
                                  inde: inde),
                            );
                          });
                    }),
          ),
        ],
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final UserModel commenterData;
  final UserModel data;
  final int inde;
  const CommentWidget(
      {super.key,
      required this.commenterData,
      required this.data,
      required this.inde});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Card(
        color: userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      imageUrl: commenterData.profileUrl,
                      height: 45,
                      // shape: BoxShape.circle,
                      // borderRadius: Border,
                      width: 45,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commenterData.name,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
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
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                  moreStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                        urls: [data.ratings[inde]['images']],
                        currentIndex: 0,
                      ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: data.ratings[inde]['images'],
                    errorWidget: (context, url, error) => SizedBox(
                      child: Text('Imge Not Found'),
                    ),

                    placeholder: (context, url) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    height: 180,
                    // shape: BoxShape.rectangle,
                    fit: BoxFit.cover,

                    width: Get.width * 0.95,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
