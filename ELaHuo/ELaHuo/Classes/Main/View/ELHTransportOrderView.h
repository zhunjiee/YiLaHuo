//
//  ELHTransportOrderView.h
//  ELaHuo
//
//  Created by elahuo on 16/4/25.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderModel;
@class ELHOrderDetailModel;

@interface ELHTransportOrderView : UIView
// 发送解封密码按钮
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
// 确认送达按钮
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
/** 竞价列表模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;
@end
