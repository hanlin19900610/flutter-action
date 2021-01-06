package com.mufeng.flutter_native_view

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry

class CustomPlugin : FlutterPlugin {

    companion object {

        const val VIEW_TYPE_ID: String = "com.mufeng.flutter_native_view/custom_platform_view"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            registrar.platformViewRegistry()
                    .registerViewFactory(VIEW_TYPE_ID, CustomFlutterViewFactory(registrar.messenger()))
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger: BinaryMessenger = binding.binaryMessenger
        binding.platformViewRegistry.registerViewFactory(VIEW_TYPE_ID, CustomFlutterViewFactory(messenger))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }
}