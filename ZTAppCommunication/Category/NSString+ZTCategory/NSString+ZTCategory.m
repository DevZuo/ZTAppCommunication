//
//  NSString+ZTCategory.m
//  YiCaXie
//
//  Created by zuoteng on 16/9/5.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "NSString+ZTCategory.h"

@implementation NSString (ZTCategory)

/// 去掉指定字符串前后两边的空格和换行
- (NSString *)zt_stringByTrimmingSpaceAndTab {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/// 将字符串转成精度比较准确的字符串，如"8.0"转成"8"、"8.80"转成"8.8"、"8.88"还是"8.88"
- (NSString *)zt_stringByAccurateNumber {
    
    CGFloat number_float = [self floatValue];
    NSUInteger number = number_float * 100;
    NSUInteger i_1 = number / 100;
    NSUInteger i_2 = (number - i_1*100) / 10;
    NSUInteger i_3 = number - i_1*100 - i_2*10;
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@", @(i_1)];
    if (i_3 > 0) {
        [string appendFormat:@".%@%@", @(i_2), @(i_3)];
    } else if (i_2 > 0) {
        [string appendFormat:@".%@", @(i_2)];
    }
    
    return string;
}

/// 经过base64编码生成新的字符串
- (NSString *)zt_base64EncodedString {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

/// URL编码
- (NSString *)zt_urlEncodedString {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

@end
