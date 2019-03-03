//
//  ELHMyWalletViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/18.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMyWalletViewController.h"
#import "ELHMyWalletCell.h"
#import "ELHHTTPSessionManager.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "ELHOCToJson.h"
#import "ELHMyWalletModel.h"

@interface ELHMyWalletViewController ()
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 存放红包数据的数组 */
@property (nonatomic, strong) NSMutableArray *redEnvelopeArray;

@end

@implementation ELHMyWalletViewController
static NSString * const Identifier = @"MyWalletCell";
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}
/** redEnvelopeArray的懒加载 */
- (NSMutableArray *)redEnvelopeArray{
    if (!_redEnvelopeArray) {
        _redEnvelopeArray = [NSMutableArray array];
    }
    return _redEnvelopeArray;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];

    [self loadRedEnvelopeData];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ELHMyWalletCell class]) bundle:nil] forCellReuseIdentifier:Identifier];
}

/**
 *  初始化导航栏
 */
- (void)setUpNav {
    self.navigationItem.title = @"我的钱包";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = ELHColor(232, 232, 232, 1);
}

- (void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

/**
 *  加载红包的数据
 */
- (void)loadRedEnvelopeData {
    [SVProgressHUD showWithStatus:@"正在加载中,请稍后"];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
    if (userID != nil) {
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               @"isOverdue" : @"false", // 是否过期
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        
        NSString *URL = [NSString stringWithFormat:@"%@Voucher_getVoucherListByGOId.action", ELHBaseURL];
        
        ELHWeakSelf;
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@", responseObject);
            // 字典数组转模型数组
            weakSelf.redEnvelopeArray = [ELHMyWalletModel mj_objectArrayWithKeyValuesArray:responseObject];
            
//            NSLog(@"%@", weakSelf.redEnvelopeArray);
            
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            
            BSLog(@"%@", error);
        }];
    }
}



#pragma mark - UITableView相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.redEnvelopeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELHMyWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    // 设置属性
    cell.backgroundColor = ELHColor(232, 232, 232, 1);
    cell.userInteractionEnabled = NO;
    
    // 设置数据
    cell.myWalletModel = self.redEnvelopeArray[indexPath.row];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    cell.limitUseLabel.text = [NSString stringWithFormat:@"●限尾号%@的手机使用", [username substringFromIndex:7]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}
@end
