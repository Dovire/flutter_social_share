package com.dovireinfotech.flutter_social_share

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** FlutterSocialSharePlugin */
class FlutterSocialSharePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    
    // The MethodChannel that will handle communication between Flutter and native Android
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var facebookShareHandler: FacebookShareHandler? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_social_share")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initializeFacebook" -> {
                handleFacebookInitialize(call, result)
            }
            "shareImageToFacebook" -> {
                handleFacebookShareImage(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleFacebookInitialize(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        val clientToken = call.argument<String>("clientToken")
        
        if (appId == null || clientToken == null) {
            result.error("INVALID_ARGUMENTS", "App ID and Client Token are required", null)
            return
        }
        
        context?.let { ctx ->
            facebookShareHandler = FacebookShareHandler(ctx)
            facebookShareHandler?.initialize(appId, clientToken, result)
        } ?: result.error("NO_CONTEXT", "Application context not available", null)
    }

    private fun handleFacebookShareImage(call: MethodCall, result: Result) {
        val imagePath = call.argument<String>("imagePath")
        val caption = call.argument<String>("caption")
        
        if (imagePath == null) {
            result.error("INVALID_ARGUMENTS", "Image path is required", null)
            return
        }
        
        activity?.let { act ->
            facebookShareHandler?.shareImage(act, imagePath, caption, result)
        } ?: result.error("NO_ACTIVITY", "Activity not available for sharing", null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        facebookShareHandler = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // Forward activity results to Facebook CallbackManager
        return FacebookCallbackManager.getInstance().onActivityResult(requestCode, resultCode, data)
    }
}
