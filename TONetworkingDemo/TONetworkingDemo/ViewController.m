//
//  ViewController.m
//  TONetworkingDemo
//
//  Created by Tony on 16/6/6.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import <TONetworking/TONetwork.h>

@interface ViewController () <UISearchBarDelegate>

@property (nonatomic,strong) IBOutlet UISearchBar * searchBar;
@property (nonatomic,strong) IBOutlet UITableView * searchResultTable;


@end

static NSString * SEARCH_KEY      = @"searchKey";
static NSString * NEXT_PAGE_KEY   = @"nextPageKey";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TOTask * task = [[TOTask alloc] initWithPath:@"http://apis.juhe.cn/cook/query.php" parames:nil owner:self taskOver:@selector(taskover:)];
    [task addParam:@"红烧肉" forKey:@"menu"];
    [task addParam:@"11c512b272925b6c765faf23d3472a13" forKey:@"key"];
    [task startAtOnce];
}

- (void)taskover:(TOTask *)task{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)search:(NSString *)txt{
    //结束翻页动作
    [[TONetwork sharedNetwork] stopTaskByKey:NEXT_PAGE_KEY];
    
    //启动搜索动作
    TOTask * task = [[TOTask alloc] initWithPath:@"http://apis.juhe.cn/cook/query.php" parames:nil owner:self taskOver:@selector(taskover:)];
    [task addParam:@"红烧肉" forKey:@"menu"];
    [task addParam:@"11c512b272925b6c765faf23d3472a13" forKey:@"key"];
    task.taskKey = SEARCH_KEY;
    //独占模式启动
    [task startAtOnce];
}

- (void)searchNextPage{
    
    if ([[TONetwork sharedNetwork] ]) {
        <#statements#>
    }
    
}

@end
