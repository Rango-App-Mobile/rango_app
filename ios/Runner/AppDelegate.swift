import AuthenticationServices
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "RangoAppleSignInButton") {
      registrar.register(
        AppleSignInButtonFactory(messenger: registrar.messenger()),
        withId: "rango/apple_sign_in_button")
    }
  }
}

/// Hosts the system "Sign in with Apple" button so Flutter shows exactly what
/// Apple ships (localized title, logo, proportions).
final class AppleSignInButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    let params = args as? [String: Any]
    return AppleSignInButtonView(
      frame: frame,
      channel: FlutterMethodChannel(
        name: "rango/apple_sign_in_button_\(viewId)", binaryMessenger: messenger),
      cornerRadius: (params?["cornerRadius"] as? NSNumber).map { CGFloat(truncating: $0) })
  }
}

final class AppleSignInButtonView: NSObject, FlutterPlatformView {
  private let button = ASAuthorizationAppleIDButton(
    authorizationButtonType: .continue, authorizationButtonStyle: .black)
  private let channel: FlutterMethodChannel

  init(frame: CGRect, channel: FlutterMethodChannel, cornerRadius: CGFloat?) {
    self.channel = channel
    super.init()
    button.frame = frame
    if let cornerRadius { button.cornerRadius = cornerRadius }
    button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
  }

  func view() -> UIView { button }

  @objc private func tapped() {
    channel.invokeMethod("onPressed", arguments: nil)
  }
}
