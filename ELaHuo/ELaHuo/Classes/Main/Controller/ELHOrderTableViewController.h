//
//  ELHOrderTableViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/3/24.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELHOrderTableViewController : UITableViewController

/** 订单tag标志 */
@property (nonatomic, assign) NSInteger orderTag;
/** 确认送达按钮tag */
@property (nonatomic, assign) NSInteger confirmTag;

/** 存放表格状态的数组: 展开还是收起 */
@property (nonatomic, strong) NSMutableArray *stateArray;
/** 存放订单列表的数组 */
@property (nonatomic, strong) NSMutableArray *orderArray;
/** 存放竞价订单的数组 */
@property (nonatomic, strong) NSMutableArray *orderDetailArray;
/** 存放订单编号的数组 */
@property (nonatomic, strong) NSMutableArray *orderNumArray;

@end
