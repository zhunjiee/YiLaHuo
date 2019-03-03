//
//  ELHMyWalletModel.m
//  ELaHuo
//
//  Created by elahuo on 16/4/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMyWalletModel.h"

@implementation ELHMyWalletModel
// 时间
- (NSString *)VCGetTime {
    if (_VCGetTime != nil) {
        _VCGetTime = [_VCGetTime substringWithRange:NSMakeRange(0, 16)];
    }
    
    return _VCGetTime;
}


@end
