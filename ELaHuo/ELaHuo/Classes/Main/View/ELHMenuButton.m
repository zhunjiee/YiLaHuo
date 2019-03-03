//
//  ELHMenuButton.m
//  ELaHuo
//
//  Created by elahuo on 16/3/24.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMenuButton.h"

@implementation ELHMenuButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
}

@end
