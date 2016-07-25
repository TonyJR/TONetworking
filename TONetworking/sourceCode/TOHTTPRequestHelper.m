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



@implementation TOHTTPRequestHelper

+(void)startTask:(nonnull TOTask *)task progress:(nullable void (^)(NSProgress * _Nonnull))progressHandler
        complete:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSData * _Nullable,NSError * _Nullable))completeHandler{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    
    // 设置请求格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSArray * keys = task.parames.allKeys;
    
    for (NSString * key in keys) {
        NSObject * item = (NSObject *)(task.parames[key]);
        
        if([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]){
            [dic setObject:item forKey:key];
        }
    }
    
    NSError * error;
    if (![task.method isEqualToString:@"GET"]) {
        task.method = @"POST";
    }
    
    
    NSMutableURLRequest * request;
    
    if ([task.method isEqualToString:@"POST"]) {
        request = [manager.requestSerializer multipartFormRequestWithMethod:task.method URLString:[[NSURL URLWithString:task.path relativeToURL:manager.baseURL] absoluteString] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSArray * _keys = task.parames.allKeys;
            
            for (NSString * key in _keys) {
                
                NSObject * item = (NSObject *)(task.parames[key]);
                if ([item isKindOfClass:[NSURL class]]) {
                    [formData appendPartWithFileURL:(NSURL *)item name:key fileName:[NSString stringWithFormat:@"%@.file",key] mimeType:@"multipart/mixed" error:nil];
                    
                }else if ([item isKindOfClass:[NSData class]]) {
                    [formData appendPartWithFileData:(NSData *)item name:key fileName:[NSString stringWithFormat:@"%@.file",key] mimeType:@"multipart/mixed"];
                }else if([item isKindOfClass:[UIImage class]]){
                    [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage *)item,0.8) name:key fileName:[NSString stringWithFormat:@"%@.jpg",key] mimeType:@"multipart/mixed"];
                }
            }
        } error:&error];
    }else{
        request = [manager.requestSerializer requestWithMethod:task.method URLString:[[NSURL URLWithString:task.path relativeToURL:manager.baseURL] absoluteString] parameters:task.parames error:&error];
    }
    
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
    
    
}

@end
