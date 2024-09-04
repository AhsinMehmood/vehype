import UIKit
import Flutter
import GoogleMaps
import Firebase
// import FirebaseAuth
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    //  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //     let firebaseAuth = Auth.auth()
    //     firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    // }
}