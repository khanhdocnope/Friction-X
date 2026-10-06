package com.frictionx.app

import android.os.Bundle
import com.frictionx.app.bridge.NativeBridgeHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Đăng ký Native Bridge giữa Flutter và Android Services
        NativeBridgeHandler.registerWith(flutterEngine.dartExecutor.binaryMessenger, context)
    }
}
