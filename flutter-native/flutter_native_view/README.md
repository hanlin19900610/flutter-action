![](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimages.h128.com%2Fupload%2F201905%2F22%2F201905221233400129.jpg%3Fx-oss-process%3Dimage%2Fresize%2Cm_lfit%2Cw_1421%2Fquality%2Cq_100%2Fformat%2Cjpg&refer=http%3A%2F%2Fimages.h128.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1612266726&t=52dc9e3a48072529e4a69bb86fa843b2)
### 什么是Platform View
> 为了能让一些现有的Native控件直接引用到Flutter App中，Flutter团队提供了Platform View，允许Native View嵌入到Flutter Widget体系中，完成Dart代码对Native View的控制。<br>
> Platform View主要包括：***AndroidView***和***UIKitView***

### 如何使用Platform View
#### AndroidView

```
class AndroidView extends StatefulWidget {
  
  const AndroidView({
    Key key,
    @required this.viewType,
    this.onPlatformViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.gestureRecognizers,
    this.creationParams,
    this.creationParamsCodec,
  }) : assert(viewType != null),
       assert(hitTestBehavior != null),
       assert(creationParams == null || creationParamsCodec != null),
       super(key: key);

  /// 嵌入Android视图的唯一标识符
  final String viewType;
  /// Platform View创建完成的回调
  final PlatformViewCreatedCallback onPlatformViewCreated;
  /// hit测试期间的行为
  final PlatformViewHitTestBehavior hitTestBehavior;
  /// 视图的文本方向
  final TextDirection layoutDirection;
  /// 用于处理时间冲突，对时间进行分发管理相关操作
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  /// 传给Android视图的参数，在Android视图构造的时候使用
  final dynamic creationParams;
  /// 对creationParams参数传递时进行的编码规则，如果creationParams不为null，该值必须不为null
  final MessageCodec<dynamic> creationParamsCodec;

  @override
  State<AndroidView> createState() => _AndroidViewState();
}
```
> 需要注意的是：<br>
> - AndroidView仅支持Android API 20以上
> - 在Flutter中使用AndroidView对性能的开销比较大，应该尽量的避免使用


用Android Studio打开创建好的Flutter项目，在Android Studio顶部菜单Tools->Flutter->Open for Editing in Android Studio,
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view1.jpg)
点击即可打开一个Android项目，包含引入的三方库:
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view2.jpg)
在主项目中，创建用于嵌入Flutter中的Android View，此View继成自PlatformView：
```

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
```
- **getView()**: 返回要嵌入Flutter层次结构的Android View
- **dispose**: 释放此VIew时调用，此方法调用后View不可用，此方法需要清除所有对象引用，否则会造成内存泄漏
- **messenger**：用于消息传递，Flutter与原生通信时会用到此参数
- **viewId**： View生成时会分配一个唯一ID
- **args**：Flutter传递的初始化参数

##### 注册PlatformView
创建一个PlatformViewFactory：
```
class CustomFlutterViewFactory(private val messenger: BinaryMessenger):  PlatformViewFactory(StandardMessageCodec.INSTANCE){
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return CustomFlutterView(context, messenger, viewId, args as Map<String, Any>)
    }
}
```
创建**CustomPlugin**：
```
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
```
> 注意：***VIEW_TYPE_ID*** 这个字符串需要和Flutter端保持一致

在App中MainActivity中注册：
```
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(CustomPlugin())
    }
}
```
> 需要注意的是，如果我们是在开发Flutter Plugin时，是没有MainActivity的，则需要在对应的Plugin类下的**onAttachedToEngine()** 方法和**registerWith()**方法下修改
##### 在Flutter中调用
```

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

```
查看在Android中的运行效果：
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_001.jpeg)
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_002.jpeg)
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_003.jpeg)


#### UIKitView
```
class UiKitView extends StatefulWidget {
  
  const UiKitView({
    Key key,
    @required this.viewType,
    this.onPlatformViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.creationParams,
    this.creationParamsCodec,
    this.gestureRecognizers,
  }) : assert(viewType != null),
       assert(hitTestBehavior != null),
       assert(creationParams == null || creationParamsCodec != null),
       super(key: key);
  /// 嵌入iOS视图的唯一标识符
  final String viewType;
  /// Platform View创建完成的回调
  final PlatformViewCreatedCallback onPlatformViewCreated;
  /// hit测试期间的行为
  final PlatformViewHitTestBehavior hitTestBehavior;
  /// 视图的文本方向
  final TextDirection layoutDirection;
  /// 传给iOS视图的参数，在Android视图构造的时候使用
  final dynamic creationParams;
  /// 对creationParams参数传递时进行的编码规则，如果creationParams不为null，该值必须不为null
  final MessageCodec<dynamic> creationParamsCodec;
  /// 用于处理时间冲突，对时间进行分发管理相关操作
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<UiKitView> createState() => _UiKitViewState();
}
```
需要使用Xcode进行开发，用Android Studio打开创建好的Flutter项目，在Android Studio顶部菜单Tools->Flutter->Open iOS module in Xcode,点击即可打开一个iOS项目

第一步，在Runner目录下创建iOS View，此View继承FlutterPlatformView
```

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

```
第二步，创建CustomFlutterViewFactory：
```

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
```
第三步，在AppDelegate中注册：
```
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  let VIEW_TYPE_ID: String = "com.mufeng.flutter_native_view/custom_platform_view"
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let registrar: FlutterPluginRegistrar = self.registrar(forPlugin: VIEW_TYPE_ID)!
    let factory = CustomFlutterViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: VIEW_TYPE_ID)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
> 注意：***VIEW_TYPE_ID*** 这个字符串需要和Flutter端保持一致

第四步，在Flutter中调用
```

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
      }else if(defaultTargetPlatform == TargetPlatform.android){
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

```
查看在iOS中的运行效果：
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_ios1.png)
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_ios2.png)
![](https://gitee.com/andlin/learning-notes/raw/master/screenshot/flutter_native_view_ios3.png)

本文代码地址<br>
https://github.com/hanlin19900610/flutter-action/tree/main/flutter-native/flutter_native_view/flutter_native_view

> 以上只是Platform View的简单的使用，更加详细的使用，请参考一下资料：<br>
> [嵌入原生View-Android](http://laomengit.com/guide/mixing/AndroidView.html)<br>
> [嵌入原生View-IOS](http://laomengit.com/guide/mixing/UiKitView.html)<br>
> [在Flutter中嵌入Native组件的正确姿势
](https://developer.aliyun.com/article/669831)<br>
> [万万没想到——Flutter外接纹理](https://zhuanlan.zhihu.com/p/42566807)


