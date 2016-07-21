//
//  TOTask.h
//  TOFramework
//
//  Created by Tony on 16/2/19.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOTaskHelper.h"

#define TaskBlock void (^)(TOTask * task)

@interface TOTask : NSObject{
    
}

#pragma mark progress
//网络状态
typedef enum TOTaskStatus{
    TOTaskWaitting = 0,
    TOTaskCancel = 1,
    TOTaskLoading = 2,
    TOTaskFinish = 3,
    TOTaskError = 4,
} TOTaskStatus;

@property (nonatomic, assign, readonly) TOTaskStatus status;
@property (nonatomic, assign, readonly) float progress;

#pragma mark progress end

@property (nonatomic, strong ,readonly) NSString * path;


//taskKey和taskId用于终止任务
@property (nonatomic, strong ) NSString * taskKey;
@property (nonatomic, strong ) NSString * taskId;

//是否缓存
@property (nonatomic) BOOL usingCache;
//请求方式 POST/GET
@property (nonatomic, strong ) NSString * method;

@property (nonatomic, assign )  int     responseStatusCode;

//请求参数
@property (nonatomic, strong ,readonly) NSMutableDictionary * parames;


//请求所有者及回调函数
@property (nonatomic, weak ,readonly) id owner;
@property (nonatomic ,readonly) SEL taskOverHandler;
@property (nonatomic ,readonly) SEL taskErrorHandler;

@property (nonatomic,assign)  BOOL  needTip;


//加载时提示信息，为空则自动填入“加载中...”
@property (nonatomic, strong) NSString * tipMessage;

//是否允许用户操作,仅强制加载和队列加载时生效
@property (nonatomic)   BOOL    lockScreen;

//用户自定义属性
@property (nonatomic, strong) id userInfo;


//请求返回结果
@property (nonatomic, strong) NSString * responseString;
@property (nonatomic, strong) NSData * responseData;
@property (nonatomic, strong) NSError * error;

//自定义属性
@property (nonatomic, strong) id responseInfo;

//任务加载器
@property (nonatomic, strong) Class<TOTaskHelper> taskHelper;
//任务超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;


-(id)init;

-(id)initWithPath:(NSString*)path parames:(NSDictionary *)parames;

-(id)initWithPath:(NSString*)path parames:(NSDictionary *)parames owner:(id)owner taskOver:(SEL) taskOverHandler;

-(id)initWithPath:(NSString*)path parames:(NSDictionary *)parames owner:(id)owner taskOver:(SEL) taskOverHandler taskError:(SEL)taskErrorHandler;

-(id)initWithPath:(NSString*)path parames:(NSDictionary *)parames taskOver:(TaskBlock) taskOverHandler;

-(id)initWithPath:(NSString*)path parames:(NSDictionary *)parames taskOver:(TaskBlock) taskOverHandler taskError:(TaskBlock)taskErrorHandler;

/**
 *  为请求添加参数
 *
 *  @param value    参数值
 *  @param key      参数键
 */
-(void)addParam:(NSObject *)value forKey:(NSString *)key;
-(void)startOnQueue;

-(void)startAtOnce;
-(void)startThread;

-(instancetype)clone;


@end
