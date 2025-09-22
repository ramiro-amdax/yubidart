package net.archethic.yubikit_android

import android.app.Activity
import android.content.Context
import android.nfc.NfcAdapter
import androidx.annotation.NonNull
import com.yubico.yubikit.android.YubiKitManager
import com.yubico.yubikit.android.transport.nfc.NfcConfiguration
import com.yubico.yubikit.android.transport.usb.UsbConfiguration
import com.yubico.yubikit.core.smartcard.SW.*
import com.yubico.yubikit.core.smartcard.SmartCardConnection
import com.yubico.yubikit.piv.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.KeyFactory
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.security.spec.X509EncodedKeySpec
import java.util.*

/** YubikitAndroidPlugin */
class YubikitAndroidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var yubikitManager: YubiKitManager

    override fun onAttachedToEngine(
        @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "net.archethic/yubidart")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        yubikitManager = YubiKitManager(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isNfcEnabled" -> {
                val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(context)
                result.success(adapter != null && adapter.isEnabled)
            }

            "pivCalculateSecret" -> {
                val arguments = call.arguments as? HashMap<String, Any>
                val pin = arguments?.get("pin") as? String
                val slot =
                    when (val rawSlot = arguments?.get("slot") as? Int) {
                        null -> null
                        else -> Slot.fromValue(rawSlot)
                    }
                val message = arguments?.get("message") as? ByteArray

                if (pin == null || slot == null || message == null) {
                    result.error(
                        YubikitError.dataError.code,
                        "Data or format error",
                        call.arguments,
                    )
                    return
                }

                readYubiKey(result, pin) { pivSession ->
                    val signatureAlgorithm = Signature.getInstance("SHA256withECDSA")
                    val secret =
                        pivSession.sign(slot, KeyType.ECCP256, message, signatureAlgorithm)
                    result.success(secret)
                }
            }

            "pivGenerateKey" -> {
                val arguments = call.arguments as? HashMap<String, Any>
                val pin = arguments?.get("pin") as? String
                val managementKey = arguments?.get("managementKey") as? ByteArray
                val managementKeyType =
                    when (val rawManagementKeyType = arguments?.get("managementKeyType") as? Int
                    ) {
                        null -> null
                        else -> ManagementKeyType.fromValue(rawManagementKeyType.toByte())
                    }
                val slot =
                    when (val rawSlot = arguments?.get("slot") as? Int) {
                        null -> null
                        else -> Slot.fromValue(rawSlot)
                    }
                val keyType =
                    when (val rawKeyType = arguments?.get("type") as? Int) {
                        null -> null
                        else -> KeyType.fromValue(rawKeyType)
                    }
                val pinPolicy =
                    when (val rawPinPolicy = arguments?.get("pinPolicy") as? Int) {
                        null -> null
                        else -> PinPolicy.fromValue(rawPinPolicy)
                    }
                val touchPolicy =
                    when (val rawTouchPolicy = arguments?.get("touchPolicy") as? Int) {
                        null -> null
                        else -> TouchPolicy.fromValue(rawTouchPolicy)
                    }

                if (pin == null ||
                    managementKey == null ||
                    slot == null ||
                    keyType == null ||
                    pinPolicy == null ||
                    touchPolicy == null
                ) {
                    result.error(
                        YubikitError.dataError.code,
                        "Data or format error",
                        call.arguments,
                    )
                    return
                }

                readYubiKey(result, pin) { pivSession ->
                    val keyTypeFromMetadata = pivSession.managementKeyMetadata.keyType
                    pivSession.authenticate(
                        managementKeyType ?: keyTypeFromMetadata,
                        managementKey,
                    )
                    val publicKey =
                        pivSession.generateKey(
                            slot,
                            keyType,
                            pinPolicy,
                            touchPolicy,
                        )
                    result.success(publicKey.encoded)
                }
            }

            "pivGetCertificate" -> {
                val arguments = call.arguments as? HashMap<String, Any>
                val pin = arguments?.get("pin") as? String
                val slot =
                    when (val rawSlot = arguments?.get("slot") as? Int) {
                        null -> null
                        else -> Slot.fromValue(rawSlot)
                    }

                if (pin == null || slot == null) {
                    result.error(
                        YubikitError.dataError.code,
                        "Data or format error",
                        call.arguments,
                    )
                    return
                }

                readYubiKey(result, pin) { pivSession ->
                    val certificate = pivSession.getCertificate(slot)
                    result.success(certificate.encoded)
                }
            }

            "pivGetPublicKey" -> {
                val arguments = call.arguments as? HashMap<String, Any>
                val pin = arguments?.get("pin") as? String
                val slot =
                    when (val rawSlot = arguments?.get("slot") as? Int) {
                        null -> null
                        else -> Slot.fromValue(rawSlot)
                    }

                if (pin == null || slot == null) {
                    result.error(
                        YubikitError.dataError.code,
                        "Data or format error",
                        call.arguments,
                    )
                    return
                }

                readYubiKey(result, pin) { pivSession ->
                    val certificate = pivSession.getCertificate(slot)
                    android.util.Log.d(
                        "YubikitAndroidPlugin",
                        "publicKey: ${certificate.publicKey.encoded}"
                    )
                    val publicKey = certificate.publicKey
                    result.success(publicKey.encoded)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        disableNfcForegroundDispatch()
    }

    override fun onDetachedFromActivity() {
        disableNfcForegroundDispatch()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        disableNfcForegroundDispatch()
    }

    private fun readYubiKey(
        result: Result,
        pin: String,
        doOnRead: (pivSession: PivSession) -> Unit
    ) {
        yubikitManager.startUsbDiscovery(UsbConfiguration()) { device ->
            if (device.hasPermission()) {
                device.requestConnection(SmartCardConnection::class.java) { connectionResult
                    ->
                    guard(result) {
                        val connection = connectionResult.getValue()
                        val piv = PivSession(connection)
                        piv.verifyPin(pin.toCharArray())
                        doOnRead(piv)
                        stopYubikeyDiscovery()
                    }
                }
            }

            device.setOnClosed {
                // Do something when the YubiKey is removed. For now: no-op
            }
        }

        setupNfcForegroundDispatch()
        val nfcConfig = NfcConfiguration().skipNdefCheck(true).timeout(5000)
        yubikitManager.startNfcDiscovery(nfcConfig, activity) { device ->
            device.requestConnection(SmartCardConnection::class.java) { connectionResult ->
                guard(result) {
                    val connection = connectionResult.getValue()
                    val piv = PivSession(connection)
                    piv.verifyPin(pin.toCharArray())
                    doOnRead(piv)
                    stopYubikeyDiscovery()
                }
            }
        }
    }

    private fun stopYubikeyDiscovery() {
        yubikitManager.stopUsbDiscovery()
        yubikitManager.stopNfcDiscovery(activity)
    }

    /**
     * Setup NFC foreground dispatch to handle NFC tags. Ensures we handle the NFC tag in the app and don't show the default NFC dialog.
     */
    private fun setupNfcForegroundDispatch() {
        val nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
        if (nfcAdapter != null && nfcAdapter.isEnabled) {
            val intent = android.content.Intent(activity, activity::class.java).apply {
                addFlags(android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            val pendingIntent = android.app.PendingIntent.getActivity(
                activity, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )

            // Create intent filters for different NFC tag types
            val techDiscoveredFilter =
                android.content.IntentFilter(android.nfc.NfcAdapter.ACTION_TECH_DISCOVERED)
            val tagDiscoveredFilter =
                android.content.IntentFilter(android.nfc.NfcAdapter.ACTION_TAG_DISCOVERED)
            val ndefDiscoveredFilter =
                android.content.IntentFilter(android.nfc.NfcAdapter.ACTION_NDEF_DISCOVERED)

            // Add MIME type filters to catch NDEF tags with URLs
            ndefDiscoveredFilter.addDataType("*/*")

            val filters = arrayOf(techDiscoveredFilter, tagDiscoveredFilter, ndefDiscoveredFilter)

            // Specify the technologies we want to handle
            val techLists = arrayOf(
                arrayOf(android.nfc.tech.IsoDep::class.java.name),
                arrayOf(android.nfc.tech.Ndef::class.java.name)
            )

            nfcAdapter.enableForegroundDispatch(activity, pendingIntent, filters, techLists)
        }
    }

    private fun disableNfcForegroundDispatch() {
        val nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
        nfcAdapter?.disableForegroundDispatch(activity)
    }
}
