import Foundation
import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import Flutter

class FacebookShareHandler: NSObject {
    private var isInitialized = false
    private var appId: String?
    private var clientToken: String?
    
    func initialize(appId: String, clientToken: String, result: @escaping FlutterResult) {
        // Validate credentials
        guard !appId.isEmpty && !clientToken.isEmpty else {
            result(FlutterError(code: "INVALID_CREDENTIALS", 
                              message: "App ID and Client Token cannot be empty", 
                              details: nil))
            return
        }
        
        // Store credentials in memory only (not persisted)
        self.appId = appId
        self.clientToken = clientToken
        
        // Configure Facebook SDK programmatically
        Settings.shared.appID = appId
        Settings.shared.clientToken = clientToken
        
        // Additional FBSDK settings for security and functionality
        Settings.shared.isAutoLogAppEventsEnabled = false
        Settings.shared.isAdvertiserIDCollectionEnabled = false
        Settings.shared.isCodelessDebugLogEnabled = false
        
        // Initialize the Facebook SDK
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        
        isInitialized = true
        
        // Log successful initialization (without exposing credentials)
        print("Facebook SDK initialized successfully for iOS")
        
        result(["status": "success", "message": "Facebook SDK initialized successfully"])
    }
    
    func cleanup() {
        // Clear credentials from memory
        appId = nil
        clientToken = nil
        isInitialized = false
        
        // Clear Facebook SDK settings
        Settings.shared.appID = nil
        Settings.shared.clientToken = nil
    }
    
    func shareImage(imagePath: String, caption: String?, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", 
                              message: "Facebook SDK not initialized", 
                              details: nil))
            return
        }
        
        // Validate image path format
        guard !imagePath.isEmpty else {
            result(FlutterError(code: "INVALID_PATH", 
                              message: "Image path cannot be empty", 
                              details: nil))
            return
        }
        
        // Validate image path and load image with comprehensive error handling
        guard let image = loadImage(from: imagePath) else {
            result(FlutterError(code: "INVALID_PATH", 
                              message: "Could not load image from path: \(imagePath). Please ensure the file exists and is accessible.", 
                              details: ["imagePath": imagePath]))
            return
        }
        
        // Validate image dimensions and size
        guard validateImage(image) else {
            result(FlutterError(code: "INVALID_IMAGE", 
                              message: "Image validation failed. Image may be too large or have invalid dimensions.", 
                              details: ["imagePath": imagePath]))
            return
        }
        
        // Create share photo content using FBSDKSharePhotoContent
        let photo = SharePhoto(image: image, isUserGenerated: true)
        
        let content = SharePhotoContent()
        content.photos = [photo]
        
        // Add caption if provided and not empty
        if let caption = caption, !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            content.hashtag = Hashtag(caption)
        }
        
        // Get the root view controller
        guard let rootViewController = getRootViewController() else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", 
                              message: "Could not find root view controller for presenting share dialog", 
                              details: nil))
            return
        }
        
        // Create and show share dialog with proper delegate
        let dialog = ShareDialog(
            viewController: rootViewController,
            content: content,
            delegate: ShareDialogDelegate(result: result)
        )
        
        // Check if sharing is possible
        if dialog.canShow {
            print("Showing Facebook share dialog")
            dialog.show()
        } else {
            // Determine specific reason why sharing is not available
            let facebookInstalled = isFacebookAppInstalled()
            
            if !facebookInstalled {
                logError("Facebook app not installed", details: ["facebookInstalled": facebookInstalled])
                result(FlutterError(code: "FACEBOOK_APP_NOT_AVAILABLE", 
                                  message: "Facebook app is not installed on this device", 
                                  details: ["facebookInstalled": false]))
            } else {
                logError("Facebook sharing not available", details: [
                    "facebookInstalled": facebookInstalled,
                    "canShow": dialog.canShow
                ])
                
                let errorMessage = "Facebook sharing is not available. This could be because:\n" +
                                 "1. Facebook SDK is not properly configured\n" +
                                 "2. Device does not support sharing\n" +
                                 "3. Facebook app version is incompatible"
                
                result(FlutterError(code: "SHARING_NOT_AVAILABLE", 
                                  message: errorMessage, 
                                  details: ["facebookInstalled": facebookInstalled]))
            }
        }
    }
    
    private func loadImage(from path: String) -> UIImage? {
        var image: UIImage?
        
        // Handle different path formats with comprehensive error handling
        if path.hasPrefix("file://") {
            // Handle file:// URLs
            guard let url = URL(string: path) else {
                print("Invalid file URL: \(path)")
                return nil
            }
            
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            } catch {
                print("Error loading image from URL \(path): \(error.localizedDescription)")
                return nil
            }
        } else if path.hasPrefix("/") {
            // Handle absolute file paths
            guard FileManager.default.fileExists(atPath: path) else {
                print("File does not exist at path: \(path)")
                return nil
            }
            
            image = UIImage(contentsOfFile: path)
        } else {
            // Handle relative paths or other formats
            // Try to load as bundle resource first
            if let bundleImage = UIImage(named: path) {
                image = bundleImage
            } else {
                // Try as documents directory path
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let fullPath = (documentsPath as NSString).appendingPathComponent(path)
                image = UIImage(contentsOfFile: fullPath)
            }
        }
        
        if image == nil {
            print("Failed to load image from path: \(path)")
        }
        
        return image
    }
    
    private func validateImage(_ image: UIImage) -> Bool {
        // Check if image has valid dimensions
        guard image.size.width > 0 && image.size.height > 0 else {
            print("Image has invalid dimensions: \(image.size)")
            return false
        }
        
        // Check reasonable size limits (Facebook has limits on image size)
        let maxDimension: CGFloat = 2048
        if image.size.width > maxDimension || image.size.height > maxDimension {
            print("Image dimensions too large: \(image.size). Max allowed: \(maxDimension)x\(maxDimension)")
            return false
        }
        
        return true
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Error: Could not find window scene or window")
            return nil
        }
        
        guard let rootViewController = window.rootViewController else {
            print("Error: Root view controller not available")
            return nil
        }
        
        return rootViewController
    }
    
    private func isFacebookAppInstalled() -> Bool {
        // Check if Facebook app is installed by trying to open Facebook URL scheme
        guard let facebookURL = URL(string: "fb://") else {
            return false
        }
        
        return UIApplication.shared.canOpenURL(facebookURL)
    }
    
    private func logError(_ message: String, details: [String: Any]? = nil) {
        print("FacebookShareHandler Error: \(message)")
        if let details = details {
            print("Error details: \(details)")
        }
    }
}

