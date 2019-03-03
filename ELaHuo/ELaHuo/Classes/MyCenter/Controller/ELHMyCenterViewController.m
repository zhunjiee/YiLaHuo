//
//  ELHMyCenterViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/4/19.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMyCenterViewController.h"
#import "ELHHTTPSessionManager.h"
#import <SVProgressHUD.h>
#import "ELHOCToJson.h"

@interface ELHMyCenterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlyCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end

@implementation ELHMyCenterViewController
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpInfo];
    
    self.navigationItem.title = @"个人中心";
    
    self.tableView.allowsSelection = NO;
}

/**
 *  设置数据信息
 */
- (void)setUpInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.phoneNumberLabel.text = [userDefaults stringForKey:@"name"];
    self.onlyCodeLabel.text = [userDefaults stringForKey:@"GOOnlyCode"];
    
    NSString *name = [userDefaults stringForKey:@"GOName"];
    if (name.length != 0) {
        self.nameTextField.text = name;
        
    } else {
        NSString *userID = [userDefaults stringForKey:@"GOId"];
        if (userID != nil) {
            NSDictionary *dict = @{
                                   @"GOId" : userID,
                                   };
            
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_getGOInfoById.action", ELHBaseURL];
            
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject[@"GOName"] != nil) {
                    self.nameTextField.text = responseObject[@"GOName"];
                    [userDefaults setObject:responseObject[@"GOName"] forKey:@"GOName"];
                } else {
                    self.nameTextField.text = nil;
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
        }
    }
}

// 更换头像
- (IBAction)headerButtonDidClick {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击拍照
        [SVProgressHUD showImage:nil status:@"敬请期待"];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 从相册选取图片
        [SVProgressHUD showImage:nil status:@"敬请期待"];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}


@end
