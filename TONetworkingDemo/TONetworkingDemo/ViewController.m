//
//  ViewController.m
//  TONetworkingDemo
//
//  Created by Tony on 16/6/6.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import <TONetworking/TONetwork.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


typedef enum : NSUInteger {
    ListStatusNomarl,
    ListStatusLoading,
    ListStatusNextPageLoading,
    ListStatusLastPage,
    ListStatusError,
    ListStatusNoResult,

} ListStatus;


#define kCellIdentifier         @"menuCell"
#define kNextPageIdentifier     @"nextPage"
#define kAPIKey                 @"11c512b272925b6c765faf23d3472a13"


@interface ViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSString * errorReason;
}

@property (nonatomic,strong) IBOutlet UISearchBar * searchBar;
@property (nonatomic,strong) IBOutlet UITableView * menuTable;


@property (nonatomic,strong) NSMutableArray<NSDictionary *> * menuDataList;
@property (nonatomic,assign) ListStatus currentStatus;

@property (nonatomic,strong) RACDisposable * loadingDispose;
@property (nonatomic,strong)   NSMutableDictionary * param;

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.menuTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.menuTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kNextPageIdentifier];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.menuDataList.count;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * result;
    if (indexPath.section == 0) {
        result = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        result.textLabel.text = self.menuDataList[indexPath.row][@"title"];
        result.detailTextLabel.text = self.menuDataList[indexPath.row][@"tags"];
    }else{
        result = [tableView dequeueReusableCellWithIdentifier:kNextPageIdentifier forIndexPath:indexPath];
        
        result.textLabel.textAlignment = NSTextAlignmentCenter;
        switch (_currentStatus) {
            case ListStatusError:
                result.textLabel.text = errorReason;
                break;
            
            case ListStatusLastPage:
                result.textLabel.text = @"没有更多内容了";
                break;
            case ListStatusNomarl:
                [self searchNextPage];
                result.textLabel.text = @"";
                break;
            case ListStatusLoading:
            case ListStatusNextPageLoading:
                result.textLabel.text = @"努力加载中...";
                break;
            case ListStatusNoResult:
                result.textLabel.text = @"╮(╯_╰)╭没找到你要的东西哦~";
                break;
            default:
                break;
        }
    }
    
    return result;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


#pragma mark - UITableViewDelegate



#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.loadingDispose dispose];//上次信号还没处理，取消它(距离上次生成还不到1秒)
    
    @weakify(self);
    self.loadingDispose = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendCompleted];
        return nil;
    }] delay:0.2] //延迟信号
                           subscribeCompleted:^{
                               @strongify(self);
                               [self search:searchText];
                               self.loadingDispose = nil;  
                           }];
}


#pragma mark - private
/**
 *  数据接口API https://www.juhe.cn/docs/api/id/46
 *  自己申请测试数据吧，貌似我的已经用光了
 */



//搜索
- (void)search:(NSString *)txt{
    //结束翻页动作
    [[TONetwork sharedNetwork] stopTaskByKey:[self nextPageKey]];
    
    self.currentStatus = ListStatusLoading;
    

    //启动搜索动作
    TOTask * task = [[TOTask alloc] initWithPath:@"http://apis.juhe.cn/cook/query.php" parames:nil owner:self taskOver:@selector(taskSuccess:) taskError:@selector(taskError:)];
    [task addParam:txt forKey:@"menu"];
    [task addParam:kAPIKey forKey:@"key"];
    task.taskKey = [self searchKey];
    //关闭自动提示
    task.needTip = NO;
    //并发模式启动
    [task startThread];
}

//翻页
- (void)searchNextPage{
    if (!self.param) {
        return;
    }
    
    if (self.currentStatus != ListStatusNomarl) {
        return;
    }
    
    self.currentStatus = ListStatusNextPageLoading;
    
    
    
    //启动翻页动作
    TOTask * task = [[TOTask alloc] initWithPath:@"http://apis.juhe.cn/cook/query.php" parames:self.param owner:self taskOver:@selector(taskSuccess:) taskError:@selector(taskError:)];
    task.taskKey = [self searchKey];
    //关闭自动提示
    task.needTip = NO;
    //并发模式启动
    [task startThread];
}

//数据结果回调
- (void)taskSuccess:(TOTask *)task{
    if (self.currentStatus == ListStatusLoading) {
        @synchronized(self) {
            [self.menuDataList removeAllObjects];
        }
    }
    
    NSArray * responseArr = task.responseInfo[@"result"][@"data"];
    
    if (responseArr.count == 0) {
        self.currentStatus = ListStatusLastPage;
    }else {
        self.currentStatus = ListStatusNomarl;
        
        @synchronized(self) {
            [self.menuDataList addObjectsFromArray:responseArr];
        }
        
        
        self.param = [task.parames mutableCopy];
        [self.param setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.menuDataList.count] forKey:@"pn"];
    }
    
    
    @synchronized(self) {
        [self.menuTable reloadData];
    }
}

//请求失败
- (void)taskError:(TOTask *)task{
    if (self.currentStatus == ListStatusLoading) {
        @synchronized(self) {
            [self.menuDataList removeAllObjects];
        }
    }
    
    switch ([task.responseInfo[@"error_code"] intValue]) {
        case 204601:
            //未输入搜索内容
            self.currentStatus = ListStatusNomarl;
            break;
        case 204602:
            //无数据时返回
            self.currentStatus = ListStatusNoResult;
            break;
            
        default:
            self.currentStatus = ListStatusError;
            errorReason = task.responseInfo[@"reason"];
            break;
    }
    
    self.param = task.parames;
    @synchronized(self) {
        [self.menuTable reloadData];
    }
}

- (NSString *)searchKey{
    static NSString * SEARCH_KEY = @"searchKey";
    return [NSString stringWithFormat:@"%p_%@",((__bridge const void *)self),SEARCH_KEY];
}

- (NSString *)nextPageKey{
    static NSString * NEXT_PAGE_KEY = @"nextPageKey";
    return [NSString stringWithFormat:@"%p_%@",((__bridge const void *)self),NEXT_PAGE_KEY];
}


#pragma mark - getter & setter
- (NSMutableArray *)menuDataList{
    if (!_menuDataList) {
        _menuDataList = [NSMutableArray array];
    }
    
    return _menuDataList;
}

- (void)setCurrentStatus:(ListStatus)currentStatus{
    _currentStatus = currentStatus;
//    [self.menuTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
@end