// MARK: - ShareDialogDelegate
class ShareDialogDelegate: NSObject, SharingDelegate {
    private let result: FlutterResult
    
    init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        // Log successful share for debugging
        print("Facebook share completed successfully: \(results)")
        
        result([
            "status": "success",
            "message": "Image shared successfully",
            "data": results
        ])
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        let nsError = error as NSError
        
        // Comprehensive error logging
        print("Facebook share failed with error: \(error)")
        print("Error domain: \(nsError.domain), code: \(nsError.code)")
        print("Error description: \(nsError.localizedDescription)")
        if let userInfo = nsError.userInfo as? [String: Any] {
            print("Error userInfo: \(userInfo)")
        }
        
        // Map iOS NSError to consistent error codes
        let (errorCode, errorMessage) = mapErrorToConsistentCode(nsError)
        
        result(FlutterError(
            code: errorCode,
            message: errorMessage,
            details: [
                "originalError": nsError.localizedDescription,
                "errorDomain": nsError.domain,
                "errorCode": nsError.code,
                "userInfo": nsError.userInfo
            ]
        ))
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("Facebook share was cancelled by user")
        
        result([
            "status": "cancelled",
            "message": "User cancelled sharing"
        ])
    }
    
    private func mapErrorToConsistentCode(_ nsError: NSError) -> (String, String) {
        var errorCode = "UNKNOWN_ERROR"
        var errorMessage = nsError.localizedDescription
        
        // Handle Facebook SDK specific errors
        if nsError.domain == "com.facebook.sdk.share" || nsError.domain == "FBSDKShareErrorDomain" {
            switch nsError.code {
            case 201:
                errorCode = "USER_CANCELLED"
                errorMessage = "User cancelled the share dialog"
            case 202:
                errorCode = "NETWORK_ERROR"
                errorMessage = "Network error occurred during sharing"
            case 203:
                errorCode = "FACEBOOK_APP_NOT_AVAILABLE"
                errorMessage = "Facebook app is not available for sharing"
            default:
                errorCode = "FACEBOOK_ERROR"
                errorMessage = "Facebook sharing error: \(nsError.localizedDescription)"
            }
        }
        // Handle Core Foundation errors
        else if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileReadNoSuchFileError:
                errorCode = "INVALID_PATH"
                errorMessage = "Image file not found"
            case NSFileReadNoPermissionError:
                errorCode = "PERMISSION_DENIED"
                errorMessage = "Permission denied accessing image file"
            default:
                errorCode = "FILE_ERROR"
                errorMessage = "File system error: \(nsError.localizedDescription)"
            }
        }
        // Handle URL errors
        else if nsError.domain == NSURLErrorDomain {
            errorCode = "NETWORK_ERROR"
            errorMessage = "Network error: \(nsError.localizedDescription)"
        }
        // Handle general iOS errors
        else {
            switch nsError.code {
            case -1:
                errorCode = "CANCELLED"
                errorMessage = "Operation was cancelled"
            case -999:
                errorCode = "USER_CANCELLED"
                errorMessage = "User cancelled the operation"
            default:
                errorCode = "PLATFORM_ERROR"
                errorMessage = "iOS platform error: \(nsError.localizedDescription)"
            }
        }
        
        return (errorCode, errorMessage)
    }
}