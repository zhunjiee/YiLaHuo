//
//  ELHUploadImage.h
//  ELaHuo
//
//  Created by elahuo on 16/8/3.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHUploadFile.h"

@interface ELHUploadImage : ELHUploadFile

/**
 *  上传图片
 */
- (void)uploadImage:(UIImage *)image withImageName:(NSString *)imageName withScale:(float)scale;

@end
