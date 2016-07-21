//
//  TONetwork+TaskLifeCycle.m
//  coco3g
//
//  Created by Tony on 16-01-06.
//  Copyright (c) 2015年 Tony. All rights reserved.
//

#import <TouchJSON/CJSONDeserializer.h>
#import "AppDelegate.h"
#import "TONetwork.h"
#import "TipManager.h"

@implementation TONetwork (TaskLifeCycle)


//类别中扩展属性




//如需在请求时特殊处理，请使用类别覆盖下面三个方法
//返回值将决定是否通知owner
-(BOOL)afterTask:(TOTask *) task
{
    if(task.responseData){
        
        // 去除回车与空格
        task.responseString = [task.responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // 赋值
        NSData * jsonData = task.responseData;
        
        
        if (task.responseStatusCode == 200) {
            //        if (YES){
            NSError * error = nil;
            
            task.responseInfo = [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
            
            task.responseInfo = [self clearString:task.responseInfo];
            
            
            if (error) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"  message:@"数据解析失败" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"好的"  style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    
                }]];
                
                
                UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                [root presentViewController:alertController animated:YES completion:nil];
                
                NSLog(@"数据解析失败：\n%@",task.responseString);
                return NO;
            }else{
                NSLog(@"请求结果：\n%@",task.responseInfo);
            }
            
            id result = task.responseInfo;
            
            
            
            int errorCode = [result[@"error_code"] intValue];
            
            if (errorCode != 0) {
                
                if (task.needTip) {
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"  message:result[@"reason"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"好的"  style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        
                    }]];
                    UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
                    
                    [root presentViewController:alertController animated:YES completion:nil];
                }
                
                
                
                
                
                return NO;
            }else{
                return YES;
                
            }
            
            
            
        }else if (task.responseStatusCode == 0){
            if (task.needTip) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"  message:@"网络错误请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"好的"  style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    
                }]];
                
                
                UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                [root presentViewController:alertController animated:YES completion:nil];
            }
            
            return NO;
            
        }else{
            if (task.needTip) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"  message:[NSString stringWithFormat:@"HTTP请求失败 (ErrorCode:%d)",task.responseStatusCode] preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"好的"  style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    
                }]];
                
                
                UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                [root presentViewController:alertController animated:YES completion:nil];
                
                
            }
            
            NSLog(@"error: path[%@]",task.path);
            
            return NO;
            
        }
    }else {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"  message:@"网络错误请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的"  style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
        }]];
        
        UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:alertController animated:YES completion:nil];
        
        return NO;

    }
}


-(void)beforeTask:(TOTask *)task{
    for (NSString * key in task.parames.allKeys) {
        id item = task.parames[key];
        if ([item isKindOfClass:[NSNumber class]]) {
            task.parames[key] = [NSString stringWithFormat:@"%@",item];
        }
    }
}

-(BOOL)errorTask:(TOTask *) task{
    return YES;
}


-(id)clearString:(id)target{
    if ([target isKindOfClass:[NSArray class]]) {
        NSMutableArray * resultArr = [NSMutableArray array];
        NSArray * temp = target;
        for (id item in temp) {
            [resultArr addObject:[self clearString:item]];
        }
        
        return resultArr;
        
    }else if([target isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
        NSDictionary * temp = target;
        for (NSString * key in temp.allKeys) {
            if ([temp[key] isKindOfClass:[NSNumber class]]){
                NSString * str = [NSString stringWithFormat:@"%@",temp[key]];
                [resultDic setValue:str forKey:key];
            }else if([temp[key] isKindOfClass:[NSDictionary class]]){
                [resultDic setValue:[self clearString:temp[key]] forKey:key];
                
            }else if([temp[key] isKindOfClass:[NSArray class]]){
                
                [resultDic setValue:[self clearString:temp[key]] forKey:key];
                
            }else{
                [resultDic setValue:temp[key] forKey:key];
            }
        }
        
        return resultDic;
    }else{
        return target;
    }
}






@end
