//
//  TOTask.m
//  TOFramework
//
//  Created by TonyJR on 16/2/19.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "TOTask.h"
#import "TONetwork.h"
#import "TOTaskConfig.h"
#import "TOHTTPRequestHelper.h"

@interface TOTask ()
{
    NSMutableDictionary *_parames;
}

@property (nonatomic,strong) NSMutableDictionary *fileNames;

@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,copy) void (^successBlock)(TOTask *);
@property (nonatomic,copy) void (^errorBlock)(TOTask *);


@end

@implementation TOTask


static int taskIndex = 10000;

+ (void)initialize{
    if (!g_default_task_helper) {
        g_default_task_helper = [TOHTTPRequestHelper class];
    }
}

/**
 *  获取下一个ID
 *
 *  @return 自动taskID增长
 */
+ (NSString *)next{
    return [NSString stringWithFormat:@"task_%d",taskIndex++];
}
- (void)setStatus:(TOTaskStatus)status{
    if (status == TOTaskCancel) {
        [self.taskHelper cancel:self];
        if (!self.isLoading) {
            status = TOTaskWaitting;
        }
    }
    _status = status;
}

- (void)setProgress:(float)progress{
    _progress = progress;
}

- (id)init{
    if (self = [super init]) {
        _path = nil;
        _taskKey = nil;
        _taskId = [TOTask next];
        _owner = nil;
        _taskOverHandler = nil;
        _taskErrorHandler = nil;
        
        _tipMessage = nil;
        
        _usingCache = NO;
        
        _responseData = nil;
        _responseString = nil;
        
        _lockScreen = YES;
        
        _responseInfo = @"str";
        
        _needTip = YES;
        _errorBlock = nil;
        _successBlock = nil;
        
        _timeoutInterval = g_default_timeout;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path parames:(NSDictionary *)parames{
    return [self initWithPath:path parames:parames owner:nil taskOver:nil];
}

- (id)initWithPath:(NSString *)path parames:(NSDictionary *)parames owner:(id)owner taskOver:(SEL)taskOverHandler{
    return [self initWithPath:path parames:parames owner:owner taskOver:taskOverHandler taskError:nil];
}

- (id)initWithPath:(NSString *)path parames:(NSDictionary *)parames owner:(id)owner taskOver:(SEL)taskOverHandler taskError:(SEL)taskErrorHandler{
    self = [self init];
    if (self) {
        _path = path;
        _parames = [NSMutableDictionary dictionaryWithDictionary:parames];
        _owner = owner;
        _taskOverHandler = taskOverHandler;
        _taskErrorHandler = taskErrorHandler;
    }
    return self;
}

- (id)initWithPath:(NSString*)path parames:(NSDictionary *)parames taskOver:(TaskBlock) taskOverHandler{
    return [self initWithPath:path parames:parames taskOver:taskOverHandler taskError:nil];
    
}

- (id)initWithPath:(NSString*)path parames:(NSDictionary *)parames taskOver:(TaskBlock) taskOverHandler taskError:(TaskBlock)taskErrorHandler{
    
    
    self = [self initWithPath:path parames:parames];
    self.successBlock = taskOverHandler;
    self.errorBlock = taskErrorHandler;
    
    return self;
}


- (void)addParam:(NSObject *)value forKey:(NSString *)key{
    if (key) {
        if (!value) {
            value = @"";
        }
        [self.parames setObject:value forKey:key];
        [self.fileNames removeObjectForKey:key];
    }
    
}

-(void)addFile:(NSObject *)value forKey:(NSString *)key withName:(NSString *)fileName{
    [self addParam:value forKey:key];
    [self.fileNames setValue:fileName forKey:key];
}

- (void)startOnQueue{
    [[TONetwork sharedNetwork] taskOnQueue:self];
}
- (void)startAtOnce{
    [[TONetwork sharedNetwork] taskAtOnce:self];
}
- (void)startThread{
    
    [[TONetwork sharedNetwork] taskThread:self];
}

- (instancetype)clone{
    TOTask * result = [[[self class] alloc] initWithPath:self.path parames:self.parames owner:self.owner taskOver:self.taskOverHandler taskError:self.taskErrorHandler];
    
    result.taskKey = self.taskKey;
    result.userInfo = self.userInfo;
    result.method = self.method;
    result.needTip = self.needTip;
    result.tipMessage = self.tipMessage;
    result.lockScreen = self.lockScreen;
    result.usingCache = self.usingCache;
    
    result.errorBlock = self.errorBlock;
    result.successBlock = self.successBlock;
    
    return result;
}

#pragma mark - setter & getter
- (Class<TOTaskHelper>)taskHelper{
    if (!_taskHelper) {
        return g_default_task_helper;
    }else{
        return _taskHelper;
    }
}

- (NSString *)mimeType{
    if (!_mimeType) {
        return g_mimeType;
    }else{
        return _mimeType;
    }
}

- (NSMutableDictionary *)parames{
    if (!_parames) {
        _parames = [NSMutableDictionary dictionary];
    }
    return _parames;
}

- (NSMutableDictionary *)fileNames{
    if (!_fileNames) {
        _fileNames = [NSMutableDictionary dictionary];
    }
    return _fileNames;
}


@end
