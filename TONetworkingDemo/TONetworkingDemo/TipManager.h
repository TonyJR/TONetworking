//
//  TipManager.h
//  Test2
//
//  Created by David on 15/7/29.
//  Copyright (c) 2015年 Jovision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface TipManager : NSObject

+(instancetype)sharedManager;

-(void)showProgress:(NSString *) progressMessage;

+(void)showTip:(NSString *) tipMessage;
+(void)debugTip:(NSString *) tipMessage;

@property (nonatomic,strong) NSString * forceTip;
@property (nonatomic,strong,readonly) MBProgressHUD * progressTip;

//加载提示 (打断式提醒)
#define progressListenTo(TARGET , KEYPATH) \
({ \
[RACObserve(TARGET, KEYPATH)\
subscribeNext:^(NSString* x){\
[[TipManager sharedManager] showProgress:x];\
}];\
})

//非打断提醒
#define tipListenTo(TARGET, KEYPATH) \
({ \
[RACObserve(TARGET, KEYPATH)\
subscribeNext:^(NSString* x){\
if (x) {\
[TipManager showTip:x];\
}\
}];\
})


@end
