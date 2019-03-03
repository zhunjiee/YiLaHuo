//
//  ELHUploadFile.h
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHUploadFile : NSObject

- (void)uploadFileWithURL:(NSURL *)url imageDic:(NSDictionary *)imgDic pramDic:(NSDictionary *)pramDic finishBlock:(void(^)(NSDictionary *responseDict))finishBlock;

@end
