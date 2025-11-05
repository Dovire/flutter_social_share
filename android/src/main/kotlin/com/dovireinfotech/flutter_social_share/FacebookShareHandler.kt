package com.dovireinfotech.flutter_social_share

import android.app.Activity
import android.content.Context
import android.net.Uri
import android.util.Log
import com.facebook.FacebookSdk
import com.facebook.share.model.SharePhoto
import com.facebook.share.model.SharePhotoContent
import com.facebook.share.widget.ShareDialog
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class FacebookShareHandler(private val context: Context) {
    
    companion object {
        private const val TAG = "FacebookShareHandler"
    }
    
    private var isInitialized = false
    private var appId: String? = null
    private var clientToken: String? = null

    fun initialize(appId: String, clientToken: String, result: Result) {
        try {
            this.appId = appId
            this.clientToken = clientToken
            
            // Initialize Facebook SDK programmatically
            FacebookSdk.setApplicationId(appId)
            FacebookSdk.setClientToken(clientToken)
            FacebookSdk.sdkInitialize(context)
            
            isInitialized = true
            Log.d(TAG, "Facebook SDK initialized successfully")
            
            result.success(mapOf(
                "status" to "success",
                "message" to "Facebook SDK initialized successfully"
            ))
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Facebook SDK", e)
            result.error(
                "INITIALIZATION_FAILED",
                "Failed to initialize Facebook SDK: ${e.message}",
                mapOf(
                    "errorCode" to "initializationFailed",
                    "details" to e.toString()
                )
            )
        }
    }

    fun shareImage(activity: Activity, imagePath: String, caption: String?, result: Result) {
        if (!isInitialized) {
            result.error(
                "NOT_INITIALIZED",
                "Facebook SDK not initialized. Call initialize() first.",
                mapOf("errorCode" to "initializationFailed")
            )
            return
        }

        try {
            // Validate image file exists
            val imageFile = File(imagePath)
            if (!imageFile.exists() || !imageFile.canRead()) {
                result.error(
                    "INVALID_PATH",
                    "Image file not found or not readable: $imagePath",
                    mapOf("errorCode" to "invalidPath")
                )
                return
            }

            // Check if Facebook app is available for sharing
            val shareDialog = ShareDialog(activity)
            if (!shareDialog.canShow(SharePhotoContent::class.java)) {
                result.error(
                    "MISSING_APP",
                    "Facebook app is not installed or sharing is not available",
                    mapOf("errorCode" to "missingApp")
                )
                return
            }

            // Create SharePhoto from image file
            val imageUri = Uri.fromFile(imageFile)
            val photo = SharePhoto.Builder()
                .setImageUrl(imageUri)
                .apply {
                    caption?.let { setCaption(it) }
                }
                .build()

            // Create SharePhotoContent
            val content = SharePhotoContent.Builder()
                .addPhoto(photo)
                .build()

            // Set up callback for share result
            shareDialog.registerCallback(
                FacebookCallbackManager.getInstance(),
                FacebookShareCallback(result)
            )

            // Show share dialog
            shareDialog.show(content)
            Log.d(TAG, "Facebook share dialog shown")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to share image", e)
            result.error(
                "SHARE_FAILED",
                "Failed to share image: ${e.message}",
                mapOf(
                    "errorCode" to "unknown",
                    "details" to e.toString()
                )
            )
        }
    }
}