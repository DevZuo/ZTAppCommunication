//
//  ZTAppPlatform.h
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 平台类型
 
 - AppTypeUnknown: 未知的
 - AppTypeWechat: 微信平台
 - AppTypeQQ: QQ平台
 */
typedef NS_ENUM(NSInteger, AppPlatformType) {
    AppPlatformTypeUnknown = 0,
    AppPlatformTypeWechat,
    AppPlatformTypeQQ
};

/// APP通讯平台
@interface ZTAppPlatform : NSObject

/// 平台类型
@property (readonly, nonatomic) AppPlatformType platformType;
/// AppID
@property (readonly, copy, nonatomic) NSString *appID;
/// AppSecret
@property (readonly, copy, nonatomic) NSString *appSecret;

/// 初始化微信平台
+ (instancetype)weChatPlatformWithAppID:(NSString *)appID appSecret:(NSString *)appSecret;

/// 初始化QQ平台
+ (instancetype)qqPlatformTypeWithAppID:(NSString *)appID;

@end

NS_ASSUME_NONNULL_END
