//
//  ELHExecuteOrderView.h
//  ELaHuo
//
//  Created by elahuo on 16/4/22.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderModel;
@class ELHOrderDetailModel;

@interface ELHExecuteOrderView : UIView
/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
/** 竞价列表模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;
@end
