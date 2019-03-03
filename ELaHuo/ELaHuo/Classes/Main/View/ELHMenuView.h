//
//  ELHMenuView.h
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELHButton.h"

@interface ELHMenuView : UIView

@property (weak, nonatomic) IBOutlet ELHButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *trueNameIdentity; // 实名认证状态
@property (weak, nonatomic) IBOutlet UIButton *companyIdentity; // 企业认证状态

@property (weak, nonatomic) IBOutlet ELHButton *historyOrderButton;
@property (weak, nonatomic) IBOutlet ELHButton *identificationButton;
@property (weak, nonatomic) IBOutlet ELHButton *myWalletButton;
@property (weak, nonatomic) IBOutlet ELHButton *settingButton;

@end
