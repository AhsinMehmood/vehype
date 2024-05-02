// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/comments_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    // final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,

          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: IconButton(
          //       onPressed: () {
          //         Get.bottomSheet(
          //           SearchSheet(),
          //           isScrollControlled: true,
          //         );
          //       },
          //       icon: Icon(
          //         Icons.search,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ],
          leading: IconButton(
              onPressed: () {
                Get.back();
                // ExploreController().addFakeProfiles();
              },
              icon: Icon(Icons.arrow_back_ios_new,
                  color: userController.isDark ? Colors.white : primaryColor)),
          elevation: 0.0,
          centerTitle: true,
          title: Text('Manage Users',
              style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontFamily: 'Avenir',
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              tabs: [
                Tab(
                  text: 'Active Reports',
                ),
                Tab(
                  text: 'Closed Reports',
                ),
              ]),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .where('status', isEqualTo: 'Active')
                    // .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: ((context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(
                  //     child: CircularProgressIndicator(),
                  //   );
                  // }
                  // if(snapshot.hasError){

                  // }
                  if (snapshot.data == null) {
                    return Center(
                      child: Text(
                        'No Reports',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  List reports = [];
                  for (var element in snapshot.data!.docs) {
                    reports.add(element.data());
                  }
                  if (reports.isEmpty) {
                    return Center(
                      child: Text(
                        'No Reports',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> reportData = reports[index];
                      return StreamBuilder<UserModel>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(reportData['reportTo'])
                              .snapshots()
                              .map((event) => UserModel.fromJson(event)),
                          builder: (context, reportToUserSnap) {
                            if (!reportToUserSnap.hasData) {
                              return SizedBox.shrink();
                            }
                            if (reportToUserSnap.data == null) {
                              return SizedBox.shrink();
                            }
                            UserModel reportToUserModel =
                                reportToUserSnap.data!;
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: ExtendedImage.network(
                                          reportToUserModel.profileUrl,
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
                                            reportToUserModel.name,
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
                                                  data: reportToUserModel));
                                            },
                                            child: Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating:
                                                      reportToUserModel.rating,
                                                  itemBuilder:
                                                      (context, index) =>
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
                                                  reportToUserModel
                                                      .ratings.length
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
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            reportToUserModel.email,
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            'Total Reports: ${reportToUserModel.blockedBy.length}',
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            'Reason: ${reportData['reason']}',
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          if (reportToUserModel.adminStatus ==
                                              'blocked')
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    // backgroundColor: userController.i
                                                    ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(reportToUserModel
                                                          .userId)
                                                      .update({
                                                    'adminStatus': 'active'
                                                  });
                                                },
                                                child: Text(
                                                  'Unblock',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          if (reportToUserModel.adminStatus ==
                                              'active')
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    // backgroundColor: userController.i
                                                    ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(reportToUserModel
                                                          .userId)
                                                      .update({
                                                    'adminStatus': 'blocked'
                                                  });
                                                },
                                                child: Text(
                                                  'Block',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  // backgroundColor: userController.i
                                                  ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('reports')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .update(
                                                        {'status': 'closed'});
                                              },
                                              child: Text(
                                                'Close Report',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  );
                })),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .where('status', isEqualTo: 'closed')
                    // .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: ((context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(
                  //     child: CircularProgressIndicator(),
                  //   );
                  // }
                  // if(snapshot.hasError){

                  // }
                  if (snapshot.data == null) {
                    return Center(
                      child: Text(
                        'No Reports',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  List reports = [];
                  for (var element in snapshot.data!.docs) {
                    reports.add(element.data());
                  }
                  if (reports.isEmpty) {
                    return Center(
                      child: Text(
                        'No Reports',
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> reportData = reports[index];
                      return StreamBuilder<UserModel>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(reportData['reportTo'])
                              .snapshots()
                              .map((event) => UserModel.fromJson(event)),
                          builder: (context, reportToUserSnap) {
                            if (!reportToUserSnap.hasData) {
                              return SizedBox.shrink();
                            }
                            if (reportToUserSnap.data == null) {
                              return SizedBox.shrink();
                            }
                            UserModel reportToUserModel =
                                reportToUserSnap.data!;
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: ExtendedImage.network(
                                          reportToUserModel.profileUrl,
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
                                            reportToUserModel.name,
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
                                                  data: reportToUserModel));
                                            },
                                            child: Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating:
                                                      reportToUserModel.rating,
                                                  itemBuilder:
                                                      (context, index) =>
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
                                                  reportToUserModel
                                                      .ratings.length
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
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            reportToUserModel.email,
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            'Total Reports: ${reportToUserModel.blockedBy.length}',
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            'Reason: ${reportData['reason']}',
                                            style: TextStyle(
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          if (reportToUserModel.adminStatus ==
                                              'blocked')
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    // backgroundColor: userController.i
                                                    ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(reportToUserModel
                                                          .userId)
                                                      .update({
                                                    'adminStatus': 'active'
                                                  });
                                                },
                                                child: Text(
                                                  'Unblock',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          if (reportToUserModel.adminStatus ==
                                              'active')
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    // backgroundColor: userController.i
                                                    ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(reportToUserModel
                                                          .userId)
                                                      .update({
                                                    'adminStatus': 'blocked'
                                                  });
                                                },
                                                child: Text(
                                                  'Block',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  // backgroundColor: userController.i
                                                  ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('reports')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .update(
                                                        {'status': 'Active'});
                                              },
                                              child: Text(
                                                'Open Report',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  );
                })),
          ],
        ),
      ),
    );
  }
}
