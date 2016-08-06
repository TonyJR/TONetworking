//
//  TOTaskConfig.h
//  TOFramework_demo
//
//  Created by Tony on 16/7/15.
//  Copyright © 2016年 Tony. All rights reserved.
//

#ifndef TOTaskConfig_h
#define TOTaskConfig_h
#import "TOTaskHelper.h"
#import "TOHTTPRequestHelper.h"


//TOTask中的默认加载工具类
static Class<TOTaskHelper>  g_default_task_helper;
//任务超时时间
static NSTimeInterval       g_default_timeout = 10;
static float                g_image_compression_quality = 1.0f;

#endif /* TOTaskConfig_h */
