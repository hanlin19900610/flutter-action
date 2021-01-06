//
//  CustomFlutterViewFactory.swift
//  Runner
//
//  Created by a on 2021/1/5.
//

import Foundation
import Flutter

class CustomFlutterViewFactory: NSObject, FlutterPlatformViewFactory {
    var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments params: Any?) -> FlutterPlatformView{
        return CustomFlutterView(frame, viewID: viewId, params: params, messenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
            return FlutterStandardMessageCodec.sharedInstance()
        }
}
