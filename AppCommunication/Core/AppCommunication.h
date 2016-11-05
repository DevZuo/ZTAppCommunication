//
//  AppCommunication.h
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AppPlatform.h"
#import "AppMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 分享类型

 - ShareMessageTypeUnknown: 未知的
 - ShareMessageTypeWeChatFriend: 微信好友
 - ShareMessageTypeWeChatTimeline: 微信朋友圈
 - ShareMessageTypeWeChatFavorite: 微信收藏
 - ShareMessageTypeQQFriend: QQ好友
 - ShareMessageTypeQQZone: QQ空间
 - ShareMessageTypeQQFavorites: QQ收藏
 */
typedef NS_ENUM(NSInteger, ShareMessageType) {
    ShareMessageTypeUnknown = 0,
    
    ShareMessageTypeWeChatFriend,
    ShareMessageTypeWeChatTimeline,
    ShareMessageTypeWeChatFavorite,
    
    ShareMessageTypeQQFriend,
    ShareMessageTypeQQZone,
    ShareMessageTypeQQFavorites
};

/**
 错误码

 - AppCommunicationErrorCodeOpenURL: 呼起APP失败
 */
typedef NS_ENUM(NSInteger, AppCommunicationErrorCode) {
    AppCommunicationErrorCodeOpenURL = -1,
};

/// 网络请求回调处理
typedef void(^NetworkingCompletionHandler)(NSDictionary * _Nullable dict, NSURLResponse * _Nullable response, NSError * _Nullable error);
/// 分享回调处理
typedef void(^ShareCompletionHandler)(BOOL success);
/// 支付回调处理
typedef void(^PayCompletionHandler)(BOOL success);
/// OAuth回调处理
#define OAuthCompletionHandler NetworkingCompletionHandler

@interface AppCommunication : NSObject

/**
 检测APP是否安装

 @param platformType APP平台类型
 @return APP是否安装标识符
 */
+ (BOOL)isAppInstalledWithAppPlatform:(AppPlatformType)platformType;

/**
 注册APP平台

 @param appPlatforms APP平台
 */
+ (void)registerAppPlatform:(NSArray<AppPlatform *> *)appPlatforms;

/**
 分享到APP平台

 @param message 需要发送的信息
 @param shareMessageType 信息接受者，APP平台
 @param completionHandler 回调处理
 */
+ (void)shareMessage:(AppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType completionHandler:(ShareCompletionHandler)completionHandler;

/**
 OAuth

 @param platformType 授权平台
 @param scope 授权内容
 @param completionHandler 回调处理
 */
+ (void)oauthWithAppPlatformType:(AppPlatformType)platformType scope:(NSString * _Nullable)scope completionHandler:(OAuthCompletionHandler)completionHandler;

/**
 支付

 @param platformType 信息接受者，APP平台
 @param payURLStr 支付请求
 @param completionHandler 回调处理
 */
+ (void)payWithAppPlatformType:(AppPlatformType)platformType payURLStr:(NSString *)payURLStr completionHandler:(PayCompletionHandler)completionHandler;

/// 处理UIApplication的application:openURL:sourceApplication:annotation:方法
+ (BOOL)handleOpenURL:(NSURL *)openURL;

@end

NS_ASSUME_NONNULL_END
