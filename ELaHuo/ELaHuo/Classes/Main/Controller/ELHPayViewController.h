//
//  ELHPayViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/4/1.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderDetailModel;
@class ELHOrderModel;

@interface ELHPayViewController : UIViewController

// 确认支付按钮
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
/** 竞价订单模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;

/** 订单编号 */
@property (nonatomic, strong) NSString *orderNumber;
/** 订单ID */
@property (nonatomic, strong) NSString *ROId;
@property (assign, nonatomic) BOOL isExecuteOrder; // 是执行订单,显示完整的司机电话
@end
