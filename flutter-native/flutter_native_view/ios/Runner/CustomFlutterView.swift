//
//  File.swift
//  Runner
//
//  Created by a on 2021/1/5.
//

import Foundation
import Flutter

class CustomFlutterView:NSObject,  FlutterPlatformView {
    
    let label = UILabel()
    
    init(_ frame: CGRect, viewID: Int64, params: Any?, messenger: FlutterBinaryMessenger) {
        super.init()
        if(params is NSDictionary){
            let dict = params as! NSDictionary
            label.text = "\(dict.value(forKey: "init") as? String ?? "")点击发送数据给Flutter"
        }
        
        let methodChannel = FlutterMethodChannel(name: "com.mufeng.flutter_native_view", binaryMessenger: messenger)
        methodChannel.setMethodCallHandler {(call, result) in
            if(call.method == "updateText"){
                if let dict = call.arguments as? Dictionary<String, Any>{
                    let author: String = dict["author"] as? String ?? ""
                    self.label.text = "Hello, \(author), 点击发送数据给Flutter"
                }
            }
        }
        
        label.addOnClick{ (view) in
            var arguments = Dictionary<String, Any>()
            arguments["text"] = "CustomFlutterView_\(viewID)"
            methodChannel.invokeMethod("sendMsgToFlutter", arguments: arguments)
        }
    }
    
    func view() -> UIView {
        return label
    }
    
}
