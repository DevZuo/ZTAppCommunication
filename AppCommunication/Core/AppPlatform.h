//
//  AppPlatform.h
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/**
 APP通讯平台
 */
@interface AppPlatform : NSObject

/**
 平台类型
 */
@property (readonly, nonatomic) AppPlatformType platformType;
/**
 AppID
 */
@property (readonly, copy, nonatomic) NSString *appID;

/**
 初始化微信平台
 */
+ (instancetype)WeChatPlatformWithAppID:(NSString *)appID;

/**
 初始化QQ平台
 */
+ (instancetype)QQPlatformTypeWithAppID:(NSString *)appID;

@end
