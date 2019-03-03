//
//  ELHLicenseViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/3/11.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELHPlaceholderTextField.h"

@interface ELHLicenseViewController : UITableViewController

@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *nameTextField;
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *licenseTextField;

@property (weak, nonatomic) IBOutlet UIImageView *licenseImageView; // 营业执照照片
@property (weak, nonatomic) IBOutlet UIImageView *licensePlaceholderImageView; // 营业执照示例图片

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

@end
