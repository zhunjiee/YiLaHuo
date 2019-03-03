//
//  DirverInfoViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/6/17.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderDetailModel;

@interface DirverInfoViewController : UITableViewController
// 竞价订单模型
@property (strong, nonatomic) ELHOrderDetailModel *orderDetailModel;

@property (copy, nonatomic) NSString *COId;

@end
