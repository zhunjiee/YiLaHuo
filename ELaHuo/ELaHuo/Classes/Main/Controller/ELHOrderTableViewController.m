//
//  ELHOrderTableViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/24.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHOrderTableViewController.h"
#import "DirverInfoViewController.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHOrderView.h"
#import "ELHExecuteOrderView.h"
#import "ELHTransportOrderView.h"
#import "ELHOrderModel.h"
#import "ELHOrderDetailModel.h"
#import <MJExtension.h>
#import "ELHOrderDetailCell.h"
#import "ELHTransportOrderCell.h"
#import <MessageUI/MessageUI.h>
#import "ELHPayViewController.h"
#import <SVProgressHUD.h>


@interface ELHOrderTableViewController () <MFMessageComposeViewControllerDelegate>

/** 网络管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;

/** 竞价订单模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;

@end

@implementation ELHOrderTableViewController
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

/** stateArray的懒加载 */
- (NSMutableArray *)stateArray{
    if (!_stateArray) {
        _stateArray = [NSMutableArray array];
    }
    return _stateArray;
}
/** orderNumArray的懒加载 */
- (NSMutableArray *)orderNumArray{
    if (!_orderNumArray) {
        _orderNumArray = [NSMutableArray array];
    }
    return _orderNumArray;
}
/** orderDetailArray的懒加载 */
- (NSMutableArray *)orderDetailArray{
    if (!_orderDetailArray) {
        _orderDetailArray = [NSMutableArray array];
    }
    return _orderDetailArray;
}


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUptableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNoticeDirver:) name:NoticeDirverNotification object:nil];

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.confirmTag = 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 *  设置tableView
 */
- (void)setUptableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.autoresizingMask = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    // 初始化表格为0 避免出现数据未加载时显示为空白表格的问题,很难看
    self.tableView.frame = CGRectMake(0, ScreenH, ScreenW, 0);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orderArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ELHOrderModel *model = self.orderArray[section];
    if (model.ROState == 4 || model.ROState == 5) {
        return 0;
    } else {
        NSArray *tempArray;
        if (self.orderArray.count == self.orderDetailArray.count) {
            tempArray = self.orderDetailArray[section];
            if (tempArray.count == 0) {
                //修改
                [self.stateArray replaceObjectAtIndex:tag withObject:@"0"];
            }
        }
        
        return tempArray.count;
    }
    
//    // 点击的时候展开,返回具体的个数
//    if (self.stateArray.count != 0 && [self.stateArray[section] isEqualToString:@"1"] && self.orderArray.count == self.orderDetailArray.count){
//        
//        ELHOrderModel *model = self.orderArray[section];
//        if (model.ROState == 4 || model.ROState == 5) {
//            return 0;
//        } else {
//            NSArray *tempArray = self.orderDetailArray[section];
//            if (tempArray.count == 0) {
//                //修改
//                [self.stateArray replaceObjectAtIndex:tag withObject:@"0"];
//            }
//            return tempArray.count;
//        }
//        
//    }else{
//        //如果是闭合，返回0
//        return 0;
//    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"orderDetailCell";
    ELHOrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ELHOrderDetailCell class]) owner:nil options:nil].firstObject;
    }
    // 设置数据
    NSArray *tempArray = [ELHOrderDetailModel mj_objectArrayWithKeyValuesArray:self.orderDetailArray[indexPath.section]];
    self.orderDetailModel = tempArray[indexPath.row];
    cell.orderDetailModel = self.orderDetailModel;
    
    [cell.dirverHeadButton addTarget:self action:@selector(seeDirverInfo) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}


// 进入司机详情页查看司机信息
- (void)seeDirverInfo {
    DirverInfoViewController *dirverInfoVC = [UIStoryboard storyboardWithName:NSStringFromClass([DirverInfoViewController class]) bundle:nil].instantiateInitialViewController;
    
    // 设置数据
    dirverInfoVC.COId = self.orderDetailModel.COId;
    dirverInfoVC.orderDetailModel = self.orderDetailModel;
    
    [self.navigationController pushViewController:dirverInfoVC animated:YES];
}



