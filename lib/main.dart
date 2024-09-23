// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/offers_provider.dart';

import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/splash_page.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/const.dart';
import 'package:vehype/firebase_options.dart';

// import 'package:json_theme/json_theme.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Handle background message
//   print('Handling a background message: ${message.messageId}');
//   if (message.data['type'] == 'chat') {
//     // FlutterAppBadger.updateBadgeCount(1);
//     // print(event.notification.additionalData);
//     ChatController()
//         .updateMessage(message.data['chatId'], message.data['messageId'], 1);
//   }
// }

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // User logged out
        await _handleLogout();
      } else {
        // User logged in
        // Get.offAllNamed('/home');
      }
    });
  }

  Future<void> _handleLogout() async {
    // Clear shared preferences
    await OneSignal.logout();
    // await GoogleSignIn().disconnect();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print(e);
    }
    // Navigate to the Splash Page
    Get.offAll(() => SplashPage());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
  //   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  // }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final themeStr = await rootBundle.loadString('assets/theme.json');
  // final themeStrDark = await rootBundle.loadString('assets/dark_theme.json');
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  Get.put(AuthController());

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // NotificationController().listenOneSignalNotification();
  // final themeJson = jsonDecode(themeStr);
  // final darkThemeJson = jsonDecode(themeStrDark);

  // final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  // final darkTheme = ThemeDecoder.decodeThemeData(darkThemeJson)!;
  OneSignal.Debug.setLogLevel(OSLogLevel.debug);

  OneSignal.initialize("e236663f-f5c0-4a40-a2df-81e62c7d411f");
  // await Mixpanel.init('c40aeb8e3a8f1030b811314d56973f5a',
  //     trackAutomaticEvents: true);
  await SentryFlutter.init((options) {
    options.dsn =
        'https://db34bb55769b55480e81f75aca7cf9d8@o4507883907186688.ingest.us.sentry.io/4507883909677056';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;

    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    options.profilesSampleRate = 1.0;
  },
      appRunner: () => runApp(
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
              ],
              child: MyApp(
                  // theme: theme,
                  // themeStrDark: darkTheme,
                  ),
            ),
          ));
}

class MyApp extends StatefulWidget {
  // final ThemeData theme;
  // final ThemeData themeStrDark;
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(seconds: 0)).then((value) async {
      await userController.initTheme();
    });

    // listenOneSignalNotification();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    userController.initTheme();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final UserController userController = Provider.of<UserController>(context);

    TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      displayMedium: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      displaySmall: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineLarge: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineMedium: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      headlineSmall: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleLarge: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleMedium: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      titleSmall: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodyLarge: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodyMedium: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      bodySmall: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelLarge: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelMedium: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
      labelSmall: GoogleFonts.notoSansOsage(
        color: userController.isDark ? Colors.white : primaryColor,
      ),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VEHYPE',
      navigatorKey: navigatorKey,
      themeMode: userController.isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(textTheme: textTheme),
      theme: ThemeData().copyWith(
        textTheme: textTheme,
        primaryColor: primaryColor,
      ),
      home: const SplashPage(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage();
        } else if (snapshot.hasData) {
          return TabsPage(); // User is logged in
        } else {
          return ChooseAccountTypePage(); // User is not logged in
        }
      },
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
