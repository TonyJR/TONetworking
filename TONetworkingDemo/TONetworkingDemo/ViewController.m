//
//  ViewController.m
//  TONetworkingDemo
//
//  Created by Tony on 16/6/6.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import <TONetworking/TONetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TOTask * task = [[TOTask alloc] initWithPath:@"http://www.baidu.com" parames:nil owner:self taskOver:@selector(taskover:)];
    [task startAtOnce];
}

-(void)taskover:(TOTask *)task{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
