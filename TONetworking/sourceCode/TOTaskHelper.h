//
//  TOTaskHelper.h
//  TOFramework_demo
//
//  Created by Tony on 16/7/15.
//  Copyright © 2016年 Tony. All rights reserved.
//

#ifndef TOTaskHelper_h
#define TOTaskHelper_h

@class TOTask;

@protocol TOTaskHelper<NSObject>


@required
+ (void)startTask:(nonnull TOTask *)task
        progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
        complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler;

@optional
+ (void)beforeTask:(nonnull TOTask *)task;
+ (BOOL)afterTask:(nonnull TOTask *)task;


@end

#endif /* TOTaskHelper_h */