/**
 *  选中报价订单的时候调用
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 订单模型
    ELHOrderModel *orderModel = self.orderArray[indexPath.section];
    NSArray *tempArray;
    if (self.orderDetailArray[indexPath.section] != nil) {
        tempArray = [ELHOrderDetailModel mj_objectArrayWithKeyValuesArray:self.orderDetailArray[indexPath.section]];
    }

    // 订单详情模型
    ELHOrderDetailModel *orderDetailModel;
    if (tempArray != nil) {
        orderDetailModel = tempArray[indexPath.row];
    }
    
    if (orderModel.ROState == 2) { // 竞价订单,点击后跳转到支付页面
        ELHPayViewController *payVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHPayViewController class]) bundle:nil].instantiateInitialViewController;
        
        // 设置支付界面数据
        //订单编号
        payVC.orderNumber = orderModel.ROBM;
        payVC.orderModel = orderModel;
        payVC.orderDetailModel = orderDetailModel;
        // 订单ID
        payVC.ROId = orderModel.ROId;
        
        [self.navigationController pushViewController:payVC animated:YES];
    }
}



- (void)receivedNoticeDirver:(NSNotification *)notification {
    NSDictionary *extras = notification.userInfo;
    BSLog(@"extras = %@", extras);
    
    NSString *orderNumber = [NSString stringWithFormat:@"%@", [extras valueForKey:@"ROBM"]];
    
    // 取出上一次的个数
    NSString *DirverCount = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"DirverCount%@", orderNumber]];
    
    int count = 0;
    if (DirverCount == nil || [DirverCount isEqual: @""]) {
        count = 0;
    } else {
        count = [DirverCount intValue];
    }
    
    count++;
    
    NSString *noticeDirverCount = [NSString stringWithFormat:@"%d", count];
    
    // 将重新计算的个数保存
    [[NSUserDefaults standardUserDefaults] setObject:noticeDirverCount forKey:[NSString stringWithFormat:@"DirverCount%@", orderNumber]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}




/**
 *  订单用sectionHeader实现
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ELHOrderModel *orderModel =  self.orderArray[section];
    
    if (orderModel.ROState == 4) { // 执行状态
        ELHExecuteOrderView *executeOrderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ELHExecuteOrderView class]) owner:nil options:nil].firstObject;
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(executeSectionViewDidClick:)];
        [executeOrderView addGestureRecognizer:tap];
        [executeOrderView setTag:section];
        
        // 设置数据
        executeOrderView.orderModel = orderModel;
        
        if (self.orderDetailArray.count != 0) {
            NSArray *tempArray = [ELHOrderDetailModel mj_objectArrayWithKeyValuesArray:self.orderDetailArray[section]];
            if (tempArray.count != 0) {
                ELHOrderDetailModel *detailModel = tempArray[0];
                executeOrderView.orderDetailModel = detailModel;
            }
        }
        
        return executeOrderView;
        
    } else if (orderModel.ROState == 5) { // 运输状态
        ELHTransportOrderView *transportOrderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ELHTransportOrderView class]) owner:nil options:nil].firstObject;
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(executeSectionViewDidClick:)];
        [transportOrderView addGestureRecognizer:tap];
        [transportOrderView setTag:section];
        
        // 设置数据
        transportOrderView.orderModel = orderModel;
        
        if (self.orderDetailArray.count != 0) {
            NSArray *tempArray = [ELHOrderDetailModel mj_objectArrayWithKeyValuesArray:self.orderDetailArray[section]];
            if (tempArray.count != 0) {
                ELHOrderDetailModel *detailModel = tempArray[0];
                transportOrderView.orderDetailModel = detailModel;
            }
        }
        
        [transportOrderView.confirmButton setTag:section];
        [transportOrderView.unlockButton setTag:section];

        
        // 确认送达
//        [transportOrderView.confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 发送解封密码
        [transportOrderView.unlockButton addTarget:self action:@selector(unlockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return transportOrderView;
        
    } else {
        ELHOrderView *orderView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ELHOrderView class]) owner:nil options:nil].firstObject;
        
        // 设置数据
        orderView.orderModel = self.orderArray[section];
        
        
        NSString *DirverCount = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"DirverCount%@", orderView.orderModel.ROBM]];
//        BSLog(@"DirverCount = %@", DirverCount);
        
        if (DirverCount != nil && ![DirverCount isEqual:@"0"]) {
            orderView.biddingLabel.hidden = NO;
            orderView.biddingLabel.text = [NSString stringWithFormat:@"(已通知%@位司机)", DirverCount];
        } else {
            orderView.biddingLabel.hidden = YES;
        }
        
        
        [orderView setTag:section];
        // 添加手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClick:)];
//        [orderView addGestureRecognizer:tap];
        
        //  取消订单
        [orderView.cancelOrderButton addTarget:self action: @selector(cancelOrderButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [orderView.cancelOrderButton setTag:section];
        
        return orderView;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ELHOrderH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return ELHBiddingOrderH;
}



#pragma mark - 逻辑控制方法
/**
 *  新:点击执行状态的sectionView跳转到订单详情页
 */
