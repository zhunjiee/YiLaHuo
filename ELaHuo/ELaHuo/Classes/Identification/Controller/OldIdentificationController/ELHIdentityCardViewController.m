//
//  ELHIdentityCardViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/11.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHIdentityCardViewController.h"
#import <Masonry.h>

@interface ELHIdentityCardViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/** 是否是第一次进入界面 */
@property (nonatomic, assign) BOOL firstLoad;

@end

@implementation ELHIdentityCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstLoad = YES;
    
    [self setUpGestureRecognizer];

    [self setUpChildControlHidden];
    
    // 修改"点击拍照"按钮的位置
    ELHWeakSelf;
    [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.idCardImageView);
        make.size.mas_equalTo(CGSizeMake(100, 35));
    }];
}

/**
 *  添加手势选择图片
 */
- (void)setUpGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePictureFromCamera:)];
    self.idCardImageView.userInteractionEnabled = YES;
    [self.idCardImageView addGestureRecognizer:tap];
}



#pragma mark - UITableView相关
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}


#pragma mark - 图片选择
/**
 *  点击拍照
 */
- (IBAction)takePhotoButtonClick {
    [self choosePictureFromCamera:nil];
}


/**
 *  调用照相机拍照
 */
- (void)choosePictureFromCamera:(UITapGestureRecognizer *)tap {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
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
        self.idCardPlaceholderImageView.image = nil;
        
        // 存储图片到caches目录
        [self savePictureToCachesPath:image withScale:0.3];
    }
 
    
    // modal - 退出相册界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 隐藏选择图片占位文字
    [self setUpChildControlHidden];
    
    
    self.firstLoad = NO;
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
 *  设置子控件显示还是隐藏
 */
- (void)setUpChildControlHidden {
    if (self.idCardImageView.image != nil) {
        self.takePhotoButton.hidden = YES;
    } else {
        self.takePhotoButton.hidden = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
}




@end