// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/splash_page.dart';
// import 'package:json_theme/json_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
  //   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  // }
  await Firebase.initializeApp();
  // final themeStr = await rootBundle.loadString('assets/theme.json');
  // final themeStrDark = await rootBundle.loadString('assets/dark_theme.json');
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  // final themeJson = jsonDecode(themeStr);
  // final darkThemeJson = jsonDecode(themeStrDark);

  // final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  // final darkTheme = ThemeDecoder.decodeThemeData(darkThemeJson)!;
  OneSignal.Debug.setLogLevel(OSLogLevel.none);

  OneSignal.initialize("e236663f-f5c0-4a40-a2df-81e62c7d411f");
  await Mixpanel.init('c40aeb8e3a8f1030b811314d56973f5a',
      trackAutomaticEvents: true);
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn =
  //         'https://c6ac471a08028bb3ecd01426b474eaf5@o4507069896523776.ingest.us.sentry.io/4507069897965568';
  //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
  //     // We recommend adjusting this value in production.
  //     options.tracesSampleRate = 1.0;
  //     // The sampling rate for profiling is relative to tracesSampleRate
  //     // Setting to 1.0 will profile 100% of sampled transactions:
  //     options.profilesSampleRate = 1.0;
  //   },
  //   appRunner: () =>
  // );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(
            create: (context) => UserController()),
        ChangeNotifierProvider<GarageController>(
            create: (context) => GarageController()),
        ChangeNotifierProvider<ChatController>(
            create: (context) => ChatController()),
      ],
      child: MyApp(
          // theme: theme,
          // themeStrDark: darkTheme,
          ),
    ),
  );
}

class MyApp extends StatefulWidget {
  // final ThemeData theme;
  // final ThemeData themeStrDark;
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool needToUpdate = false;
  checkUpdate() async {
    UserController().checkVersion().then((value) {
      setState(() {
        needToUpdate = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      userController.initTheme();
      checkUpdate();
    });
    listenOneSignalNotification();
  }

  listenOneSignalNotification() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      if (event.notification.additionalData!['type'] == 'Message') {
        // FlutterAppBadger.updateBadgeCount(1);
        // print(event.notification.additionalData);
        ChatController().updateMessage(
            event.notification.additionalData!['chatId'],
            event.notification.additionalData!['messageId'],
            1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final UserController userController = Provider.of<UserController>(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VEHYPE',
      themeMode: userController.isDark ? ThemeMode.dark : ThemeMode.light,
      // darkTheme: widget.themeStrDark,
      // theme: widget.theme,
      home: needToUpdate ? const AppUpdate() : const SplashPage(),
    );
  }
}

class AppUpdate extends StatelessWidget {
  const AppUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                'App outdated!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                'Please update your app to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