- (void)executeSectionViewDidClick:(UITapGestureRecognizer *)tap {
    ELHPayViewController *payVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHPayViewController class]) bundle:nil].instantiateInitialViewController;
    NSInteger tag = [tap.view tag];
    if (self.orderArray.count != 0 && self.orderDetailArray.count != 0) {
        ELHOrderModel *orderModel = self.orderArray[tag];
        NSArray *tempArray = self.orderDetailArray[tag];
        ELHOrderDetailModel *orderDetailModel;
        if (tempArray.count != 0) {
            orderDetailModel = tempArray[0];
        }
        // 设置支付界面数据
        //订单编号
        payVC.orderNumber = orderModel.ROBM;
        payVC.orderModel = orderModel;
        payVC.orderDetailModel = orderDetailModel;
        // 订单ID
        payVC.ROId = orderModel.ROId;
        payVC.isExecuteOrder = YES;
        [self.navigationController pushViewController:payVC animated:YES];
    }
    
}

/**
 *  旧:点击了SectionHeader后调用此方法,展开sectionView
 */
static NSInteger tag;
- (void)sectionClick:(UITapGestureRecognizer *)tap {
    
    tag = [tap.view tag];
    
    //判断状态值
    if (self.stateArray.count != 0 && [self.stateArray[tag] isEqualToString:@"1"]){ // 展开状态,点击后收起
        NSArray *tempArray = self.orderDetailArray[tag];
        
        //修改
        [self.stateArray replaceObjectAtIndex:tag withObject:@"0"];
        self.orderTag = 0;
        
        
        // 修改tableView的frame
        ELHOrderModel *model = self.orderArray[tag];
        if (model.ROState == 4 || model.ROState == 5) {
            tempArray = @[];
        }
        CGFloat tableViewY = ScreenH - self.tableView.contentSize.height - ELHNavY + ELHBiddingOrderH * tempArray.count;
        CGFloat tableViewH = self.tableView.contentSize.height - ELHBiddingOrderH * tempArray.count;
        if (tableViewY < 0) {
            tableViewY = 0;
        }
        if (tableViewH > ScreenH - ELHNavY) {
            tableViewH = ScreenH - ELHNavY;
        }
        self.tableView.frame = CGRectMake(0, tableViewY, ScreenW, tableViewH);
        
    }else{ // 收起状态,点击后展开
        if (self.orderDetailArray.count != 0 && self.stateArray.count != 0) {
            NSArray *tempArray = self.orderDetailArray[tag];
            [self.stateArray replaceObjectAtIndex:tag withObject:@"1"];
            self.orderTag = 1;
            
            ELHOrderModel *model = self.orderArray[tag];
            if (model.ROState == 4 || model.ROState == 5) {
                tempArray = @[];
            }
            CGFloat tableViewY = ScreenH - self.tableView.contentSize.height - ELHNavY - ELHBiddingOrderH * tempArray.count;
            CGFloat tableViewH = self.tableView.contentSize.height + ELHBiddingOrderH * tempArray.count;
            if (tableViewY < 0) {
                tableViewY = 0;
            }
            if (tableViewH > ScreenH - ELHNavY) {
                tableViewH = ScreenH - ELHNavY;
            }
            self.tableView.frame = CGRectMake(0, tableViewY, ScreenW, tableViewH);
        }
        
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ELHorderButtonDidClickNotification object:nil];
}

/**
 *  取消订单
 */
- (void)cancelOrderButtonClick:(UIButton *)button {
    BSLog(@"cancelButtonTag = %ld", (long)button.tag);
    
    NSString *title = @"取消订单";
    NSString *message = @"订单取消后不可恢复,是否确认取消订单?";
    NSString *cancelButtonTitle = @"取消";
    NSString *confirmButtonTitle = @"确认";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSInteger tag = button.tag;
        ELHOrderModel *model = self.orderArray[tag];
        
        if (model.ROId != nil) {
            // 取消订单
            NSDictionary *dict = @{
                                   @"ROId" : model.ROId,
                                   };
            
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            
            
            NSString *URL = [NSString stringWithFormat:@"%@RealtimeOrder_CansolOrderForGO.action", ELHBaseURL];
            
            //        ELHWeakSelf;
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSString *resultStr =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSData *reslutData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:reslutData options:NSJSONReadingMutableContainers error:nil];
                
                if ([resultDict[@"resultSign"] isEqual:@"-1"]) {
                    [SVProgressHUD showImage:nil status:@"异常失败"];
                    return;
                    
                } else {
                    [SVProgressHUD showImage:nil status:@"成功"];
                    
                    // 移除 已通知司机 的缓存key
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"DirverCount%@",model.ROBM]];
                    
                    // 发送取消订单的通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:ELHcancelOrderButtonClickNotification object:nil];
                }
                
                [self.tableView reloadData];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
        }
        
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  确认送达
 */
