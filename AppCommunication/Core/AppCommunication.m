//
//  AppCommunication.m
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "AppCommunication.h"

#define APPCOMMUNICATION [AppCommunication singleton]

#define WeChatAppID APPCOMMUNICATION.appPlatformDict[@"AppCommunication.WeChat.AppID"]
#define SetWeChatAppID(x) [APPCOMMUNICATION.appPlatformDict setObject:x forKey:@"AppCommunication.WeChat.AppID"]

#define QQAppID APPCOMMUNICATION.appPlatformDict[@"AppCommunication.QQ.AppID"]
#define SetQQAppID(x) [APPCOMMUNICATION.appPlatformDict setObject:x forKey:@"AppCommunication.QQ.AppID"]

#define WeChatPasteboardType @"content"

@interface AppCommunication ()

/**
 平台信息字典
 */
@property (readonly, strong, nonatomic) NSMutableDictionary *appPlatformDict;
/**
 分享回调处理
 */
@property (copy, nonatomic) CompletionHandler shareCompletionHandler;

@end

@implementation AppCommunication

@synthesize appPlatformDict = _appPlatformDict;

#pragma mark - Life Cycle

+ (instancetype)singleton {
    
    static AppCommunication *appCommunication;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appCommunication = [[AppCommunication alloc] init];
    });
    
    return appCommunication;
}

#pragma mark - Getter And Setter

- (NSMutableDictionary *)appPlatformDict {
    
    if (!_appPlatformDict) {
        _appPlatformDict = [NSMutableDictionary dictionary];
    }
    return _appPlatformDict;
}

#pragma mark - Public

/**
 注册APP平台
 
 @param appPlatforms APP平台
 */
+ (void)registerAppPlatform:(NSArray<AppPlatform *> *)appPlatforms {
    
    for (AppPlatform *appPlatform in appPlatforms) {
        switch (appPlatform.platformType) {
            case AppPlatformTypeWechat:
            {
                SetWeChatAppID(appPlatform.appID);
            }
                break;
            case AppPlatformTypeQQ:
            {
                SetQQAppID(appPlatform.appID);
            }
                break;
                
            default:
                break;
        }
    }
}

/**
 分享到APP平台
 
 @param message 需要发送的信息
 @param shareMessageType 信息接受者，APP平台
 */
