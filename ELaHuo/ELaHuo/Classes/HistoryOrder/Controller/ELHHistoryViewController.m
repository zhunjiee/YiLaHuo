//
//  ELHHistoryViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHHistoryViewController.h"
#import "ELHHistoryOrderCell.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "ELHHistoryOrderModel.h"
#import "ELHDetailHistoryOrderViewController.h"
#import "ELHAssessViewController.h"


@interface ELHHistoryViewController ()
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *mangaer;
/** 历史订单模型 */
@property (nonatomic, strong) ELHHistoryOrderModel *historyOrder;
/** 存放历史订单的数组 */
@property (nonatomic, strong) NSMutableArray *historyOrderArray;
@end

@implementation ELHHistoryViewController
static NSString * const Identifier = @"HistoryOrderCell";
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)mangaer{
    if (!_mangaer) {
        _mangaer = [ELHHTTPSessionManager manager];
    }
    return _mangaer;
}
/** historyOrderArray的懒加载 */
- (NSMutableArray *)historyOrderArray{
    if (!_historyOrderArray) {
        _historyOrderArray = [NSMutableArray array];
    }
    return _historyOrderArray;
}


#pragma 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];

    [self loadHistoryOrderData];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ELHHistoryOrderCell class]) bundle:nil] forCellReuseIdentifier:Identifier];
    
    // 注册评价成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assessSuccess) name:ELHAssessSuccessNotification object:nil];
}

// 评价成功,重新加载数据
- (void)assessSuccess {
    [self loadHistoryOrderData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化导航栏
 */
- (void)setUpNav {
    self.navigationItem.title = @"历史订单";

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = ELHColor(232, 232, 232, 1);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

/**
 *  加载历史订单数据
 */
- (void)loadHistoryOrderData {
    [SVProgressHUD showWithStatus:@"正在加载中,请稍后"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
    if (userID != nil) {
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               @"sPageNum" : @"1", // 起始页
                               @"aPageNum" : @"30", // 每页显示条数
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        
        NSString *URL = [NSString stringWithFormat:@"%@HistoryOrder_getOrderByGOId.action", ELHBaseURL];
        
        ELHWeakSelf;
        [self.mangaer POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"HistoryOrderresponseObject = %@", responseObject);
            weakSelf.historyOrderArray = [ELHHistoryOrderModel mj_objectArrayWithKeyValuesArray:responseObject];

            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            
            BSLog(@"%@", error);
        }];
    }

}


#pragma mark - tableView相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.historyOrderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELHHistoryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    cell.historyOrderModel = self.historyOrderArray[indexPath.row];
    if ([cell.historyOrderModel.ROSTATE isEqual:@"6"]) {
        cell.assessButton.hidden = NO;
        cell.cancelOrderImage.hidden = YES;
    } else if ([cell.historyOrderModel.ROSTATE isEqual:@"8"]) {
        cell.cancelOrderImage.hidden = NO;
        cell.assessButton.hidden = YES;
    }else {
        cell.assessButton.hidden = YES;
        cell.cancelOrderImage.hidden = YES;
    }
    // 立即评价
    [cell.assessButton setTag:indexPath.row];
    [cell.assessButton addTarget:self action:@selector(assessButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 订单详情
    [cell.selectedButton setTag:indexPath.row];
    [cell.selectedButton addTarget:self action:@selector(selectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/**
 *  跳转到订单详情页面
 */
- (void)selectedButtonDidClick:(UIButton *)button {
    ELHDetailHistoryOrderViewController *detailOrderVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHDetailHistoryOrderViewController class]) bundle:nil].instantiateInitialViewController;
    // 设置数据
    detailOrderVC.HistoryOrder = self.historyOrderArray[button.tag];
//    ELHHistoryOrderModel *model = self.historyOrderArray[button.tag];
//    detailOrderVC.navigationItem.title = model.ROBM;
    // 跳转
    [self.navigationController pushViewController:detailOrderVC animated:YES];
}
/**
 *  点击了立即评价按钮,跳转到评价页面
 */
- (void)assessButtonClick:(UIButton *)button {
    ELHAssessViewController *assessVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHAssessViewController class]) bundle:nil].instantiateInitialViewController;
    ELHHistoryOrderModel *model = self.historyOrderArray[button.tag];
    assessVC.COId = model.COID;
    assessVC.ROId = model.ROID;
    [self.navigationController pushViewController:assessVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

@end
