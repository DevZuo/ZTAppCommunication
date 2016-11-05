//
//  NSString+ZTCategory.h
//  YiCaXie
//
//  Created by zuoteng on 16/9/5.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZTCategory)

/// 去掉指定字符串前后两边的空格和换行
- (NSString *)zt_stringByTrimmingSpaceAndTab;

/// 将字符串转成精度比较准确的字符串，如"8.0"转成"8"、"8.80"转成"8.8"、"8.88"还是"8.88"
- (NSString *)zt_stringByAccurateNumber;

/// 经过base64编码生成新的字符串
- (NSString *)zt_base64EncodedString;

/// URL编码
- (NSString *)zt_urlEncodedString;

@end

NS_ASSUME_NONNULL_END
