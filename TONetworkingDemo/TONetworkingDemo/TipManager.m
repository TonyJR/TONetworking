//
//  TipManager.m
//  Test2
//
//  Created by David on 15/7/29.
//  Copyright (c) 2015年 Jovision. All rights reserved.
//

#import "TipManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation TipManager{
    MBProgressHUD * _progressTip;
    RACDisposable * dispose;
    NSString * lastTip;
}

static TipManager * _sharedManager;

+(instancetype)sharedManager{
    if (!_sharedManager) {
        _sharedManager = [[TipManager alloc] init];
    }
    return _sharedManager;
}

-(void)showProgress:(NSString *) progressMessage{
    if ([NSThread isMainThread]) {
        [self showProgressMainThread:progressMessage];
    }else{
        [self performSelectorOnMainThread:@selector(showProgressMainThread:) withObject:progressMessage waitUntilDone:YES];
    }
}

-(void)showProgressMainThread:(NSString *)progressMessage{
    if (dispose) {
        [dispose dispose];
        dispose = nil;
    }
    
    lastTip = progressMessage;
    
    if (!progressMessage) {
        progressMessage = self.forceTip;
    }
    
    if (progressMessage) {
        self.progressTip.labelText = progressMessage;
        [self.progressTip show:NO];
    }else{
         dispose = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
             
             [subscriber sendCompleted];
             return nil;
            

        }] delay:0.1] subscribeCompleted:^{
            [self.progressTip hide:NO];
        }];
        
    }
}

+(void)showTip:(NSString *)tipMessage{
    [[self sharedManager] performSelectorOnMainThread:@selector(showTipThread:) withObject:tipMessage waitUntilDone:NO];
}

-(void)showTipThread:(NSString *)tipMessage{
    if (!tipMessage || tipMessage.length == 0) {
        return;
    }
    
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    
//    for (UIWindow * temp in [UIApplication sharedApplication].windows) {
//        if (!window) {
//            window = temp;
//        }else if(window.windowLevel < temp.windowLevel){
//            window = temp;
//        }
//    }
    
    MBProgressHUD * HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.yOffset = window.frame.size.height/2 - 100;
    
    HUD.labelText = tipMessage;
    HUD.dimBackground = NO;
    HUD.backgroundColor = [UIColor clearColor];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.userInteractionEnabled = NO;
    HUD.animationType = MBProgressHUDAnimationZoom;
    [window addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
}

+(void)debugTip:(NSString *) tipMessage{
    //[self showTip:tipMessage];
}

-(MBProgressHUD *)progressTip{
    if (!_progressTip) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        
        if (window) {
            _progressTip = [[MBProgressHUD alloc] initWithView:window];
            _progressTip.dimBackground = YES;
            _progressTip.labelText = @"加载中...";
            
            [window addSubview:_progressTip];
        }
        
    }
    return _progressTip;
}

-(void)setForceTip:(NSString *)forceTip{
    _forceTip = forceTip;
    if (forceTip) {
        [self showProgress:forceTip];
    }else{
        [self showProgress:lastTip];
    }
}

@end
