package ani.aayush262.dartotsu

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.content.pm.verify.domain.DomainVerificationManager
import android.content.pm.verify.domain.DomainVerificationUserState
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.KeyEvent
import fl.pip.FlPiPActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlPiPActivity() {
    private var volumeChannel: MethodChannel? = null
    private var interceptVolume = false

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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dartotsu/network")
            .setMethodCallHandler { call, result ->
                if (call.method != "isMetered") return@setMethodCallHandler result.notImplemented()
                val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                result.success(manager.isActiveNetworkMetered)
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dartotsu/downloads")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> try {
                        DownloadForegroundService.start(
                            this,
                            call.argument<String>("title") ?: "Downloads",
                            call.argument<String>("text") ?: "",
                            call.argument<Int>("percent") ?: -1,
                            call.argument<String>("sub"),
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                    "stop" -> {
                        DownloadForegroundService.stop(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
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
