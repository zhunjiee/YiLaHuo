//
//  ELHIdentityCardViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/3/11.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELHPlaceholderTextField.h"


@interface ELHIdentityCardViewController : UITableViewController

@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIImageView *idCardImageView; // 身份证照片
@property (weak, nonatomic) IBOutlet UIImageView *idCardPlaceholderImageView; // 身份证实例照片

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;

@end
