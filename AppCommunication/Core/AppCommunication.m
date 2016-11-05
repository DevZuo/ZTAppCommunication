//
//  AppCommunication.m
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "AppCommunication.h"

#import "UIImage+ZTCategory.h"

#define APPCOMMUNICATION [AppCommunication singleton]

#define WeChatAppID APPCOMMUNICATION.appPlatformDict[@"AppCommunication.WeChat.AppID"]
#define SetWeChatAppID(x) [APPCOMMUNICATION.appPlatformDict setObject:x forKey:@"AppCommunication.WeChat.AppID"]

#define WeChatAppSecret APPCOMMUNICATION.appPlatformDict[@"AppCommunication.WeChat.AppSecret"]
#define SetWeChatAppSecret(x) [APPCOMMUNICATION.appPlatformDict setObject:x forKey:@"AppCommunication.WeChat.AppSecret"]

#define QQAppID APPCOMMUNICATION.appPlatformDict[@"AppCommunication.QQ.AppID"]
#define SetQQAppID(x) [APPCOMMUNICATION.appPlatformDict setObject:x forKey:@"AppCommunication.QQ.AppID"]

#define WeChatPasteboardType @"content"

/**
 网络请求方法

 - NetworkingMethodPOST: POST
 - NetworkingMethodGET: GET
 */
typedef NS_ENUM(NSInteger, NetworkingMethod) {
    NetworkingMethodPOST,
    NetworkingMethodGET
};

@interface AppCommunication ()

/**
 平台信息字典
 */
@property (readonly, strong, nonatomic) NSMutableDictionary *appPlatformDict;
/**
 分享回调处理
 */
@property (copy, nonatomic) ShareCompletionHandler shareCompletionHandler;
/**
 OAuth回调处理
 */
@property (copy, nonatomic) OAuthCompletionHandler oauthCompletionHandler;

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
 检测APP是否安装
 
 @param platformType APP平台类型
 @return APP是否安装标识符
 */
+ (BOOL)isAppInstalledWithAppPlatform:(AppPlatformType)platformType {
    
    switch (platformType) {
        case AppPlatformTypeWechat:
        {
            return [self canOpenURLStr:@"weixin://"];
        }
            break;
        case AppPlatformTypeQQ:
        {
            return [self canOpenURLStr:@"mqqapi://"];
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
    }
}

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
                SetWeChatAppSecret(appPlatform.appSecret);
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
+ (void)shareMessage:(AppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType completionHandler:(ShareCompletionHandler)completionHandler {
    
    NSString *urlStr = nil;
    switch (shareMessageType) {
        case ShareMessageTypeWeChatFriend:
        case ShareMessageTypeWeChatTimeline:
        case ShareMessageTypeWeChatFavorite:
        {
            if ([self isAppInstalledWithAppPlatform:AppPlatformTypeWechat]) {
                urlStr = [self weChatMessgaURLStr];
                [self setupWeChatMessgaDataWithAppMessage:message forShareMessageType:shareMessageType];
            }
        }
            break;
            
        default:
        {
            return;
        }
            break;
    }
    
    if ([self openURLStr:urlStr]) {
        APPCOMMUNICATION.shareCompletionHandler = completionHandler;
    } else {
        completionHandler(NO);
    }
}

/**
 OAuth
 
 @param platformType 授权平台
 @param scope 授权内容
 @param completionHandler 回调处理
 */
+ (void)oauthWithAppPlatformType:(AppPlatformType)platformType scope:(NSString * _Nullable)scope completionHandler:(OAuthCompletionHandler)completionHandler {
    
    NSString *urlStr = nil;
    switch (platformType) {
        case AppPlatformTypeWechat:
        {
            if ([self isAppInstalledWithAppPlatform:AppPlatformTypeWechat]) {
                urlStr = [self weChatOAuthURLStrWithScope:scope];
            }
        }
            break;
            
        default:
        {
            return;
        }
            break;
    }
    
    if ([self openURLStr:urlStr]) {
        APPCOMMUNICATION.oauthCompletionHandler = completionHandler;
    } else {
        completionHandler(nil, nil, [NSError errorWithDomain:@"呼起微信失败" code:AppCommunicationErrorCodeOpenURL userInfo:nil]);
    }
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

/// 调用UIApplication的canOpenURL:方法
+ (BOOL)canOpenURLStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
    return NO;
}

/**
 调用UIApplication的openURL:方法
 */
+ (BOOL)openURLStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    return NO;
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
+ (NSData  * _Nullable)compressedImageData:(NSData *)originalData {
    
    if (!originalData) {
        return nil;
    }
    return [UIImage zt_compressedImageData:originalData maxSize:CGSizeMake(240, 240) maxDateLength:31500];
}

#pragma mark - WeChat

/// 生成微信平台的请求信息的URL
+ (NSString *)weChatMessgaURLStr {
    return [NSString stringWithFormat:@"weixin://app/%@/sendreq/?", WeChatAppID];
}

/// 生成微信OAuthURL
+ (NSString *)weChatOAuthURLStrWithScope:(NSString * _Nullable)scope {
    if (!scope) {
        scope = @"snsapi_userinfo";
    }
    return [NSString stringWithFormat:@"weixin://app/%@/auth/?scope=%@&state=Weixinauth", WeChatAppID, scope];
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
        [dict setObject:[self compressedImageData:message.thumbnailData] forKey:@"thumbData"];
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
    
    // 授权登录
    if ([urlString containsString:@"state=Weixinauth"]) {
        
        NSDictionary<NSString *, NSString *> *queryDict = [self queryDictionaryWithURL:url];
        NSString *code = queryDict[@"code"];
        [self fetchWeChatOAuthInfoByCode:code completionHandler:^(NSDictionary * _Nullable dict, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            APPCOMMUNICATION.oauthCompletionHandler(dict, response, error);
        }];
        
        return YES;
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

/// 获取微信用户信息
+ (void)fetchWeChatOAuthInfoByCode:(NSString *)code completionHandler:(NetworkingCompletionHandler)completionHandler {
    
    NSMutableString *accessTokenAPI = [NSMutableString stringWithString:@"https://api.weixin.qq.com/sns/oauth2/access_token?grant_type=authorization_code"];
    [accessTokenAPI appendFormat:@"&appid=%@", WeChatAppID];
    [accessTokenAPI appendFormat:@"&secret=%@", WeChatAppSecret];
    [accessTokenAPI appendFormat:@"&code=%@", code];
    
    [self requestWithURLString:accessTokenAPI networkingMethod:NetworkingMethodGET parameters:nil completionHandler:completionHandler];
}

#pragma mark - Networking

/**
 网络请求

 @param urlString URL
 @param networkingMethod 请求方法
 @param parameters 参数
 @param completionHandler 请求回调
 */
+ (void)requestWithURLString:(NSString *)urlString networkingMethod:(NetworkingMethod)networkingMethod parameters:(NSDictionary *)parameters completionHandler:(NetworkingCompletionHandler)completionHandler {
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (![json isKindOfClass:[NSDictionary class]]) {
            json = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(json, response, error);
        });
    }];
    [task resume];
}

@end
