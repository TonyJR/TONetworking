//
//  ToNetwork.m
//  TOTest
//
//  Created by Tony on 14-4-11.
//  Copyright (c) 2014年 PY. All rights reserved.
//

#import "TONetwork.h"
#import "Reachability.h"
#import <Foundation/Foundation.h>
#import "TORequestHelper.h"


#define TONETWORK_CACHE @"__toNetworkCache"

@interface TOTask ()


-(void)setStatus:(TOTaskStatus)status;
-(void)setProgress:(float)progress;

@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,copy) void (^successBlock)(TOTask *);
@property (nonatomic,copy) void (^errorBlock)(TOTask *);


@end


@interface TONetwork (){
    dispatch_queue_t task_queue;
}
@property (nonatomic,strong) TOTask * currentTask;

-(void)requestWithTask:(TOTask *)task;
@end



@implementation TONetwork
{
    Reachability * hostReach;
}

static TONetwork * _sharedNetwork = nil;


-(id)init{
    self = [super init];
    if (self) {
        self.queueTasks = [NSMutableArray array];
        self.threadTasks = [NSMutableArray array];
        
        hostReach = nil;
        
        task_queue = dispatch_queue_create("tonetwork", NULL);
    }
    return self;
}


-(void)setCurrentTask:(TOTask *)currentTask{
    _currentTask = currentTask;
    
    NSString * message;
    
    if (currentTask && self.currentTask.lockScreen) {
        if (self.currentTask.tipMessage) {
            message = self.currentTask.tipMessage;
        }else{
            message = @"加载中...";
        }
    }else{
        message = nil;
    }
    
    self.message = message;
}




+(instancetype)sharedNetwork{
    if (!_sharedNetwork) {
        _sharedNetwork = [[TONetwork alloc] init];
    }
    return _sharedNetwork;
}

+(BOOL)isCached:(NSString *)url{
    
    return NO;
}

+(NSData *)cachedData:(NSString *)url{
    return nil;
}

/**
 *  独占加载，暂停加载其他项，优先加载该项，多次独占会阻止前一次独占
 *
 *  @param task 被启动的任务
 *
 *  @return 独占模式，暂停加载其他项，优先加载该项，多次独占会阻止前一次独占
 */
-(NSString *)taskAtOnce:(TOTask *)task{
    

    __block TOTask * task_block = task;
    
    dispatch_async(task_queue, ^{
        [self stopTaskByIdSync:task_block.taskId];
        [self stopTaskByKeySync:task_block.taskKey];
        
        [self.queueTasks insertObject:task_block atIndex:0];
        [self nextQueue];
    });
    return task.taskId;
    
}
//并发模式，不与其他项冲突，独立加载。不受独占模式影响
-(NSString *)taskThread:(TOTask *)task{
    
    __block TOTask * task_block = task;
    
    dispatch_async(task_queue, ^{
        [self stopTaskByIdSync:task_block.taskId];
        [self stopTaskByKeySync:task_block.taskKey];
        
        [self.threadTasks addObject:task_block];
        [self requestWithTask:task_block];
    });
    
    return task.taskId;
}

//队列模式，队列加载，等待其他队列完成后才加载，受独占模式限制
-(NSString *)taskOnQueue:(TOTask *)task{
    
    __block TOTask * task_block = task;
    
    dispatch_async(task_queue, ^{
        [self stopTaskByIdSync:task_block.taskId];
        [self stopTaskByKeySync:task_block.taskKey];
        
        [self.queueTasks addObject:task_block];
        [self nextQueue];
    });
    return task.taskId;
}



//停止所有加载
-(void)stopAllTask{
    dispatch_async(task_queue, ^{

        if(self.currentTask){
            [self.currentTask setStatus:TOTaskCancel];
            self.currentTask = nil;
        }
        
        while (self.threadTasks.count > 0) {
            TOTask * task = self.threadTasks[0];
            [task setStatus:TOTaskCancel];
            [self.threadTasks removeObjectAtIndex:0];
        }
        
    });
}
//停止特定加载
-(void)stopTaskById:(NSString*)taskId{
    __block NSString * taskId_block = taskId;
    dispatch_async(task_queue, ^{

        [self stopTaskByIdSync:taskId_block];
        
    });
}


