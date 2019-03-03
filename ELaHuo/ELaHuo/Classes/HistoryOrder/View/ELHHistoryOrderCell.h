//
//  ELHHistoryOrderCell.h
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHHistoryOrderModel;

@interface ELHHistoryOrderCell : UITableViewCell
/** 评价按钮 */
@property (weak, nonatomic) IBOutlet UIButton *assessButton;
/** 选中按钮:点击跳转到订单详情界面 */
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
/** 取消订单标志 */
@property (weak, nonatomic) IBOutlet UIImageView *cancelOrderImage;
/** 历史订单模型 */
@property (nonatomic, strong) ELHHistoryOrderModel *historyOrderModel;
@end
