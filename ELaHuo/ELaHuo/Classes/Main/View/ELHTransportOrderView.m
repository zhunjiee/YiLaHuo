//
//  ELHTransportOrderView.m
//  ELaHuo
//
//  Created by elahuo on 16/4/25.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHTransportOrderView.h"
#import "ELHOrderModel.h"
#import "ELHOrderDetailModel.h"
#import "ELHCarLevel.h"

@interface ELHTransportOrderView ()
@property (weak, nonatomic) IBOutlet UILabel *loadTimeLabel; // 订单时间
@property (weak, nonatomic) IBOutlet UILabel *loadLocationLabel; // 装货地点
@property (weak, nonatomic) IBOutlet UILabel *unloadLocationLabel; // 卸货地点

@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel; // 订单价格
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel; // 里程
@property (weak, nonatomic) IBOutlet UILabel *dirverNameLabel; // 车主姓名
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel; // 车辆级别
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel; // 订单编号

@end

@implementation ELHTransportOrderView

- (void)setOrderModel:(ELHOrderModel *)orderModel {
    _orderModel = orderModel;
    
    self.loadTimeLabel.text = orderModel.ROLoadTime;
    self.loadLocationLabel.text = orderModel.ROLoadSite;
    self.unloadLocationLabel.text = orderModel.ROUnloadSite;
    // 订单编号
    self.orderNumLabel.text = [NSString stringWithFormat:@"订单编号:%@", orderModel.ROBM];
    // 订单价格
    self.orderPriceLabel.text = [NSString stringWithFormat:@"%.0f元", orderModel.ROPrice];
    
    // 公里
    self.mileageLabel.text = [NSString stringWithFormat:@"%.0f公里", orderModel.ROKM];
    
    // 车辆级别
    NSString *level = [ELHCarLevel setUpCarLevel:[NSString stringWithFormat:@"%d", orderModel.COCLevel]];
    if (orderModel.ROIsWB == 1 && orderModel.ROCMNum == 1) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板/侧门", level];
    } else if (orderModel.ROIsWB == 1 && orderModel.ROCMNum == 0) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板", level];
    } else if (orderModel.ROIsWB == 0 && orderModel.ROCMNum == 1) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/侧门", level];
    } else {
        self.carLevelLabel.text = level;
    }
}

- (void)setOrderDetailModel:(ELHOrderDetailModel *)orderDetailModel {
    _orderDetailModel = orderDetailModel;
    
    // 车主姓名
    NSString *dirverName;
    if (orderDetailModel.COName.length > 3) {
        dirverName = [orderDetailModel.COName substringWithRange:NSMakeRange(0, 2)];
    } else {
        dirverName = [orderDetailModel.COName substringWithRange:NSMakeRange(0, 1)];
    }
    self.dirverNameLabel.text = [NSString stringWithFormat:@"%@师傅", dirverName];
}

@end
