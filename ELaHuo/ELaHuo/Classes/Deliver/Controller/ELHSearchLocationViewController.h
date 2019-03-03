//
//  ELHSearchLocationViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/3/18.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHSearchLocationViewController;

@protocol ELHSearchLocationDeleagte <NSObject>

@optional
// 点击cell后通知代理接收地点数据
- (void)searchLocationViewController:(ELHSearchLocationViewController *)searchVC didAddLoaction:(NSString *)location andCLLocationPoint:(NSValue *)point;

@end

@interface ELHSearchLocationViewController : UIViewController
/** 代理属性 */
@property (nonatomic, weak) id<ELHSearchLocationDeleagte> delegate;

@end
