//
//  AppPlatform.m
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "ZTAppPlatform.h"

@interface ZTAppPlatform ()

/// 平台类型
@property (readwrite, nonatomic) AppPlatformType platformType;
/// AppID
@property (readwrite, copy, nonatomic) NSString *appID;
/// AppSecret
@property (readwrite, copy, nonatomic) NSString *appSecret;

@end

@implementation ZTAppPlatform

/// 初始化微信平台
+ (instancetype)weChatPlatformWithAppID:(NSString *)appID appSecret:(NSString *)appSecret {
    if (!appID && !appSecret) {
        return nil;
    }
    
    ZTAppPlatform *appPlatform = [[ZTAppPlatform alloc] init];
    appPlatform.platformType = AppPlatformTypeWechat;
    appPlatform.appID = appID;
    appPlatform.appSecret = appSecret;
    return appPlatform;
}

/// 初始化QQ平台
+ (instancetype)qqPlatformTypeWithAppID:(NSString *)appID {
    if (!appID) {
        return nil;
    }
    
    ZTAppPlatform *appPlatform = [[ZTAppPlatform alloc] init];
    appPlatform.platformType = AppPlatformTypeQQ;
    appPlatform.appID = appID;
    return appPlatform;
}

@end
