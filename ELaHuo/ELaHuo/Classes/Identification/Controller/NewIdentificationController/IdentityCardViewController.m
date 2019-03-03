//
//  IdentificationViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/6/13.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "IdentityCardViewController.h"
#import "ELHPlaceholderTextField.h"
#import "LicenseViewController.h"
#import <SVProgressHUD.h>
#import "ELHButton.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHUploadImage.h"

@interface IdentityCardViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
// 距离底部的位置约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraint;
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *trueNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *idCardImageView;
@property (weak, nonatomic) IBOutlet ELHButton *uploadIdCardPictureButton;
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end

@implementation IdentityCardViewController
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
    self.idCardImageView.layer.cornerRadius = 5;
    self.idCardImageView.layer.masksToBounds = YES;
    
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
    
    // 真实姓名
    NSString *trueName = [userDefaults stringForKey:@"GOName"];
    
    if (trueName.length != 0) {
        // 本地有数据
        self.trueNameTextField.text = trueName;
    } else {
        // 本地没有数据
        // 尝试从网络加载数据
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_getGOInfoById.action", ELHBaseURL];
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            self.trueNameTextField.text = responseObject[@"GOName"]; // 真实姓名
            [userDefaults setObject:responseObject[@"GOName"] forKey:@"GOName"];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
    }
    
    // 身份证照片
    NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID]; // 身份证照片名称
    
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *file = [cachesPath stringByAppendingPathComponent:idCardPictureName];
    
    NSData *imageData = [NSData dataWithContentsOfFile:file];
    UIImage *idCardImage = [UIImage imageWithData:imageData];
    if (idCardImage != nil) {
        // 本地有图片
        self.idCardImageView.image = idCardImage;
        // 隐藏上传按钮内容
        [self.uploadIdCardPictureButton setTitle:nil forState:UIControlStateNormal];
        [self.uploadIdCardPictureButton setImage:nil forState:UIControlStateNormal];
    } else {
        // 本地没有图片
        // 下载图片
        NSString *imageURL = [NSString stringWithFormat:@"%@file/DownLoadServlet?imageBNType=GOCardPicture&imageFileName=%@", ELHBaseURL, idCardPictureName];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *image = [UIImage imageWithData:imageData scale:1.0];
        BSLog(@"从网络获取身份证照片 :%@ ,大小为 %lu KB", image, imageData.length / 1024);
        
        if (image != nil) {
            // 本地有图片
            self.idCardImageView.image = image;
            // 隐藏上传按钮内容
            [self.uploadIdCardPictureButton setTitle:nil forState:UIControlStateNormal];
            [self.uploadIdCardPictureButton setImage:nil forState:UIControlStateNormal];
            
            // 保存图片到本地
            [self savePictureToCachesPath:image withScale:1.0];
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 存储数据
    [[NSUserDefaults standardUserDefaults] setValue:self.trueNameTextField.text forKey:@"GOName"]; // 真实姓名
}


- (void)setUpNavigationBar {
    self.navigationItem.title = @"身份认证";

    if (ScreenH >= 667 && ScreenH < 736) { // iphone6
        self.bottomLineConstraint.constant = ScreenH * 0.2;
    } else if (ScreenH >= 736) { // iphone6 plus
        self.bottomLineConstraint.constant = ScreenH * 0.18;
    }
    
    [self.view layoutIfNeeded];
}

/**
 *  上传身份证图片
 */
- (IBAction)uploadIdCardImage {
    BSLog(@"上传身份证图片");
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
        self.idCardImageView.image = image;
        
        // 隐藏上传按钮内容
        [self.uploadIdCardPictureButton setTitle:nil forState:UIControlStateNormal];
        [self.uploadIdCardPictureButton setImage:nil forState:UIControlStateNormal];
        
        // 缓存照片
        [self savePictureToCachesPath:image withScale:0.3];
        
        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
        NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID];
        // 上传图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ELHUploadImage *uploadImage = [[ELHUploadImage alloc] init];
            [uploadImage uploadImage:image withImageName:idCardPictureName withScale:0.3];
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
    NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID]; // 身份证照片名称
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *file = [cachesPath stringByAppendingPathComponent:idCardPictureName];
        NSData *imageData = UIImageJPEGRepresentation(image, scale);
        [imageData writeToFile:file atomically:YES];
    });
}


/**
 *  下一步:跳转到企业真正界面
 */
- (IBAction)toLicenseViewController {
    if (self.trueNameTextField.text.length != 0 && self.idCardImageView.image != nil) {
        [self performSegueWithIdentifier:@"toLicenseView" sender:nil];
    } else if (self.trueNameTextField.text.length == 0) {
        [SVProgressHUD showImage:nil status:@"\"真实姓名\"是必填项"];
        return;
    } else if (self.idCardImageView.image == nil) {
        [SVProgressHUD showImage:nil status:@"请上传身份证照片"];
        return;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toLicenseView"]) {
        LicenseViewController *licenseVC = segue.destinationViewController;
        licenseVC.trueName = self.trueNameTextField.text;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
