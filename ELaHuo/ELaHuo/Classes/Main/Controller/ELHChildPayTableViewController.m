//
//  ELHChildPayTableViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/6/20.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHChildPayTableViewController.h"
#import "ELHOrderDetailModel.h"
#import "ELHOrderModel.h"
#import "ELHOCToJson.h"
#import "UPPaymentControl.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import <MJExtension.h>
#import "ELHMyWalletModel.h"
#import "ELHCarLevel.h"

@interface ELHChildPayTableViewController ()
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 存放红包数据的数组 */
@property (nonatomic, strong) NSMutableArray *redEnvelopeArray;
/** 存放红包金额的数据 */
@property (nonatomic, strong) NSMutableArray *redEnvelopeAmountArray;
/** 存放可用红包的数组 */
@property (nonatomic, strong) NSMutableArray *availableArray;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;

@end

@implementation ELHChildPayTableViewController
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
/** redEnvelopeAmountArray的懒加载 */
- (NSMutableArray *)redEnvelopeAmountArray{
    if (!_redEnvelopeAmountArray) {
        _redEnvelopeAmountArray = [NSMutableArray array];
    }
    return _redEnvelopeAmountArray;
}
/** availableArray的懒加载 */
- (NSMutableArray *)availableArray{
    if (!_availableArray) {
        _availableArray = [NSMutableArray array];
    }
    return _availableArray;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpPayInfo];
    
    [self loadRedEnvelopeData];

}

/**
 *  设置支付界面信息
 */
- (void)setUpPayInfo {
    // 设置支付页面相关数据
    self.loadLabal.text = self.orderModel.ROLoadSite; // 出发地
    self.unloadLabel.text = self.orderModel.ROUnloadSite; // 目的地
    self.mileageLabel.text = [NSString stringWithFormat:@"%.0f公里", self.orderModel.ROKM]; // 里程
    [self.unloadPhoneButton setTitle:self.orderModel.COCUnloadM forState:UIControlStateNormal];  // 收货人电话
    [self.unloadPhoneButton addTarget:self action:@selector(callUnloadPhoneNumber:) forControlEvents:UIControlEventTouchUpInside]; // 打电话
    
    
    // 车主姓名
    NSString *dirverName;
    if (self.orderDetailModel.COName.length > 3) {
        dirverName = [self.orderDetailModel.COName substringWithRange:NSMakeRange(0, 2)];
    } else {
        dirverName = [self.orderDetailModel.COName substringWithRange:NSMakeRange(0, 1)];
    }
    self.dirverNameLabel.text = [NSString stringWithFormat:@"%@师傅", dirverName];
    // 司机电话
    if (self.isExecuteOrder == YES) {
        self.dirverPhoneLabel.text = self.orderDetailModel.COMobile;
    } else {
        self.dirverPhoneLabel.text = [NSString stringWithFormat:@"%@****%@", [self.orderDetailModel.COMobile substringWithRange:NSMakeRange(0, 3)], [self.orderDetailModel.COMobile substringWithRange:NSMakeRange(7, 4)]];
    }
    // 司机星级
    if ([self.orderDetailModel.COPJStar floatValue] >= 0 && [self.orderDetailModel.COPJStar floatValue] < 1) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] >= 1 && [self.orderDetailModel.COPJStar floatValue] < 2) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] >= 2 && [self.orderDetailModel.COPJStar floatValue] < 3) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] >= 3 && [self.orderDetailModel.COPJStar floatValue] < 4) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] >= 4 && [self.orderDetailModel.COPJStar floatValue] < 5) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 5) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_selected"]];
        
    }
    
    
    // 车辆级别
    NSString *level = [ELHCarLevel setUpCarLevel:[NSString stringWithFormat:@"%d", self.orderModel.COCLevel]];
    if (self.orderModel.ROIsWB == 1 && self.orderModel.ROCMNum == 1) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板/侧门", level];
    } else if (self.orderModel.ROIsWB == 1 && self.orderModel.ROCMNum == 0) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板", level];
    } else if (self.orderModel.ROIsWB == 0 && self.orderModel.ROCMNum == 1) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/侧门", level];
    } else {
        self.carLevelLabel.text = level;
    }
    
    // 车牌号
    self.carNumberLabel.text = self.orderDetailModel.COCPLATENUMBER;
    
    self.dirverPriceLabel.text = [NSString stringWithFormat:@"%.0f元", [self.orderDetailModel.Price floatValue]]; // 车主报价

}


