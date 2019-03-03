//
//  ELHExecuteOrderView.m
//  ELaHuo
//
//  Created by elahuo on 16/4/22.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHExecuteOrderView.h"
#import "ELHOrderModel.h"
#import "ELHOrderDetailModel.h"
#import "ELHCarLevel.h"
#import "TimeFormat.h"

@interface ELHExecuteOrderView ()
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *unloadLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dirverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *milageLabel; // 里程
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel; // 订单编号

@end

@implementation ELHExecuteOrderView

- (void)setOrderModel:(ELHOrderModel *)orderModel {
    _orderModel = orderModel;
    
    // 订单编号
    self.orderNumberLabel.text = [NSString stringWithFormat:@"订单编号:%@", orderModel.ROBM];
    
    self.orderTimeLabel.text = [TimeFormat ROLoadTimeDateFormat:orderModel.ROLoadTime];
    self.loadLocationLabel.text = orderModel.ROLoadSite;
    self.unloadLocationLabel.text = orderModel.ROUnloadSite;
    if (orderModel.ROKM) {
        self.milageLabel.text = [NSString stringWithFormat:@"%0.f公里", orderModel.ROKM];
    } else {
        self.milageLabel.text = @"";
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
    
    // 车辆详情
    if ([orderDetailModel.COCISWB isEqual:@"1"] && [orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板/侧门", [ELHCarLevel setUpCarLevel:orderDetailModel.COCLEVEL]];
    } else if ([orderDetailModel.COCISWB isEqual:@"1"] && [orderDetailModel.COCCMNUM isEqual:@"0"]) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/尾板", [ELHCarLevel setUpCarLevel:orderDetailModel.COCLEVEL]];
    } else if ([orderDetailModel.COCISWB isEqual:@"0"] && [orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@/侧门", [ELHCarLevel setUpCarLevel:orderDetailModel.COCLEVEL]];
    } else {
        self.carLevelLabel.text = [NSString stringWithFormat:@"%@", [ELHCarLevel setUpCarLevel:orderDetailModel.COCLEVEL]];
    }
    
    // 车主报价
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f元", [orderDetailModel.Price floatValue]];
}

@end
