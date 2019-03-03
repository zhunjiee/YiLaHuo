//
//  ELHOrderDetailCell.h
//  ELaHuo
//
//  Created by elahuo on 16/3/31.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderDetailModel;

@interface ELHOrderDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *dirverHeadButton; // 司机头像

/** 订单详情模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;
@end
