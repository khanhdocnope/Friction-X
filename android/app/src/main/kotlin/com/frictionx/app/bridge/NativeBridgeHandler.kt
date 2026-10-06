package com.frictionx.app.bridge

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import com.frictionx.app.services.AppTrackerAccessibilityService
import com.frictionx.app.services.GrayscaleOverlayService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NativeBridgeHandler(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private const val METHOD_CHANNEL = "com.frictionx/native_bridge"
        private const val EVENT_CHANNEL = "com.frictionx/app_events"
        private var instance: NativeBridgeHandler? = null

        fun registerWith(messenger: BinaryMessenger, context: Context) {
            val handler = NativeBridgeHandler(context)
            instance = handler
            MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler(handler)
            EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(handler)
        }

        fun broadcastForegroundApp(packageName: String) {
            instance?.eventSink?.success(packageName)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermissions" -> {
                val hasAccessibility = AppTrackerAccessibilityService.instance != null
                val hasOverlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Settings.canDrawOverlays(context)
                } else true
                val hasUsage = checkUsageStatsPermission()

                result.success(
                    mapOf(
                        "hasAccessibility" to hasAccessibility,
                        "hasOverlayPermission" to hasOverlay,
                        "hasUsageStats" to hasUsage
                    )
                )
            }

            "requestPermissions" -> {
                // 1. Mở màn hình trợ năng nếu chưa bật
                if (AppTrackerAccessibilityService.instance == null) {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    context.startActivity(intent)
                }

                // 2. Mở cấp quyền Vẽ đè (Overlay)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:${context.packageName}")
                    ).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    context.startActivity(intent)
                }
                result.success(true)
            }

            "enableGrayscale" -> {
                val intent = Intent(context, GrayscaleOverlayService::class.java).apply {
                    action = GrayscaleOverlayService.ACTION_ENABLE_GRAYSCALE
                }
                context.startService(intent)
                result.success(true)
            }

            "disableGrayscale" -> {
                val intent = Intent(context, GrayscaleOverlayService::class.java).apply {
                    action = GrayscaleOverlayService.ACTION_DISABLE_GRAYSCALE
                }
                context.startService(intent)
                result.success(true)
            }

            "triggerScrollLag" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                AppTrackerAccessibilityService.instance?.setScrollLagEnabled(enabled)
                result.success(true)
            }

            "triggerHardBlockKick" -> {
                AppTrackerAccessibilityService.instance?.kickToHomeScreen()
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun checkUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }
}
