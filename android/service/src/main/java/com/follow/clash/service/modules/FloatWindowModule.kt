package com.follow.clash.service.modules

import android.annotation.SuppressLint
import android.app.Service
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.core.content.getSystemService
import com.follow.clash.common.tickerFlow
import com.follow.clash.core.Core
import com.follow.clash.service.State
import com.follow.clash.service.models.getSpeedTrafficText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch

class FloatWindowModule(private val service: Service) : Module() {
    private val scope = CoroutineScope(Dispatchers.Main)
    private val windowManager by lazy { service.getSystemService<WindowManager>()!! }
    private var floatView: View? = null

    override fun onInstall() {
        scope.launch {
            combine(
                tickerFlow(1000, 0),
                State.notificationParamsFlow
            ) { _, params ->
                params
            }.collect { params ->
                if (params?.showTrafficFloatingWindow == true && Settings.canDrawOverlays(service)) {
                    showOrUpdate(Core.getSpeedTrafficText(params.onlyStatisticsProxy))
                } else {
                    hide()
                }
            }
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun showOrUpdate(text: String) {
        if (floatView == null) {
            val textView = TextView(service).apply {
                this.text = text
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
                setPadding(20, 10, 20, 10)
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#80000000"))
                    cornerRadius = 20f
                }
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                },
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = 100
                y = 100
            }

            textView.setOnTouchListener(object : View.OnTouchListener {
                private var initialX = 0
                private var initialY = 0
                private var initialTouchX = 0f
                private var initialTouchY = 0f

                override fun onTouch(v: View, event: MotionEvent): Boolean {
                    when (event.action) {
                        MotionEvent.ACTION_DOWN -> {
                            initialX = params.x
                            initialY = params.y
                            initialTouchX = event.rawX
                            initialTouchY = event.rawY
                            return true
                        }
                        MotionEvent.ACTION_MOVE -> {
                            params.x = initialX + (event.rawX - initialTouchX).toInt()
                            params.y = initialY + (event.rawY - initialTouchY).toInt()
                            try {
                                windowManager.updateViewLayout(v, params)
                            } catch (_: Exception) {
                            }
                            return true
                        }
                    }
                    return false
                }
            })

            floatView = textView
            try {
                windowManager.addView(floatView, params)
            } catch (_: Exception) {
                floatView = null
            }
        } else {
            (floatView as? TextView)?.text = text
        }
    }

    private fun hide() {
        floatView?.let {
            try {
                windowManager.removeView(it)
            } catch (_: Exception) {
            }
            floatView = null
        }
    }

    override fun onUninstall() {
        hide()
        scope.cancel()
    }
}
