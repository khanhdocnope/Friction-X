package com.frictionx.app.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Intent
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import com.frictionx.app.bridge.NativeBridgeHandler

class AppTrackerAccessibilityService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    private var isScrollLagEnabled = false
    private var lastScrollTime = 0L

    companion object {
        var instance: AppTrackerAccessibilityService? = null
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    fun setScrollLagEnabled(enabled: Boolean) {
        this.isScrollLagEnabled = enabled
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            // 1. PhÃ¡t hiá»‡n thay Ä‘á»•i á»©ng dá»¥ng trÃªn mÃ n hÃ¬nh (Foreground App Changed)
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString() ?: return
                val className = event.className?.toString() ?: ""

                // Bá» qua cÃ¡c event ná»™i bá»™ cá»§a há»‡ thá»‘ng hoáº·c chÃ­nh Friction-X
                if (packageName != applicationContext.packageName &&
                    !className.startsWith("android.widget.") &&
                    !className.startsWith("android.view.")
                ) {
                    NativeBridgeHandler.broadcastForegroundApp(packageName)
                }
            }

            // 2. Cháº·n & lÃ m giáº­t lag thao tÃ¡c cuá»™n (Scroll Lag / Stutter Injection)
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                if (isScrollLagEnabled) {
                    injectScrollResistance()
                }
            }
        }
    }

    /**
     * BÆ¡m lá»±c cáº£n cuá»™n: Khi ngÆ°á»i dÃ¹ng cuá»™n, service báº¯t vÃ  phÃ¡t má»™t micro-gesture
     * ngÆ°á»£c chiá»u nháº¹ hoáº·c ngáº¯t nhá»‹p cuá»™n khiáº¿n thao tÃ¡c trá»Ÿ nÃªn cá»±c ká»³ khÃ³ chá»‹u.
     */
    private fun injectScrollResistance() {
        val now = System.currentTimeMillis()
        if (now - lastScrollTime < 180) {
            // Throttling scroll speed via reverse micro-stroke
            val path = Path()
            val metrics = resources.displayMetrics
            val midX = (metrics.widthPixels / 2).toFloat()
            val midY = (metrics.heightPixels / 2).toFloat()

            // Micro nudge
            path.moveTo(midX, midY)
            path.lineTo(midX, midY - 15)

            val stroke = GestureDescription.StrokeDescription(path, 0, 50)
            val gesture = GestureDescription.Builder().addStroke(stroke).build()
            dispatchGesture(gesture, null, null)
        }
        lastScrollTime = now
    }

    /**
     * HÃ m há»— trá»£ Hard Block cáº¥p há»‡ thá»‘ng: Äáº©y ngÆ°á»i dÃ¹ng vÄƒng ngay vá» mÃ n hÃ¬nh Home
     */
    fun kickToHomeScreen() {
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    override fun onInterrupt() {
        // Accessibility interrupted
    }
}
