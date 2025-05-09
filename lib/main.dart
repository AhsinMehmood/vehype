// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/providers/assistance_chat_provider.dart';
import 'package:vehype/providers/firebase_storage_provider.dart';

import '/Controllers/chat_controller.dart';
import '/Controllers/garage_controller.dart';
import '/Controllers/mix_panel_controller.dart';
import '/Controllers/offers_provider.dart';

import '/Controllers/user_controller.dart';

import '/Pages/splash_page.dart';

import '/const.dart';
import 'providers/copy_vehicle_data.dart';
import 'providers/garage_provider.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        await _handleLogout();
      } else {}
    });
  }

  Future<void> _handleLogout() async {
    await OneSignal.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {}

    Get.offAll(() => SplashPage());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  Get.put(AuthController());
  Get.put(MixPanelController());

  OneSignal.Debug.setLogLevel(OSLogLevel.error);

  OneSignal.initialize(isDebug ? debugOneSignalApiKey : prodOneSignalApiKey);

  // await SentryFlutter.init((options) {
  //   options.dsn =
  //       'https://db34bb55769b55480e81f75aca7cf9d8@o4507883907186688.ingest.us.sentry.io/4507883909677056';

  //   options.tracesSampleRate = 1.0;

  //   options.profilesSampleRate = 1.0;
  // },
  //     appRunner: () => );
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider<UserController>(
            create: (context) => UserController()),
        ChangeNotifierProvider<OffersProvider>(
            create: (context) => OffersProvider()),
        ChangeNotifierProvider<GarageController>(
            create: (context) => GarageController()),
        ChangeNotifierProvider<ChatController>(
            create: (context) => ChatController()),
        ChangeNotifierProvider(create: (context) => GarageProvider()),
        ChangeNotifierProvider(create: (context) => FirebaseStorageProvider()),
        ChangeNotifierProvider(create: (_) => VehicleDataProvider()),
        ChangeNotifierProvider(create: (context) => AssistanceChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final UserController userController = Provider.of<UserController>(context);

    TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      displayMedium: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      displaySmall: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleLarge: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleMedium: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleSmall: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodySmall: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelLarge: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelMedium: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelSmall: GoogleFonts.poppins(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VEHYPE',
      // navigatorKey: navigatorKey,
      themeMode: userController.isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        textTheme: textTheme,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      theme: ThemeData().copyWith(
        textTheme: textTheme,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const SplashPage(),
    );
  }
}

class NewSplash extends StatefulWidget {
  const NewSplash({super.key});

  @override
  State<NewSplash> createState() => _NewSplashState();
}

class _NewSplashState extends State<NewSplash> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
