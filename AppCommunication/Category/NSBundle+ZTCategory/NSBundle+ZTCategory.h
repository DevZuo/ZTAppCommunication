//
//  NSBundle+ZTCategory.h
//  Demo
//
//  Created by zuoteng on 2016/11/5.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (ZTCategory)

/// 获取应用的BundleDisplayName，不存在的话取BundleName
+ (NSString *)zt_bundleDisplayName;

@end
