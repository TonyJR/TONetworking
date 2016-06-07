# TONetworking
==============

[![CocoaPods](https://img.shields.io/cocoapods/v/TONetworking.svg?style=flat)](http://cocoapods.org/?q=name%3ATONetworking)
基于HTTP协议的任务系统。对多个请求任务进行管理，轻松处理任务队列、并发任务、任务进度、互斥任务等情况。

TONetworking本身不处理网络请求，它只是帮助你对请求进行管理。
统一管理加载提示、请求失败时的提示、应答报文的格式化、应答结果归类。
大多数情况下，你不需要在业务代码中为失败分支写任何代码，只需要把精力集中在正常分支即可。

使用前提，您的服务器端接口需要提供标示请求成功或失败的字段，最好返回的是错误码（ErrorCode），每种错误都有唯一标识。

Installation
------------
Use [CocoaPods](http://cocoapods.org).

```ruby
pod 'AFNetworking'
pod 'Reachability'
pod 'TONetworking'


#数据解析库，根据需要选择
pod 'TouchJSON'
```

拷贝 [TONetworking+TaskLifeCycle.m](https://github.com/TonyJR/TONetworking/blob/master/TONetworkingDemo/TONetworkingDemo/TONetwork%2BTaskLifeCycle.m) 到项目中。根据需要，修改-(BOOL)afterTask:(TOTask *)task

Optional
--------
如需要显示加载提示框，按照下面步骤操作

1、安装
```ruby
pod 'AFNetworking'
pod 'Reachability'
pod 'TONetworking'

#数据解析库，根据需要选择
pod 'TouchJSON'

#用于显示加载提示
pod 'MBProgressHUD'
pod 'ReactiveCocoa'
```

2、拷贝 [TONetworking+TaskLifeCycle.m](https://github.com/TonyJR/TONetworking/blob/master/TONetworkingDemo/TONetworkingDemo/TONetwork%2BTaskLifeCycle.m)、[TipManager.h](https://github.com/TonyJR/TONetworking/blob/master/TONetworkingDemo/TONetworkingDemo/TipManager.h)、[TipManager.m](https://github.com/TonyJR/TONetworking/blob/master/TONetworkingDemo/TONetworkingDemo/TipManager.m) 到项目中。根据需要，修改-(BOOL)afterTask:(TOTask *)task

3、AppDelegate 中加入如下代码

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//加载提示 (打断式提醒————UIAlertController)
progressListenTo([TONetwork sharedNetwork], message);
//错误提示 (非打断提醒————MBProgressBar)
tipListenTo([TONetwork sharedNetwork], tip);
return YES;
}
```

Usage
-----

```objc
TOTask * task = [[TOTask alloc] initWithPath:@"http://apis.juhe.cn/cook/query.php" parames:nil taskOver:^(TOTask *task) {
    NSLog(@"请求成功");
}];
[task addParam:@"红烧肉" forKey:@"menu"];
[task addParam:@"11c512b272925b6c765faf23d3472a13" forKey:@"key"];
[task startAtOnce];
```



License
-------
UITextView+PlaceholderExt is under MIT license. See LICENSE for more information.