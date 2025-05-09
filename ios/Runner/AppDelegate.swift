import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDm7nwkWyl3djkqjOS6-Ygg-shDVT-1aKI")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
