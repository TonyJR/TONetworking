//
//  TOHTTPRequestHelper.m
//  TOFramework
//
//  Created by TonyJR on 16/2/19.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "TOHTTPRequestHelper.h"
#import "TOTask.h"
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "TOTaskConfig.h"
#import <objc/runtime.h>

@interface TOTask (HTTPTask)

@property (nonatomic,strong) NSURLSessionDataTask *httpTask;

@end

@implementation TOTask (HTTPTask)

- (void)setHttpTask:(NSURLSessionDataTask *)httpTask{
    objc_setAssociatedObject(self, @"TOTask_HTTPTask", httpTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask *)httpTask{
    return objc_getAssociatedObject(self, @"TOTask_HTTPTask");
}

@end

@interface TOTask ()
@property (nonatomic,strong) NSMutableDictionary *fileNames;

@end

@implementation TOHTTPRequestHelper
static AFHTTPSessionManager *_manager;
+ (AFHTTPSessionManager *)sessionManager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        
        
        // 设置请求格式
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 设置返回格式
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

+(void)startTask:(nonnull TOTask *)task
        progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
        complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    if ([task.method length] == 0) {
        task.method = @"POST";
    }
    
    
    
    if ([task.method isEqualToString:@"GET"]) {
        
        [self doGet:task
           progress:progressHandler
           complete:completeHandler];
    }else if([task.method isEqualToString:@"POST"]){
        [self doPost:task
            progress:progressHandler
            complete:completeHandler];
    }else if([task.method isEqualToString:@"DELETE"]){
        [self doDelete:task
            progress:progressHandler
            complete:completeHandler];
    }else if([task.method isEqualToString:@"PUT"]){
        [self doPut:task
            progress:progressHandler
            complete:completeHandler];
    }
    
    
}

+ (void)doPost:(nonnull TOTask *)task
      progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
      complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    AFHTTPSessionManager *manager = [self sessionManager];
    if (task.usingCache) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }else{
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSArray * keys = task.parames.allKeys;
    
    for (NSString * key in keys) {
        NSObject * item = (NSObject *)(task.parames[key]);
        
        if([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]){
            [dic setObject:item forKey:key];
        }
    }
    
    NSError * error;
    
    
    NSMutableURLRequest * request;
    
    
    request = [manager.requestSerializer multipartFormRequestWithMethod:task.method URLString:[[NSURL URLWithString:task.path relativeToURL:manager.baseURL] absoluteString] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSArray * _keys = task.parames.allKeys;
        
        for (NSString * key in _keys) {
            
            NSObject * item = (NSObject *)(task.parames[key]);
            if ([item isKindOfClass:[NSURL class]]) {
                [formData appendPartWithFileURL:(NSURL *)item name:key fileName:[NSString stringWithFormat:@"%@.file",key] mimeType:task.mimeType error:nil];
                
            }else if ([item isKindOfClass:[NSData class]]) {
                NSString *filename;
                if (task.fileNames[key]) {
                    filename = task.fileNames[key];
                }else{
                    filename = [NSString stringWithFormat:@"%@.file",key];
                }
                [formData appendPartWithFileData:(NSData *)item name:key fileName:filename mimeType:@"multipart/mixed"];
            }else if([item isKindOfClass:[UIImage class]]){
                NSString *filename;
                if (task.fileNames[key]) {
                    filename = task.fileNames[key];
                }else{
                    filename = [NSString stringWithFormat:@"%@.jpg",key];
                }
                
                if ([[filename lowercaseString] rangeOfString:@".png"].location == filename.length - 4) {
                    [formData appendPartWithFileData:UIImagePNGRepresentation((UIImage *)item)
                                                name:key
                                            fileName:filename
                                            mimeType:@"multipart/mixed"];
                }else{
                    [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage *)item,g_image_compression_quality)
                                                name:key
                                            fileName:filename
                                            mimeType:@"multipart/mixed"];
                }
                
                
            }
        }
    } error:&error];
    
    
    request.timeoutInterval = task.timeoutInterval;
    
    if (error) {
        if (completeHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandler(nil,nil, error);
            });
        }
        return;
    }
    
    __block NSURLSessionDataTask * sessionDataTask = [manager uploadTaskWithStreamedRequest:request progress:progressHandler completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        if(completeHandler){
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandler(sessionDataTask,responseObject, error);
            });
        }
        
    }];
    [sessionDataTask resume];
    
    task.httpTask = sessionDataTask;
}

+ (void)doGet:(nonnull TOTask *)task
     progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
     complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    
    AFHTTPSessionManager *manager = [self sessionManager];
    if (task.usingCache) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }else{
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    task.httpTask = [manager GET:task.path
      parameters:task.parames
        progress:progressHandler
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             __block NSURLSessionDataTask * sessionDataTask = task;
             if(completeHandler){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completeHandler(sessionDataTask,responseObject, nil);
                 });
             }
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             __block NSURLSessionDataTask * sessionDataTask = task;
             
             if(completeHandler){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completeHandler(sessionDataTask,nil, error);
                 });
             }
             
         }];
}

+ (void)doPut:(nonnull TOTask *)task
      progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
      complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    AFHTTPSessionManager *manager = [self sessionManager];
    if (task.usingCache) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }else{
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    task.httpTask = [manager PUT:task.path
      parameters:task.parames
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             __block NSURLSessionDataTask * sessionDataTask = task;
             if(completeHandler){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completeHandler(sessionDataTask,responseObject, nil);
                 });
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             __block NSURLSessionDataTask * sessionDataTask = task;
             
             if(completeHandler){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     completeHandler(sessionDataTask,nil, error);
                 });
             }
         }];
    
    
}

+ (void)doDelete:(nonnull TOTask *)task
      progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
      complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    AFHTTPSessionManager *manager = [self sessionManager];
    if (task.usingCache) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }else{
        [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    task.httpTask = [manager DELETE:task.path
         parameters:task.parames
            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __block NSURLSessionDataTask * sessionDataTask = task;
                if(completeHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandler(sessionDataTask,responseObject, nil);
                    });
                }
            }
            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __block NSURLSessionDataTask * sessionDataTask = task;
                
                if(completeHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeHandler(sessionDataTask,nil, error);
                    });
                }
            }];
}

+ (void)cancel:(nonnull TOTask *)task{
    [task.httpTask cancel];
}


@end