+ (void)shareMessage:(AppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType completionHandler:(CompletionHandler)completionHandler {
    
    NSURL *url = nil;
    switch (shareMessageType) {
        case ShareMessageTypeWeChatFriend:
        case ShareMessageTypeWeChatTimeline:
        case ShareMessageTypeWeChatFavorite:
        {
            url = [self WeChatMessgaURL];
            [self setupWeChatMessgaDataWithAppMessage:message forShareMessageType:shareMessageType];
        }
            break;
            
        default:
        {
            return;
        }
            break;
    }
    
    APPCOMMUNICATION.shareCompletionHandler = completionHandler;
    [self openURL:url];
}

/**
 处理UIApplication的application:openURL:sourceApplication:annotation:方法
 */
+ (BOOL)handleOpenURL:(NSURL *)url {
    if ([url.scheme hasPrefix:WeChatAppID]) {
        return [self handleWeChatOpenURL:url];
    }
    
    return NO;
}

#pragma mark - Private

/**
 判断值为nil返回空字符串
 */
+ (id)valueIsNilReturnEmptyString:(id)value {
    return value ? value : @"";
}

/**
 判断值为nil返回NSNull
 */
+ (id)valueIsNilReturnNSNull:(id)value {
    return value ? value : [NSNull null];
}

/**
 调用UIApplication的openURL:方法
 */
+ (void)openURL:(NSURL *)url {
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 获取url的queryItem字典
 */
+ (NSDictionary<NSString *, NSString *> *)queryDictionaryWithURL:(NSURL *)url {
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary<NSString *, NSString *> *dict = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        [dict setObject:queryItem.value forKey:queryItem.name];
    }
    return dict;
}

/**
 压缩图片
 */
+ (NSData *)compressedImageData:(NSData *)originalData {
    
}

#pragma mark - WeChat

/**
 生成微信平台的请求信息的URL
 */
+ (NSURL *)WeChatMessgaURL {
    
    NSMutableString *urlStr = [NSMutableString string];
    [urlStr appendFormat:@"weixin://app/%@/sendreq/?", WeChatAppID];
    return [NSURL URLWithString:urlStr];
}

/**
 设置微信分享信息的数据
 
 @param shareMessageType 微信分享类型
 */
+ (void)setupWeChatMessgaDataWithAppMessage:(AppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType {
    
    if (AppMessageTypeFile == message.messageType) {
        NSAssert(NO, @"微信不支持文件分享");
        return;
    }
    
    NSString *scene = nil;
    switch (shareMessageType) {
        case ShareMessageTypeWeChatFriend:
        {
            scene = @"0";
        }
            break;
        case ShareMessageTypeWeChatTimeline:
        {
            scene = @"1";
        }
            break;
        case ShareMessageTypeWeChatFavorite:
        {
            scene = @"2";
        }
            break;
            
        default:
        {
            return;
        }
            break;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"1" forKey:@"result"];
    [dict setObject:@"0" forKey:@"returnFromApp"];
    [dict setObject:@"1.7.3" forKey:@"sdkver"];
    [dict setObject:scene forKey:@"scene"];
    
    if (message.title) {
        [dict setObject:[self valueIsNilReturnEmptyString:message.title] forKey:@"title"];
    }
    if (message.content) {
        [dict setObject:[self valueIsNilReturnEmptyString:message.content] forKey:@"description"];
    }
    if (message.thumbnailData) {
        [dict setObject:[self valueIsNilReturnNSNull:message.thumbnailData] forKey:@"thumbData"];
    }
    
    switch (message.messageType) {
        case AppMessageTypeText:
        {
            [dict setObject:@"1020" forKey:@"command"];
        }
            break;
        case AppMessageTypeImage:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"2" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnNSNull:message.imgData] forKey:@"fileData"];
        }
            break;
        case AppMessageTypeURL:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"5" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.url.absoluteString] forKey:@"mediaUrl"];
        }
            break;
        case AppMessageTypeAudio:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"3" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.url.absoluteString] forKey:@"mediaUrl"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.audioURL.absoluteString] forKey:@"mediaDataUrl"];
        }
            break;
        case AppMessageTypeVideo:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"4" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.videoURL.absoluteString] forKey:@"mediaUrl"];
        }
            break;
            
        default:
            break;
    }
    
    NSDictionary *infoDict = @{WeChatAppID:dict};
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:infoDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (error) {
        return;
    }
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:WeChatPasteboardType];
}

/**
 处理微信的OpenURL
 */
+ (BOOL)handleWeChatOpenURL:(NSURL *)url {
    
    NSString *urlString = url.absoluteString;
//    NSDictionary<NSString *, NSString *> *queryDict = [self queryDictionaryWithURL:url];
    
    // 授权登录
    if ([urlString containsString:@"state=Weixinauth"]) {
        return NO;
    }
    
    if ([urlString containsString:@"wapoauth"]) {
        return NO;
    }
    
    // 支付
    if ([urlString containsString:@"://pay/"]) {
        return NO;
    }
    
    // 分享
    
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:WeChatPasteboardType];
    if (!data) {
        return NO;
    }
    
    NSError *error = nil;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
    if (error || !dict) {
        return NO;
    }
    
    NSDictionary *info = dict[WeChatAppID];
    if (!info) {
        return NO;
    }
    
    NSInteger result = [info[@"result"] integerValue];
    BOOL success = (result == 0);
    APPCOMMUNICATION.shareCompletionHandler(success);
    
    return NO;
}

@end
