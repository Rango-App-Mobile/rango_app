import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    provideGoogleMapsKey()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Reads GOOGLE_IOS_API_KEY from the dart-defines that Flutter copies into
  /// Info.plist (comma-separated base64 "KEY=value" entries).
  private func provideGoogleMapsKey() {
    guard let defines = Bundle.main.object(forInfoDictionaryKey: "DartDefines") as? String else {
      return
    }
    let prefix = "GOOGLE_IOS_API_KEY="
    for entry in defines.split(separator: ",") {
      guard let data = Data(base64Encoded: String(entry)),
        let decoded = String(data: data, encoding: .utf8),
        decoded.hasPrefix(prefix)
      else { continue }
      let value = String(decoded.dropFirst(prefix.count))
      if !value.isEmpty { GMSServices.provideAPIKey(value) }
      return
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
