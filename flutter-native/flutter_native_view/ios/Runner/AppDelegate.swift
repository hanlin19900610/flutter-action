import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  let VIEW_TYPE_ID: String = "com.mufeng.flutter_native_view/custom_platform_view"
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let registrar: FlutterPluginRegistrar = self.registrar(forPlugin: VIEW_TYPE_ID)!
    let factory = CustomFlutterViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: VIEW_TYPE_ID)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
