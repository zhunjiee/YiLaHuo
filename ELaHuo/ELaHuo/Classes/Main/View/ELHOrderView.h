//
//  ELHOrderView.h
//  ELaHuo
//
//  Created by elahuo on 16/3/28.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderModel;

@interface ELHOrderView : UIView

/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
// 取消订单
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;
// 竞价个数
@property (weak, nonatomic) IBOutlet UILabel *biddingLabel;

@end
