//
//  NSBundle+ZTCategory.m
//  Demo
//
//  Created by zuoteng on 2016/11/5.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "NSBundle+ZTCategory.h"

@implementation NSBundle (ZTCategory)

/// 获取应用的BundleDisplayName，不存在的话取BundleName
+ (NSString *)zt_bundleDisplayName {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *localizedInfoDict = [[NSBundle mainBundle] localizedInfoDictionary];
    if (localizedInfoDict && localizedInfoDict.allKeys.count>0) {
        infoDict = localizedInfoDict;
    }
    
    NSString *displayName = infoDict[@"CFBundleDisplayName"];
    if (!displayName) {
        displayName = infoDict[@"CFBundleName"];
    }
    
    return displayName;
}

@end
