package ani.aayush262.dartotsu

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.content.pm.verify.domain.DomainVerificationManager
import android.content.pm.verify.domain.DomainVerificationUserState
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Rational
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var volumeChannel: MethodChannel? = null
    private var interceptVolume = false
    private var pipChannel: MethodChannel? = null
    private var pipAuto = false
    private var pipRatio = Rational(16, 9)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(NativeLogger())
        volumeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dartotsu/volumekeys").also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != "setEnabled") return@setMethodCallHandler result.notImplemented()
                interceptVolume = call.arguments as? Boolean ?: false
                result.success(null)
            }
        }
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dartotsu/pip").also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "supported" -> result.success(pipSupported())
                    "enter" -> {
                        updateRatio(call.argument<Int>("width"), call.argument<Int>("height"))
                        result.success(enterPip())
                    }
                    "setAuto" -> {
                        pipAuto = call.arguments as? Boolean ?: false
                        applyPipParams()
                        result.success(null)
                    }
                    "setRatio" -> {
                        updateRatio(call.argument<Int>("width"), call.argument<Int>("height"))
                        applyPipParams()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dartotsu/links")
            .setMethodCallHandler { call, result ->
                if (call.method == "isLinkHandlingEnabled") {
                    return@setMethodCallHandler result.success(isLinkHandlingEnabled())
                }
                if (call.method != "openLinkSettings") return@setMethodCallHandler result.notImplemented()
                val uri = Uri.parse("package:$packageName")
                val action = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
                    Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
                else Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                try {
                    startActivity(Intent(action, uri))
                    result.success(true)
                } catch (e: Exception) {
                    try {
                        startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, uri))
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
            }
    }

    private fun pipSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun updateRatio(width: Int?, height: Int?) {
        if (width == null || height == null || width <= 0 || height <= 0) return
        val ratio = width.toDouble() / height
        pipRatio = if (ratio in 0.42..2.38) Rational(width, height) else Rational(16, 9)
    }

    private fun pipParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val builder = PictureInPictureParams.Builder().setAspectRatio(pipRatio)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(pipAuto).setSeamlessResizeEnabled(false)
        }
        return builder.build()
    }

    private fun applyPipParams() {
        val params = pipParams() ?: return
        try {
            setPictureInPictureParams(params)
        } catch (e: Exception) {
        }
    }

    private fun enterPip(): Boolean {
        val params = pipParams() ?: return false
        return try {
            enterPictureInPictureMode(params)
        } catch (e: Exception) {
            false
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipAuto && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) enterPip()
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        pipChannel?.invokeMethod("changed", isInPictureInPictureMode)
    }

    private fun isLinkHandlingEnabled(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        return try {
            val manager = getSystemService(DomainVerificationManager::class.java)
            val state = manager.getDomainVerificationUserState(packageName)
            val hosts = state?.hostToStateMap ?: return true
            val value = hosts["anilist.co"] ?: return true
            value != DomainVerificationUserState.DOMAIN_STATE_NONE
        } catch (e: Exception) {
            true
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val code = event.keyCode
        if (interceptVolume && (code == KeyEvent.KEYCODE_VOLUME_UP || code == KeyEvent.KEYCODE_VOLUME_DOWN)) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                volumeChannel?.invokeMethod("key", if (code == KeyEvent.KEYCODE_VOLUME_UP) "up" else "down")
            }
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        CrashHandler.init(this)
        super.onCreate(savedInstanceState)
    }
}
