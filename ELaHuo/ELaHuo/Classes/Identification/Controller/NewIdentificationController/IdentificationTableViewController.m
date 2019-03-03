//
//  IdentificationTableViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/7/5.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "IdentificationTableViewController.h"
#import "CheckPictureView.h"

@interface IdentificationTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *trueNameLable;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLable;
@property (weak, nonatomic) IBOutlet UILabel *licenseNumberLabel;

@property (weak, nonatomic) CheckPictureView *checkView;
@end

@implementation IdentificationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpUserInfo];
}

/**
 *  加载用户信息
 */
- (void)setUpUserInfo {
    self.trueNameLable.text = self.trueName;
    self.companyNameLable.text = self.companyName;
    self.licenseNumberLabel.text = self.licenseNumber;
    
}


/**
 *  查看身份证图片
 */
- (IBAction)checkIdCardPicture:(UIButton *)button {
    BSLog(@"%ld",(long)button.tag);
    [self createCheckPictureViewWithTag:button.tag];
}
/**
 *  查看营业执照图片
 */
- (IBAction)checkLicensePicture:(UIButton *)button {
    BSLog(@"%ld",(long)button.tag);
    [self createCheckPictureViewWithTag:button.tag];
}
/**
 *  创建查看图片视图
 */
- (void)createCheckPictureViewWithTag:(NSInteger)tag {
    self.tableView.bounces = NO;
    
    CheckPictureView *checkView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CheckPictureView class]) owner:nil options:nil].firstObject;
    BSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    checkView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    
    [self.view addSubview:checkView];
    
    self.checkView = checkView;

    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"]; // 用户ID
    NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID]; // 身份证照片名称
    NSString *licenseNumPicName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID]; // 营业执照照片名称
    if (tag == 1) { // 身份证照片
        UIImage *idCardImage = [self loadPictureFromCachesPath:idCardPictureName];
        self.checkView.imageView.image = idCardImage;
    } else if (tag == 2) { // 营业执照照片
        UIImage *licenseImage = [self loadPictureFromCachesPath:licenseNumPicName];
        self.checkView.imageView.image = licenseImage;
    }
    
    [checkView.closeButton addTarget:self action:@selector(closeCheckPictureView) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  加载图片
 */
- (UIImage *)loadPictureFromCachesPath:(NSString *)pictureName {
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *file = [cachesPath stringByAppendingPathComponent:pictureName];
    NSData *imageData = [NSData dataWithContentsOfFile:file];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

- (void)closeCheckPictureView {
    self.tableView.bounces = YES;
    [self.checkView removeFromSuperview];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 根据有无企业信息决定显示几组section
    return self.sectionCount;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    return 0.00001;
}

@end
