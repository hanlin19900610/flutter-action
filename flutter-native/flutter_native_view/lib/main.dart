import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  static const platform =
  const MethodChannel('com.mufeng.flutter_native_view');

  String result;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) {
      setState(() {
        result = call.arguments['text'];
      });
      print("接收到Native传递的数据: ${call.arguments['text']}");
      return;
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget platformView() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return AndroidView(
          viewType: "com.mufeng.flutter_native_view/custom_platform_view",
          creationParams: {'init': '来自Flutter传递的初始化参数'},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (viewId) {
            print('View 创建完成; ViewId: $viewId');
          },
        );
      }else if(defaultTargetPlatform == TargetPlatform.iOS){
        return UiKitView(
          viewType: "com.mufeng.flutter_native_view/custom_platform_view",
          creationParams: {'init': '来自Flutter传递的初始化参数'},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (viewId) {
            print('View 创建完成; ViewId: $viewId');
          },
        );
      }else{
        return Text('暂不支持的平台类型');
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Platform View',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextButton(onPressed: () {
            platform.invokeMethod('updateText', {'author': 'MuFeng'});
          }, child: Text('传递参数给原生View')),
          Text(result??'等待Native发送的数据'),
          Expanded(child: platformView()),
        ],
      ),
    );
  }
}
