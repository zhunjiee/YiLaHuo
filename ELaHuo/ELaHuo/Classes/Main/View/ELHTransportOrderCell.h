//
//  ELHTransportOrderCell.h
//  ELaHuo
//
//  Created by elahuo on 16/3/31.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderModel;

@interface ELHTransportOrderCell : UITableViewCell
/** 订单详情模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
// 发送解封密码
@property (weak, nonatomic) IBOutlet UIButton *unblockButton;

@end