-(void)stopTaskByIdSync:(NSString*)taskId{
    if (!taskId) {
        return;
    }
    
    if (self.currentTask) {
        TOTask * task = self.currentTask;
        if ([task.taskId isEqualToString:taskId]) {
            
            task.status = TOTaskCancel;
            self.currentTask = nil;
            [self nextQueue];
        }
    }
    for (int i=0;i< self.queueTasks.count;i++) {
        TOTask * task = self.queueTasks[i];
        if (task.taskKey && [task.taskId isEqualToString:taskId]) {
            task.status = TOTaskCancel;
            [self.queueTasks removeObjectAtIndex:i];
            i--;
        }
    }
    for (int i=0;i< self.threadTasks.count;i++) {
        TOTask * task = self.threadTasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            task.status = TOTaskCancel;
            [self.threadTasks removeObjectAtIndex:i];
            i--;
        }
    }
}

//停止特定加载
-(void)stopTaskByKey:(NSString*)taskKey{
    
    __block NSString * taskKey_block = taskKey;
    
    dispatch_async(task_queue, ^{
        [self stopTaskByKeySync:taskKey_block];
    });
    
}

-(void)stopTaskByKeySync:(NSString*)taskKey{
    
    if (!taskKey) {
        return;
    }
    
    if (self.currentTask) {
        TOTask * task = self.currentTask;
        if ([task.taskKey isEqualToString:taskKey]) {
            task.status = TOTaskCancel;
            self.currentTask = nil;
            [self nextQueue];
        }
    }
    for (int i=0;i< self.queueTasks.count;i++) {
        TOTask * task = self.queueTasks[i];
        if (task.taskKey && [task.taskKey isEqualToString:taskKey]) {
            task.status = TOTaskCancel;
            [self.queueTasks removeObjectAtIndex:i];
            i--;
        }
    }
    for (int i=0;i< self.threadTasks.count;i++) {
        TOTask * task = self.threadTasks[i];
        if ([task.taskKey isEqualToString:taskKey]) {
            task.status = TOTaskCancel;
            [self.threadTasks removeObjectAtIndex:i];
            i--;
        }
    }
}

//暂停加载队列
-(void)pauseQueue{
    
    dispatch_sync(task_queue, ^{
        // something
        
        if(self.currentTask){
            [self.queueTasks insertObject:[self.currentTask clone] atIndex:0];
            
            
            [self.currentTask setStatus:TOTaskCancel];
            
            self.currentTask = nil;
        }
        

    });
    
    
}
//恢复加载队列
-(void)resumeQueue{
    [self nextQueue];
}

//队列继续
-(void)nextQueue{
    dispatch_async(task_queue, ^{
        // something
        
        if(!self.currentTask || self.currentTask.status == TOTaskFinish || self.currentTask.status == TOTaskError || self.currentTask.status == TOTaskCancel){
            
            self.currentTask = [self nextTask];
            if (self.currentTask) {
                [self requestWithTask:self.currentTask];
            }
        }
    });
}


-(TOTask *)nextTask{
    TOTask * result;
    
    if (self.queueTasks.count>0) {
        
        result = [self.queueTasks objectAtIndex:0];
        [self.queueTasks removeObjectAtIndex:0];
        
    }
    return result;
}


