package com.example.flutter_social_share

import android.util.Log
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import io.flutter.plugin.common.MethodChannel.Result

class FacebookShareCallback(private val result: Result) : FacebookCallback<Sharer.Result> {
    
    companion object {
        private const val TAG = "FacebookShareCallback"
    }

    override fun onSuccess(sharerResult: Sharer.Result) {
        Log.d(TAG, "Facebook share successful")
        result.success(mapOf(
            "status" to "success",
            "message" to "Image shared successfully to Facebook"
        ))
    }

    override fun onCancel() {
        Log.d(TAG, "Facebook share cancelled by user")
        result.success(mapOf(
            "status" to "cancelled",
            "message" to "Share cancelled by user"
        ))
    }

    override fun onError(error: FacebookException) {
        Log.e(TAG, "Facebook share error", error)
        
        val errorCode = when {
            error.message?.contains("not installed", ignoreCase = true) == true -> "missingApp"
            error.message?.contains("network", ignoreCase = true) == true -> "networkError"
            else -> "unknown"
        }
        
        result.error(
            "SHARE_ERROR",
            "Facebook share failed: ${error.message}",
            mapOf(
                "errorCode" to errorCode,
                "details" to error.toString()
            )
        )
    }
}