//
//  IdentificationTableViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/7/5.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IdentificationTableViewController : UITableViewController

@property (assign, nonatomic) NSUInteger sectionCount;
@property (copy, nonatomic) NSString *trueName;
@property (copy, nonatomic) NSString *companyName;
@property (copy, nonatomic) NSString *licenseNumber;

@end