- (void)callUnloadPhoneNumber:(UIButton *)button {
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", button.titleLabel.text]];
    if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
        [[UIApplication sharedApplication] openURL:telURL];
    }
}


/**
 *  加载红包数据
 */
- (void)loadRedEnvelopeData {
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
            
            // 字典数组转模型数组
            weakSelf.redEnvelopeArray = [ELHMyWalletModel mj_objectArrayWithKeyValuesArray:responseObject];
            
            float maxAmount = 0; // 最大红包
            float redEnvelopeAmount = 0; // 当前红包
            // 1. 先获取满足车主报价的所有红包
            if (weakSelf.redEnvelopeArray.count != 0) {
                for (int i = 0; i < weakSelf.redEnvelopeArray.count; i++) {
                    ELHMyWalletModel *redEnvelopeModel = weakSelf.redEnvelopeArray[i];
                    
                    
                    // 如果红包'满多少可用'小于等于'司机报价',红包可用
                    if ([redEnvelopeModel.VCFullAmount floatValue] <= [weakSelf.orderDetailModel.Price floatValue]) { // 有可用优惠券
                        // 创建数组用于保存可用红包
                        [weakSelf.availableArray addObject:weakSelf.redEnvelopeArray[i]];// 可用红包
                        
                        // 根据array数组中存储的i值获取最大的红包金额
                        NSInteger index = 0; // 记录最大可用红包的索引
                        for (int j = 0; j < weakSelf.availableArray.count; j++) {
                            ELHMyWalletModel *availableModel = weakSelf.availableArray[j];
                            redEnvelopeAmount = [redEnvelopeModel.VCAmount floatValue];
                            
                            
                            // 如果筛选到的红包 大于 最大优惠价格, 改变最大价格
                            if (redEnvelopeAmount > maxAmount) {
                                maxAmount = redEnvelopeAmount;
                                index = j; // 记录最大值得索引
                                // 设置数据
                                self.couponLabel.text = [NSString stringWithFormat:@"%.0f元", maxAmount]; // 优惠价格
                                float originalPrice = [weakSelf.orderDetailModel.Price floatValue];
                                float actualPrice = originalPrice - maxAmount;
                                self.actualPriceLabel.text = [NSString stringWithFormat:@"%.0f元" ,actualPrice]; // 实际价格
                                
                                // 传递真实价格给父控制器
                                if ([self.delegate respondsToSelector:@selector(getOriginalPrice:ActualPrice:andRedEnvelope:)]) {
                                    
                                    [self.delegate getOriginalPrice:[NSString stringWithFormat:@"%.0f", originalPrice * 100] ActualPrice:[NSString stringWithFormat:@"%.0f", actualPrice * 100] andRedEnvelope:availableModel.VCId];
                                    
                                }
                            } else if (redEnvelopeAmount == maxAmount) { // 如果筛选到的红包 等于 最大优惠价格, 判断过期日期
                                // 拿到筛选到的红包模型
                                NSInteger availbaleTerm = [availableModel.VCTerm integerValue]; // 期限
                                NSString *availableGetTime = availableModel.VCGetTime; // 获取时间
                                NSTimeInterval Term_day = availbaleTerm * 24 * 60 * 60;
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                                NSDate *availableDate = [formatter dateFromString:availableGetTime];
                                NSDate *dueDate = [availableDate dateByAddingTimeInterval:Term_day]; // 过期日期
                                
                                // 拿到最大值得红包模型
                                ELHMyWalletModel *maxAvailableModel = weakSelf.availableArray[index];
                                NSInteger maxAvailbaleTerm = [maxAvailableModel.VCTerm integerValue]; // 期限
                                NSString *maxAvailableGetTime = maxAvailableModel.VCGetTime; // 获取时间
                                NSTimeInterval maxTerm_day = maxAvailbaleTerm * 24 * 60 * 60;
                                NSDate *maxDate = [formatter dateFromString:maxAvailableGetTime];
                                NSDate *maxDueDate = [maxDate dateByAddingTimeInterval:maxTerm_day]; // 过期日期
                                
                                // 比较过期日期
                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
                                NSDateComponents *cmps = [calendar components:unit fromDate:dueDate toDate:maxDueDate options:0];
                                
                                // 现有红包过期日期比最大红包过期日期早,用现有红包吧
                                if (cmps.year < 0 && cmps.month < 0 && cmps.day < 0 && cmps.hour < 0 && cmps.minute < 0) {
                                    // 设置数据
                                    self.couponLabel.text = [NSString stringWithFormat:@"%.0f元", redEnvelopeAmount]; // 优惠价格
                                    float originalPrice = [weakSelf.orderDetailModel.Price floatValue];
                                    float actualPrice = originalPrice - redEnvelopeAmount;
                                    self.actualPriceLabel.text = [NSString stringWithFormat:@"%.0f元" , actualPrice]; // 实际价格
                                    
                                    // 传递真实价格给父控制器
                                    if ([self.delegate respondsToSelector:@selector(getOriginalPrice:ActualPrice:andRedEnvelope:)]) {
                                        
                                        [self.delegate getOriginalPrice:[NSString stringWithFormat:@"%.0f", originalPrice * 100] ActualPrice:[NSString stringWithFormat:@"%.0f", actualPrice * 100] andRedEnvelope:maxAvailableModel.VCId];
                                        
                                    }
                                } else { // 使用最大红包
                                    // 设置数据
                                    self.couponLabel.text = [NSString stringWithFormat:@"%.0f元", maxAmount]; // 优惠价格
                                    float originalPrice = [weakSelf.orderDetailModel.Price floatValue];
                                    float actualPrice = originalPrice - maxAmount;
                                    
                                    self.actualPriceLabel.text = [NSString stringWithFormat:@"%.0f元" ,actualPrice]; // 实际价格
                                    
                                    // 传递真实价格给父控制器
                                    if ([self.delegate respondsToSelector:@selector(getOriginalPrice:ActualPrice:andRedEnvelope:)]) {
                                        [self.delegate getOriginalPrice:[NSString stringWithFormat:@"%.0f", originalPrice * 100] ActualPrice:[NSString stringWithFormat:@"%.0f", actualPrice * 100] andRedEnvelope:availableModel.VCId];
                                        
                                    }
                                }
                            }
                        }
                        
                        
                    } else { // 没有可用优惠券
                        self.couponLabel.text = @"无可用优惠券";
                        float actualPrice = [self.orderDetailModel.Price floatValue]; // 优惠后价格
                        float originalPrice = actualPrice; // 原始价格
                        self.actualPriceLabel.text = [NSString stringWithFormat:@"%.0f元", actualPrice];
                        
                        // 传递真实价格给父控制器
                        if ([self.delegate respondsToSelector:@selector(getOriginalPrice:ActualPrice:andRedEnvelope:)]) {
                            
                            [self.delegate getOriginalPrice:[NSString stringWithFormat:@"%.0f", originalPrice * 100] ActualPrice:[NSString stringWithFormat:@"%.0f", actualPrice * 100] andRedEnvelope:@""];
                        }
                    }
                    
                }
                
            } else {
                self.couponLabel.text = @"无可用优惠券";
                float actualPrice = [self.orderDetailModel.Price floatValue]; // 优惠后价格
                float originalPrice = actualPrice; // 原始价格
                self.actualPriceLabel.text = [NSString stringWithFormat:@"%.0f元", actualPrice];
                
                // 传递真实价格给父控制器
                if ([self.delegate respondsToSelector:@selector(getOriginalPrice:ActualPrice:andRedEnvelope:)]) {
                    
                    [self.delegate getOriginalPrice:[NSString stringWithFormat:@"%.0f", originalPrice * 100] ActualPrice:[NSString stringWithFormat:@"%.0f", actualPrice * 100] andRedEnvelope:@""];
                }
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
            
        }];
    }
}


#pragma UITable相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isExecuteOrder == YES) {
        return 2;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    return 0.00001;
}

@end

