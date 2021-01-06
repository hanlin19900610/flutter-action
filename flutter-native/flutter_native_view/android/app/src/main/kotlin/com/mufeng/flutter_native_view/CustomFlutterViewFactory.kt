package com.mufeng.flutter_native_view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CustomFlutterViewFactory(private val messenger: BinaryMessenger):  PlatformViewFactory(StandardMessageCodec.INSTANCE){
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return CustomFlutterView(context, messenger, viewId, args as Map<String, Any>?)
    }
}