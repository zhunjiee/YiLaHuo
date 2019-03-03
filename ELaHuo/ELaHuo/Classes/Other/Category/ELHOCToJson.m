//
//  ELHOCToJson.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHOCToJson.h"

@implementation ELHOCToJson

+ (NSDictionary *)ocToJson:(NSDictionary *)dict {
    // OC 转 json
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{
                             @"jo" : aString
                             };
    return params;
}
@end
