//
//  ELHUploadImage.m
//  ELaHuo
//
//  Created by elahuo on 16/8/3.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHUploadImage.h"

@implementation ELHUploadImage

/**
 *  上传图片
 */
- (void)uploadImage:(UIImage *)image withImageName:(NSString *)imageName withScale:(float)scale {
    // ************************* 上传图片 *********************************
    ELHUploadFile *upload = [[ELHUploadFile alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@file/UploadServlet", ELHBaseURL];
    
    //    NSData *data = UIImagePNGRepresentation(image);
    NSData *data = UIImageJPEGRepresentation(image, scale); // 压缩图片
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    [imageDic setValue:data forKey:[NSString stringWithFormat:@"%@", imageName]];
    NSMutableDictionary *pramDic = [NSMutableDictionary dictionary];
    [pramDic setValue:[NSString stringWithFormat:@"%@", image] forKey:@"title"];
    
    [upload uploadFileWithURL:[NSURL URLWithString:urlString] imageDic:imageDic pramDic:pramDic];
}

@end
