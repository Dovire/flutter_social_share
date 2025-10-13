import Flutter
import UIKit
import FBSDKShareKit
import FBSDKCoreKit

public class FlutterSocialSharePlugin: NSObject, FlutterPlugin {
    private var facebookShareHandler: FacebookShareHandler?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_social_share", binaryMessenger: registrar.messenger())
        let instance = FlutterSocialSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    deinit {
        // Ensure cleanup when plugin is deallocated
        facebookShareHandler?.cleanup()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initializeFacebook":
            handleFacebookInitialize(call: call, result: result)
        case "shareImageToFacebook":
            handleFacebookShareImage(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleFacebookInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let appId = arguments["appId"] as? String,
              let clientToken = arguments["clientToken"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "App ID and Client Token are required", 
                              details: nil))
            return
        }
        
        facebookShareHandler = FacebookShareHandler()
        facebookShareHandler?.initialize(appId: appId, clientToken: clientToken, result: result)
    }
    
    private func handleFacebookShareImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let imagePath = arguments["imagePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Image path is required", 
                              details: nil))
            return
        }
        
        let caption = arguments["caption"] as? String
        
        guard let shareHandler = facebookShareHandler else {
            result(FlutterError(code: "NOT_INITIALIZED", 
                              message: "Facebook SDK not initialized", 
                              details: nil))
            return
        }
        
        shareHandler.shareImage(imagePath: imagePath, caption: caption, result: result)
    }
}
