package com.frictionx.app.services

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager

/**
 * Service hiá»ƒn thá»‹ lá»›p phá»§ mÃ n hÃ¬nh (Overlay Window)
 * 1. Cháº¿ Ä‘á»™ Grayscale: Phá»§ má»™t layer Ä‘Æ¡n sáº¯c bÃ£o hÃ²a 0 lÃªn toÃ n bá»™ mÃ n hÃ¬nh
 * 2. CÃ¡c cÃ¡nh cá»•ng Kiosk / Hostage Block
 */
class GrayscaleOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    companion object {
        const val ACTION_ENABLE_GRAYSCALE = "com.frictionx.ENABLE_GRAYSCALE"
        const val ACTION_DISABLE_GRAYSCALE = "com.frictionx.DISABLE_GRAYSCALE"
        var isGrayscaleActive = false
            private set
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_ENABLE_GRAYSCALE -> showGrayscaleOverlay()
            ACTION_DISABLE_GRAYSCALE -> removeGrayscaleOverlay()
        }
        return START_STICKY
    }

    private fun showGrayscaleOverlay() {
        if (overlayView != null) return

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        // View vẽ bộ lọc đơn sắc (Grayscale Saturation = 0)
        overlayView = View(this).apply {
            val paint = Paint()
            val colorMatrix = ColorMatrix().apply {
                setSaturation(0f) // Triệt tiêu toàn bộ màu sắc, chuyển về Trắng Đen
            }
            paint.colorFilter = ColorMatrixColorFilter(colorMatrix)
            setLayerType(View.LAYER_TYPE_HARDWARE, paint)
        }

        try {
            windowManager?.addView(overlayView, params)
            isGrayscaleActive = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun removeGrayscaleOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
            isGrayscaleActive = false
        }
    }

    override fun onDestroy() {
        removeGrayscaleOverlay()
        super.onDestroy()
    }
}
