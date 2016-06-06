//
//  ViewController.m
//  TONetworkingDemo
//
//  Created by Tony on 16/6/6.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import <TONetworking>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TOTask * task = [[TOTask alloc] initWithPath:@"http://www.baidu.com" parames:nil taskOver:^(TOTask *task) {
        
    }];
    [task startAtOnce];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