- (void)confirmButtonClick:(UIButton *)button {
    BSLog(@"确认送达按钮的Tag值 = %lu", button.tag);

    NSInteger untransportCount = 0;
    for (int i = 0; i < self.orderArray.count ; i++) {
        ELHOrderModel *model = self.orderArray[i];
        if (model.ROState < 5) {
            untransportCount++;
        }
        self.confirmTag = button.tag - untransportCount;
    }
    BSLog(@"大头针的订单的Tag值 = %lu", self.confirmTag);
    
    
    NSString *title = @"系统提示";
    NSString *message = @"请您确认收货人已成功解封后再确认收货!";
    NSString *cancelButtonTitle = @"取消";
    NSString *confirmButtonTitle = @"确认";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"已发送确认指令,请等待反馈"];
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"GOId"];
        
        ELHOrderModel *model = self.orderArray[button.tag];
        BSLog(@"\nGOId(用户ID) 为 : %@\n ROId(订单ID) 为 : %@ \n COId(车主ID) 为 : %@", userID, model.ROId, model.COId);
        // 确认送达
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               @"ROId" : model.ROId,
                               @"COId" : model.COId,
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        
        
        NSString *URL = [NSString stringWithFormat:@"%@Purse_finishPurse.action", ELHBaseURL];
        
        //        ELHWeakSelf;
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            BSLog(@"确认收货 : %@", responseObject);
            NSString *resultStr =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *reslutData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:reslutData options:NSJSONReadingMutableContainers error:nil];
            if ([resultDict[@"resultSign"] isEqual:@"-1"]) {
                [SVProgressHUD showImage:nil status:@"异常失败"];
            } else if ([resultDict[@"resultSign"] isEqual:@"1"]) {
                [SVProgressHUD showImage:nil status:@"成功"];
                
                // 发送一个确认送达的通知,通知主界面重新请求订单数据,达到刷新订单的目的
                [[NSNotificationCenter defaultCenter] postNotificationName:ELHConfirmServiceNotification object:nil];
                
            } else if ([resultDict[@"resultSign"] isEqual:@"2"]) {
                [SVProgressHUD showImage:nil status:@"没有此单"];
            } else {
                [SVProgressHUD showImage:nil status:@"锁状态不正确"];
            }
            
            
            
            [self.tableView reloadData];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 *  发送解封密码
 */
- (void)unlockButtonClick:(UIButton *)button {
    BSLog(@"unlockButtonTag = %ld", (long)button.tag);
    
    NSInteger tag = button.tag;
    ELHOrderModel *model = self.orderArray[tag];
    NSString *title = @"解封密码短信内容";
    NSString *message = [NSString stringWithFormat:@"发件人:%@\n收件人:%@\n内容:您当前的运单密码锁解封密码是(%@)。重要密码请妥善保管。", model.COCLoadM, model.COCUnloadM, model.COPassword];
    NSString *cancelButtonTitle = @"取消发送";
    NSString *confirmButtonTitle = @"确认发送";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 发送短信
        [SVProgressHUD showWithStatus:@"正在发送中..."];
        // 请求参数
        NSDictionary *params = @{
                                 @"userid" : @"4039",
                                 @"account" : @"易拉货",
                                 @"password" : @"elahuo123NET",
                                 @"mobile" : model.COCUnloadM,
                                 @"content" : [NSString stringWithFormat:@"您当前的运单密码锁解封密码是(%@)。重要密码请妥善保管。【e拉货】", model.COPassword],
                                 @"sendTime" : @"", // 为空表示立即发送，定时发送格式2010-10-24 09:08:10
                                 @"action" : @"send",
                                 @"extno" : @""
                                 };
        
        
        NSString *URL = @"http://211.147.242.161:8888/sms.aspx";
        
        
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            BSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [SVProgressHUD showImage:nil status:@"成功发货,解封密码已发送给收货人"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showImage:nil status:@"解封密码发送失败"];
            BSLog(@"%@", error);
        }];
        
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}



/**
 *  调用短信接口发送短信,本app不使用此方法
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            
            break;
        default:
            break;
    }
}
/**
 *  发送短信的相关方法
 */
-(void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = ELHGlobalColor;
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}



@end
