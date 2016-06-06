//
//  TORequestHelper.m
//  TOFramework
//
//  Created by Tony on 16/2/19.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "TORequestHelper.h"
#import "TOTask.h"
#import "AFNetworking.h"



@implementation TORequestHelper

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
    
    
    NSMutableURLRequest * request = [manager.requestSerializer multipartFormRequestWithMethod:task.method URLString:[[NSURL URLWithString:task.path relativeToURL:manager.baseURL] absoluteString] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
    
    
    /*
    
    if (task.usingCache || [task.method isEqualToString:@"GET"]) {
        
        NSMutableArray * arr = [NSMutableArray array];
        NSArray * keys = task.parames.allKeys;
        
        for (NSString * key in keys) {
            NSObject * item = (NSObject *)(task.parames[key]);
            
            [arr addObject:@{key:item}];
        }
        
        
        [manager GET:task.path parameters:arr progress:^(NSProgress * _Nonnull downloadProgress) {
            task.progress = downloadProgress.completedUnitCount * 100.0f / downloadProgress.totalUnitCount;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            task.responseData= responseObject;
            if ([response.textEncodingName isEqualToString:@"utf-8"]) {
                task.responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            task.responseStatusCode = response.statusCode;
            
            [self requestFinished:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            task.error = error;
            [self requestFailed:task];
        }];
    }else{
        NSMutableArray * arr = [NSMutableArray array];
        NSArray * keys = task.parames.allKeys;
        
        for (NSString * key in keys) {
            NSObject * item = (NSObject *)(task.parames[key]);
            
            if([item isKindOfClass:[NSString class]]){
                [arr addObject:@{key:item}];
            }
        }
        
        [manager POST:task.path parameters:arr constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSArray * _keys = task.parames.allKeys;
            
            for (NSString * key in _keys) {
                
                NSObject * item = (NSObject *)(task.parames[key]);
                if ([item isKindOfClass:[NSData class]]) {
                    [formData appendPartWithFormData:item name:key];
                    
                }else if([item isKindOfClass:[UIImage class]]){
                    [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage *)item,0.8) name:key fileName:[NSString stringWithFormat:@"%@.jpg",key] mimeType:@"multipart/mixed"];
                }
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            task.progress = uploadProgress.completedUnitCount * 100.0f / uploadProgress.totalUnitCount;
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            task.responseData= responseObject;
            if ([response.textEncodingName isEqualToString:@"utf-8"]) {
                task.responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            task.responseStatusCode = response.statusCode;
            
            
            [self requestFinished:task];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"----%lld",task.response.expectedContentLength);
            
            task.error = error;
            error.
            
            [self requestFailed:task];
            
        }];
    }
    */
}

@end
