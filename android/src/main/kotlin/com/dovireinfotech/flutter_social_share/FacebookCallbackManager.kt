package com.dovireinfotech.flutter_social_share

import com.facebook.CallbackManager

object FacebookCallbackManager {
    private var callbackManager: CallbackManager? = null
    
    fun getInstance(): CallbackManager {
        if (callbackManager == null) {
            callbackManager = CallbackManager.Factory.create()
        }
        return callbackManager!!
    }
}