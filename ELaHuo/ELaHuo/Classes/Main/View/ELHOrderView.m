//
//  ELHOrderView.m
//  ELaHuo
//
//  Created by elahuo on 16/3/28.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHOrderView.h"
#import "ELHOrderModel.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHCarLevel.h"
#import "TimeFormat.h"

@interface ELHOrderView ()
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel; // 订单时间
@property (weak, nonatomic) IBOutlet UILabel *loadLocationLabel; // 装货地点
@property (weak, nonatomic) IBOutlet UILabel *statusLabel; // 订单状态
@property (weak, nonatomic) IBOutlet UILabel *unloadLocationLabel; // 卸货地点

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel; // 订单编号
@property (weak, nonatomic) IBOutlet UILabel *milageLabel; // 里程
@property (weak, nonatomic) IBOutlet UILabel *carLevleLabel; // 车辆级别
@property (weak, nonatomic) IBOutlet UILabel *slideDoorLabel; // 尾板/侧门

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end


@implementation ELHOrderView
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}


/**
 *  设置sectionHeader数据
 */
- (void)setOrderModel:(ELHOrderModel *)orderModel {
    _orderModel = orderModel;
    
    self.orderTimeLabel.text = [TimeFormat ROLoadTimeDateFormat:orderModel.ROLoadTime];
    self.loadLocationLabel.text = orderModel.ROLoadSite;
    self.statusLabel.text = [self orderState];
    self.unloadLocationLabel.text = orderModel.ROUnloadSite;
    self.orderNumberLabel.text = [NSString stringWithFormat:@"订单编号:%@", orderModel.ROBM];
    self.milageLabel.text = [NSString stringWithFormat:@"%.0f公里", orderModel.ROKM];
    self.carLevleLabel.text = [ELHCarLevel setUpCarLevel:[NSString stringWithFormat:@"%d", orderModel.COCLevel]];
    if (orderModel.ROIsWB == 1 && orderModel.ROCMNum == 1) {
        self.slideDoorLabel.text = @"尾板/侧门";
    } else if (orderModel.ROIsWB == 1 && orderModel.ROCMNum == 0) {
        self.slideDoorLabel.text = @"尾板";
    }else if (orderModel.ROIsWB == 0 && orderModel.ROCMNum == 1) {
        self.slideDoorLabel.text = @"侧门";
    } else {
        self.slideDoorLabel.text = @"";
    }
}



/**
 *  返回订订单的状态
 *
 */
- (NSString *)orderState {
    if (self.orderModel.ROState == 1) {
        return @"发布";
    } else if (self.orderModel.ROState == 2) {
        return @"竞价";
    } else if (self.orderModel.ROState == 3) {
        return @"交易";
    } else if (self.orderModel.ROState == 4) {
        return @"执行";
    } else if (self.orderModel.ROState == 5) {
        return @"运输";
    } else if (self.orderModel.ROState == 6) {
        return @"结束";
    } else {
        return @"评价";
    }
}
@end
