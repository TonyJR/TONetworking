//
//  ToNetwork.h
//  TOTest
//
//  Created by Tony on 14-4-11.
//  Copyright (c) 2014年 PY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOTask.h"




//网络状态
typedef enum TONetStatus{
    TONetStatusNoSign = 0,
    TONetStatus3G = 2,
    TONetStatusWifi = 1,
} TONetStatus;

@interface TONetwork : NSObject{
    
}
//加载等待队列
@property (nonatomic,strong,nonatomic) NSMutableArray * queueTasks;
//并发加载队列
@property (nonatomic,strong,nonatomic) NSMutableArray * threadTasks;



//当前网络状态
@property (nonatomic,readonly) TONetStatus netStatus;


//独占信息
@property (nonatomic,retain) NSString * message;
//小贴士
@property (nonatomic,retain) NSString * tip;




+(BOOL)isCached:(NSString *)url;
+(NSData *)cachedData:(NSString *)url;


+ (instancetype)sharedNetwork;

/*
 下列三种加载方式将返回taskId，该ID可用于stopTaskById
 当改次请求的taskKey与之前未完成请求的taskKey相同时，会终止前一次请求，并使新请求重新排队
 */


//独占模式，暂停加载其他项，优先加载该项，多次独占会阻止前一次独占
-(NSString *)taskAtOnce:(TOTask *)task;
//并发模式，不与其他项冲突，独立加载。不受独占模式影响
-(NSString *)taskThread:(TOTask *)task;
//队列模式，队列加载，等待其他队列完成后才加载，受独占模式限制
-(NSString *)taskOnQueue:(TOTask *)task;


//获取任务
-(TOTask *)taskByKey:(NSString *)taskKey;
//获取任务
-(TOTask *)taskById:(NSString *)taskId;

//停止所有加载
-(void)stopAllTask;
//停止特定加载
-(void)stopTaskById:(NSString *)taskId;
//停止特定加载
-(void)stopTaskByKey:(NSString *)taskKey;
//暂停加载队列
-(void)pauseQueue;
//恢复加载队列
-(void)resumeQueue;

-(void)clearSession;

//启动网络监控
-(void)startNetListener;
-(void)stopNetListener;



@end


@interface TONetwork (TaskLifeCycle)


//如需在请求时特殊处理，请使用类别覆盖下面三个方法

//任务启动、结束以及失败
-(void)beforeTask:(TOTask *) task;

//返回值将决定是否通知owner
-(BOOL)afterTask:(TOTask *) task;
-(BOOL)errorTask:(TOTask *) task;

@end
