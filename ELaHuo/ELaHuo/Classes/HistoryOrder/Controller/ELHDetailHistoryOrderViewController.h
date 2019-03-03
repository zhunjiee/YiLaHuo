//
//  ELHDetailHistoryOrderViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHHistoryOrderModel;

@interface ELHDetailHistoryOrderViewController : UITableViewController
/** 历史订单模型 */
@property (nonatomic, strong) ELHHistoryOrderModel *HistoryOrder;
@end
