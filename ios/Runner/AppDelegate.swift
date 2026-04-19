import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps
    GMSServices.provideAPIKey("AIzaSyBQFkJ6oG4RTRRb6RbJ3Tk0MfrA1seHTqM")

    // Firebase
    FirebaseApp.configure()

    // Google Sign-In — explicit config required for distribution builds.
    // serverClientID (web client) is required by GIDSignIn 7.x to generate a valid idToken.
    if let clientID = FirebaseApp.app()?.options.clientID {
      let serverClientID = "830017708682-l5976rfnqen0ap7ofmhn6adb7bt6p4j3.apps.googleusercontent.com"
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID, serverClientID: serverClientID)
    }

    // Push Notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle APNs token
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Handle Google Sign-In callback URL
  override func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
