//
//  ELHMyWalletCell.h
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHMyWalletModel;

@interface ELHMyWalletCell : UITableViewCell
// 使用条件
@property (weak, nonatomic) IBOutlet UILabel *limitUseLabel;

/** 红包模型 */
@property (nonatomic, strong) ELHMyWalletModel *myWalletModel;
@end
