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
 回调处理
 */
typedef void(^CompletionHandler)(BOOL success);

@interface AppCommunication : NSObject

/**
 注册APP平台

 @param appPlatforms APP平台
 */
+ (void)registerAppPlatform:(NSArray<AppPlatform *> *)appPlatforms;

/**
 分享到APP平台

 @param message 需要发送的信息
 @param shareMessageType 信息接受者，APP平台
 */
+ (void)shareMessage:(AppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType completionHandler:(CompletionHandler)completionHandler;

/**
 处理UIApplication的application:openURL:sourceApplication:annotation:方法
 */
+ (BOOL)handleOpenURL:(NSURL *)openURL;

@end

NS_ASSUME_NONNULL_END
