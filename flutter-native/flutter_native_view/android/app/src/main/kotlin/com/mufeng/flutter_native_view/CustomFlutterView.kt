package com.mufeng.flutter_native_view

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import com.mufeng.flutter_native_view.databinding.CustomFlutterViewBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class CustomFlutterView(private val context: Context, messenger: BinaryMessenger, private val viewId: Int, params: Map<String, Any>?): PlatformView,  MethodChannel.MethodCallHandler{


    private var binding: CustomFlutterViewBinding = CustomFlutterViewBinding.inflate(LayoutInflater.from(context))
    private var methodChannel: MethodChannel

    init {
        params?.also { binding.tvReceiverFlutterMsg.text = it["init"] as String }
        methodChannel = MethodChannel(messenger, "com.mufeng.flutter_native_view")
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        binding.sendMsgToFlutter.setOnClickListener {
            methodChannel.invokeMethod("sendMsgToFlutter", mapOf("text" to "Hello, CustomFlutterView_$viewId"))
        }
        return binding.root
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        Log.e("TAG", "释放资源")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "updateText") {
            val author = call.argument("author") as String?

            binding.tvReceiverFlutterMsg.text = "Hello, $author"
        } else {
            result.notImplemented()
        }
    }
}