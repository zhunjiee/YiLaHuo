//
//  LicenseViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/6/13.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "LicenseViewController.h"
#import "IndentificationViewController.h"
#import "ELHPlaceholderTextField.h"
#import <SVProgressHUD.h>
#import "ELHButton.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHUploadImage.h"

@interface LicenseViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraint;
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *companyNameTextField; // 企业名称
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *licenseNumberTextField; // 营业执照号
@property (weak, nonatomic) IBOutlet UIImageView *licenseImageView; // 营业执照照片
@property (weak, nonatomic) IBOutlet ELHButton *uploadLicensePictureButton;
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end

@implementation LicenseViewController
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置图片圆角
    self.licenseImageView.layer.cornerRadius = 5;
    self.licenseImageView.layer.masksToBounds = YES;
    
    [self setUpNavigationBar];
    [self loadIdentificationInfo];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  加载认证数据
 */
- (void)loadIdentificationInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults stringForKey:@"GOId"];
    
    // 企业名称
    NSString *companyName = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOQYMC"];
    // 营业执照号
    NSString *licenseNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOZZH"];
    if (companyName.length != 0 && licenseNumber.length != 0) {
        // 本地有数据
        self.companyNameTextField.text = companyName;
        self.licenseNumberTextField.text = licenseNumber;
    } else {
        // 本地没有数据
        // 从网络下载数据
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_getGOInfoById.action", ELHBaseURL];
        
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            self.companyNameTextField.text = responseObject[@"GOQYMC"]; // 真实姓名
            self.licenseNumberTextField.text = responseObject[@"GOZZH"]; // 营业执照号
            
            // 保存信息到本地
            [userDefaults setObject:responseObject[@"GOQYMC"] forKey:@"GOQYMC"];
            [userDefaults setObject:responseObject[@"GOZZH"] forKey:@"GOZZH"];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
        
    }
    
    
    
    // 营业执照照片
    NSString *licenseNumPicName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID]; // 营业执照照片名称
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *file = [cachesPath stringByAppendingPathComponent:licenseNumPicName];
    NSData *licenseImageData = [NSData dataWithContentsOfFile:file];
    UIImage *licenseImage = [UIImage imageWithData:licenseImageData];
    if (licenseImage != nil) {
        // 本地有数据
        self.licenseImageView.image = licenseImage;
        // 隐藏上传按钮内容
        [self.uploadLicensePictureButton setTitle:nil forState:UIControlStateNormal];
        [self.uploadLicensePictureButton setImage:nil forState:UIControlStateNormal];
    } else {
        // 本地没有数据
        // 从网路下载数据
        // 下载图片
        NSString *imageURL = [NSString stringWithFormat:@"%@file/DownLoadServlet?imageBNType=GOZZPicture&imageFileName=%@", ELHBaseURL, licenseNumPicName];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *image = [UIImage imageWithData:imageData scale:1.0];
        BSLog(@"从网络获取营业执照图片 %@ ,大小为: %lu KB", image, imageData.length / 1024);
        
        if (image != nil) {
            self.licenseImageView.image = image;
            
            // 隐藏上传按钮内容
            [self.uploadLicensePictureButton setTitle:nil forState:UIControlStateNormal];
            [self.uploadLicensePictureButton setImage:nil forState:UIControlStateNormal];
            
            [self savePictureToCachesPath:image withScale:1.0];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 存储认证数据
    [[NSUserDefaults standardUserDefaults] setObject:self.companyNameTextField.text forKey:@"GOQYMC"];
    [[NSUserDefaults standardUserDefaults] setObject:self.licenseNumberTextField.text forKey:@"GOZZH"];
}


- (void)setUpNavigationBar {
    self.navigationItem.title = @"企业认证";
    
    // 自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icon_NavBackItem"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissFormViewController) forControlEvents:UIControlEventTouchUpInside];
    
    backButton.frame = CGRectMake(0, 0, 6, 22);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = item;
    
    if (ScreenH >= 667 && ScreenH < 736) { // iphone6
        self.bottomLineConstraint.constant = ScreenH * 0.2;
    } else if (ScreenH >= 736) { // iphone6 plus
        self.bottomLineConstraint.constant = ScreenH * 0.18;
    }
    
    [self.view layoutIfNeeded];
}

- (void)dismissFormViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

/**
 *  上传营业执照图片
 */
- (IBAction)uploadLicensePicture {
    BSLog(@"上传营业执照图片");
    [self choosePictureFromCamera:nil];
}

/**
 *  调用照相机拍照
 */
- (void)choosePictureFromCamera:(UITapGestureRecognizer *)tap {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        BSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}



/**
 *  进入系统相册选取图片
 */
- (void)choosePictureFromAlbum:(UITapGestureRecognizer *)tap {
    
    // 创建照片选择控制器
    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    // 设置数据源
    imagePickerVc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; // 系统相册
    // 设置代理
    imagePickerVc.delegate = self;
    
    //modal - 进入相册界面
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}




#pragma mark - <UIImagePickerControllerDelegate>
// 用户选择照片的时候调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];;
    
    if (image != nil) {
        self.licenseImageView.image = image;
        
        // 隐藏上传按钮内容
        [self.uploadLicensePictureButton setTitle:nil forState:UIControlStateNormal];
        [self.uploadLicensePictureButton setImage:nil forState:UIControlStateNormal];
        
        // 缓存图片
        [self savePictureToCachesPath:image withScale:0.3];
        
        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
        NSString *licensePictureName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID];
        // 上传图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ELHUploadImage *uploadImage = [[ELHUploadImage alloc] init];
            [uploadImage uploadImage:image withImageName:licensePictureName withScale:0.3];
        });
    }
    
    // modal - 退出相册界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


/**
 *  保存图片到caches目录
 */
- (void)savePictureToCachesPath:(UIImage *)image withScale:(float)scale {
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
    NSString *licenseNumPicName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID]; // 营业执照照片名称
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *file = [cachesPath stringByAppendingPathComponent:licenseNumPicName];
        NSData *imageData = UIImageJPEGRepresentation(image, scale);
        [imageData writeToFile:file atomically:YES];
    });
}

/**
 *  下一步
 */
- (IBAction)toUserInfoViewController {
    if (self.companyNameTextField.text.length != 0 && self.licenseNumberTextField.text.length != 0 && self.licenseImageView.image != nil) {
        [self performSegueWithIdentifier:@"toUserInfoView" sender:nil];
    } else if (self.companyNameTextField.text.length == 0) {
        [SVProgressHUD showImage:nil status:@"\"企业名称\"为必填项"];
    } else if (self.licenseNumberTextField.text.length == 0) {
        [SVProgressHUD showImage:nil status:@"\"营业执照号\"为必填项"];
    } else if (self.licenseImageView.image == nil) {
        [SVProgressHUD showImage:nil status:@"请上传营业执照照片"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IndentificationViewController *identificationVC = segue.destinationViewController;
    // 跳过企业认证界面
    if ([segue.identifier isEqualToString:@"jumpLicenseView"]) {
        identificationVC.sectionCount = 1;
        identificationVC.trueName = self.trueName;
        identificationVC.companyName = nil;
        identificationVC.licenseNumber = nil;
    } else {
        identificationVC.sectionCount = 2;
        identificationVC.trueName = self.trueName;
        identificationVC.companyName = self.companyNameTextField.text;
        identificationVC.licenseNumber = self.licenseNumberTextField.text;
    }
}

@end
