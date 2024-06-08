// ignore_for_file: sort_child_properties_last

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/app_controller.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/chat_page.dart';
import 'package:vehype/Pages/explore_page.dart';
import 'package:vehype/Pages/my_garage.dart';
import 'package:vehype/Pages/orders_history_provider.dart';
import 'package:vehype/Pages/profile_page.dart';
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/const.dart';

import 'offers_tab_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  List<Widget> _body = [
    RepairPage(),
    MyGarage(),
    ExplorePage(),
    ChatPage(),
    ProfilePage(),
  ];
  List<Widget> _body2 = [
    OrdersHistoryProvider(),
    ChatPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    // AppController controller = Get.put(AppController());
    return Scaffold(
        body: IndexedStack(
          index: userModel.accountType == 'seeker'
              ? userController.tabIndex
              : userController.tabIndex,
          children: userModel.accountType == 'seeker' ? _body : _body2,
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: userModel.accountType == 'seeker'
            ? bottomNavigationBarSeeker()
            : bottomNavigationBarProvider());
  }

  BottomNavigationBar bottomNavigationBarProvider() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    return BottomNavigationBar(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      selectedItemColor: userController.isDark ? Colors.white : Colors.black,
      selectedFontSize: 13,
      unselectedFontSize: 13,
      // unselectedItemColor: C,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 13,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) {
        // print(userModel.userId);
        userController.changeTabIndex(index);

        // FlutterAppBadger.updateBadgeCount(10);
        // OneSignal.login(userModel.userId);
        // sendNotification(userModel.userId, 'Ahsinnn', 'Has', 'contents',
        //     'chatId', 'type', 'messageId');
        // userController.checkIsAdmin(userModel.email);
      },
      items: providerTabs(),

      type: BottomNavigationBarType.fixed,
    );
  }

  BottomNavigationBar bottomNavigationBarSeeker() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;

    return BottomNavigationBar(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      selectedItemColor: userController.isDark ? Colors.white : Colors.black,
      selectedFontSize: 13,
      unselectedFontSize: 13,
      // unselectedItemColor: C,
      selectedIconTheme: IconThemeData(
        color: changeColor(color: colorPurple),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 13,
        color: userController.isDark ? Colors.white : Colors.black,
      ),
      currentIndex: userController.tabIndex,
      onTap: (int index) async {
        print(userModel.userId);

        // userController.checkIsAdmin(userModel.email);
        userController.changeTabIndex(index);
        // FlutterAppBadger.updateBadgeCount(10);
        // OneSignal.login(userModel.userId);
        // sendNotification(userModel.userId, 'Ahsinnn', 'Has', 'contents',
        //     'chatId', 'type', 'messageId');
        print(userModel.userId);
      },
      items: seekerTabs(),

      type: BottomNavigationBarType.fixed,
    );
  }

  List<BottomNavigationBarItem> providerTabs() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
          icon: Icon(
            Icons.online_prediction_rounded,
            size: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(0),
          ),
          label: 'Offers'),

      // if (userModel.accountType != 'seeker')
      // BottomNavigationBarItem(
      //     icon: Icon(
      //       Icons.notifications_none,
      //       size: 28,
      //       // ignore: deprecated_member_use
      //       color: labelAndIconColorDark(1),
      //     ),
      //     label: 'Notifications'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/messages.svg',
                height: 28,
                width: 28,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(1),
              ),
              StreamBuilder<List<ChatModel>>(
                  stream:
                      ChatController().chatsStream(userModel.userId, context),
                  builder: (context, AsyncSnapshot<List<ChatModel>> snapshot) {
                    if (snapshot.hasData) {
                      bool haveUnread = false;
                      List<ChatModel> chats = snapshot.data ?? [];
                      for (var element in chats) {
                        if (haveUnread == false) {
                          haveUnread = getUnread(element.lastMessageAt,
                              element.lastOpen[userModel.userId], context);
                        }
                      }
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Visibility(
                          visible: haveUnread,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: haveUnread ? Colors.red : Colors.white,
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
            ],
          ),
          label: 'Messages'),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/profile.png',
          height: 28,
          width: 28,
          // ignore: deprecated_member_use
          color: labelAndIconColorDark(2),
        ),
        label: 'Profile',
      ),
    ];
  }

  bool getUnread(String sentAt, String lastOpen, BuildContext context) {
    bool unreadMessage = DateTime.parse(sentAt)
            .toLocal()
            .difference(DateTime.parse(lastOpen).toLocal())
            .inSeconds >
        0;

    return unreadMessage;
  }

  List<BottomNavigationBarItem> seekerTabs() {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    bool haveUnread = false;

    return [
      // if (userModel.accountType == 'seeker')
      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/repair.png',
            height: 28,
            width: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(0),
          ),
          label: 'Repair'),

      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/garage.png',
            height: 28,
            width: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(1),
          ),
          label: 'My Garage'),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.location_on_outlined,
            size: 28,
            // width: 28,
            // ignore: deprecated_member_use
            color: labelAndIconColorDark(2),
          ),
          label: 'Explore'),
      // if (userModel.accountType != 'seeker')
      //   BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.notifications_none,
      //         size: 28,
      //         // ignore: deprecated_member_use
      //         color: labelAndIconColorDark(1),
      //       ),
      //       label: 'Notifications'),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/messages.svg',
                height: 28,
                width: 28,
                // ignore: deprecated_member_use
                color: labelAndIconColorDark(3),
              ),
              StreamBuilder<List<ChatModel>>(
                  stream:
                      ChatController().chatsStream(userModel.userId, context),
                  builder: (context, AsyncSnapshot<List<ChatModel>> snapshot) {
                    if (snapshot.hasData) {
                      List<ChatModel> chats = snapshot.data ?? [];
                      for (var element in chats) {
                        if (haveUnread == false) {
                          haveUnread = getUnread(element.lastMessageAt,
                              element.lastOpen[userModel.userId], context);
                        }
                      }

                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Visibility(
                          visible: haveUnread,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
            ],
          ),
          label: 'Messages'),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/profile.png',
          height: 28,
          width: 28,
          // ignore: deprecated_member_use
          color: labelAndIconColorDark(4),
        ),
        label: 'Profile',
      ),
    ];
  }

  Color labelAndIconColor(int index) {
    final UserController userController = Provider.of<UserController>(context);

    int tabIndex = userController.tabIndex;
    bool isDark = userController.isDark;
    Color color = tabIndex == index && isDark ? Colors.white : primaryColor;
    return Color(tabIndex);
  }

  Color labelAndIconColorDark(int index) {
    final UserController userController = Provider.of<UserController>(context);

    int tabIndex = userController.tabIndex;
    if (userController.isDark) {
      Color color = tabIndex == index ? Colors.white : Colors.white54;
      return color;
    } else {
      Color color = tabIndex == index ? Colors.black : Colors.black54;
      return color;
    }
  }
  // : const SizedBox.shrink();
}