//发送请求
-(void)requestWithTask:(TOTask *) _task{
    [self performSelectorOnMainThread:@selector(beforeTask:) withObject:_task waitUntilDone:YES];
    _task.status = TOTaskLoading;
    __block TOTask * task_block = _task;
    
    task_block.progress = 0;
    
    
    [TORequestHelper startTask:task_block progress:^(NSProgress * progress) {
        
        task_block.progress = progress.completedUnitCount * 100.0f / progress.totalUnitCount;
        
    } complete:^(NSURLSessionDataTask * task, NSData * responseData, NSError * error) {
        
        __block TOTask * task_main_block = task_block;
        __block NSURLSessionDataTask * task_main_data_block = task;
        
        
        dispatch_async(task_queue, ^{
            
            if (task_main_block.status == TOTaskLoading) {
                NSHTTPURLResponse * response = (NSHTTPURLResponse *)task_main_data_block.response;
                task_main_block.responseData = responseData;
                
                if ([response.textEncodingName isEqualToString:@"utf-8"]) {
                    task_main_block.responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                }else{
                    task_main_block.responseString = nil;
                }
                
                task_main_block.responseStatusCode = (int)response.statusCode;
                task_main_block.error = error;
                
                [self requestEnd:task_main_block];
                
                
                 [self performSelectorOnMainThread:@selector(requestFinished:) withObject:task_block waitUntilDone:YES];
            }
            
            
           
        });
        
        
    }];
    
    
}


-(void)clearSession{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        NSLog(@"%@",cookie.name);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

//网络监控
-(void)startNetListener{
    if (hostReach) {
        return;
    }
    
    //网络检测
    _netStatus = TONetStatusNoSign;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(reachabilityChanged:)
     
                                                 name: kReachabilityChangedNotification
     
                                               object: nil];
    
    hostReach =(Reachability *) [Reachability reachabilityWithHostName:@"www.baidu.com"];//可以以多种形式初始化
    
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    
    [self updateInterfaceWithReachability: hostReach];
}

//关闭网络监控
-(void)stopNetListener{
    if (hostReach) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        [hostReach stopNotifier];
        hostReach = nil;
    }
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach

{
    
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            if (self.netStatus!=TONetStatusNoSign) {
                _netStatus = TONetStatusNoSign;
                self.tip = NSLocalizedString(@"tip_1",@"未发现网络，进入离线模式");
            }
            break;
        case ReachableViaWiFi:
            if (self.netStatus!=TONetStatusWifi) {
                _netStatus = TONetStatusWifi;
                self.tip = NSLocalizedString(@"tip_2",@"进入wifi模式");
            }
            break;
        case ReachableViaWWAN:
            if (self.netStatus!=TONetStatus3G) {
                _netStatus = TONetStatus3G;
                self.tip = NSLocalizedString(@"tip_3",@"进入3G/GPRS模式");
            }
            break;
            
        default:
            
            break;
    }
}

// 连接改变

- (void) reachabilityChanged: (NSNotification* )note

{
    
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    [self updateInterfaceWithReachability: curReach];
    
}







//请求成功
- (void)requestFinished:(TOTask *)task{

    
    if (task) {
        
        if ([self afterTask:task]) {
            if (task.owner && task.taskOverHandler) {
                [task.owner performSelector:task.taskOverHandler withObject:task];
            }
            if (task.successBlock) {
                task.successBlock(task);
            }
            
        }else {
            if(task.owner && task.taskErrorHandler){
                [task.owner performSelector:task.taskErrorHandler withObject:task];
            }
            
            if (task.errorBlock) {
                task.errorBlock(task);
            }
        }
    }
    
}

-(void)blockWithMainThread:(TOTask *)task{
    
}

//请求结束时通知
-(void)requestEnd:(TOTask *)task{
    if (task.error) {
        task.status = TOTaskError;
    }else{
        task.status = TOTaskFinish;
    }
    
    [self nextQueue];
}






-(void)beforeTask:(TOTask *) task{
    
}


-(BOOL)afterTask:(TOTask *) task{
    return YES;
}
-(BOOL)errorTask:(TOTask *) task{
    return YES;
}


- (void)setProgress:(float)newProgress{
    self.progress = newProgress;
}


@end