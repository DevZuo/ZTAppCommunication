//
//  AppCommunication.m
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "ZTAppCommunication.h"

#import "UIImage+ZTCategory.h"
#import "NSBundle+ZTCategory.h"
#import "NSString+ZTCategory.h"

#define ZTAPPCOMMUNICATION [ZTAppCommunication singleton]

#define WeChatAppIDIdentifier @"AppCommunication.WeChat.AppID"
#define WeChatAppID ZTAPPCOMMUNICATION.appPlatformDict[WeChatAppIDIdentifier]
#define SetWeChatAppID(x) [ZTAPPCOMMUNICATION.appPlatformDict setObject:x forKey:WeChatAppIDIdentifier]

#define WeChatAppSecretIdentifier @"AppCommunication.WeChat.AppSecret"
#define WeChatAppSecret ZTAPPCOMMUNICATION.appPlatformDict[WeChatAppSecretIdentifier]
#define SetWeChatAppSecret(x) [ZTAPPCOMMUNICATION.appPlatformDict setObject:x forKey:WeChatAppSecretIdentifier]

#define QQAppIDIdentifier @"AppCommunication.QQ.AppID"
#define QQAppID ZTAPPCOMMUNICATION.appPlatformDict[QQAppIDIdentifier]
#define SetQQAppID(x) [ZTAPPCOMMUNICATION.appPlatformDict setObject:x forKey:QQAppIDIdentifier]

#define WeChatPasteboardType @"content"
#define QQPasteboardType @"com.tencent.mqq.api.apiLargeData"

/**
 错误码
 
 - AppCommunicationErrorCodeOpenURL: 呼起APP失败
 - AppCommunicationErrorCodeOAuth: 微信授权失败
 */
typedef NS_ENUM(NSInteger, AppCommunicationErrorCode) {
    AppCommunicationErrorCodeOpenURL = -1,
    AppCommunicationErrorCodeOAuth = -2
};

/**
 网络请求方法

 - NetworkingMethodPOST: POST
 - NetworkingMethodGET: GET
 */
typedef NS_ENUM(NSInteger, NetworkingMethod) {
    NetworkingMethodPOST,
    NetworkingMethodGET
};

@interface ZTAppCommunication ()

/// 平台信息字典
@property (readonly, strong, nonatomic) NSMutableDictionary *appPlatformDict;
/// 分享回调处理
@property (copy, nonatomic) ShareCompletionHandler shareCompletionHandler;
/// OAuth回调处理
@property (copy, nonatomic) OAuthCompletionHandler oauthCompletionHandler;
/// 支付回调处理
@property (copy, nonatomic) PayCompletionHandler payCompletionHandler;

@end

@implementation ZTAppCommunication

@synthesize appPlatformDict = _appPlatformDict;

#pragma mark - Life Cycle

+ (instancetype)singleton {
    
    static ZTAppCommunication *appCommunication;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appCommunication = [[ZTAppCommunication alloc] init];
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
+ (void)registerAppPlatform:(NSArray<ZTAppPlatform *> *)appPlatforms {
    
    for (ZTAppPlatform *appPlatform in appPlatforms) {
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
+ (void)shareMessage:(ZTAppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType completionHandler:(ShareCompletionHandler)completionHandler {
    
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
        case ShareMessageTypeQQFriend:
        case ShareMessageTypeQQZone:
        case ShareMessageTypeQQFavorites:
        {
            if ([self isAppInstalledWithAppPlatform:AppPlatformTypeQQ]) {
                urlStr = [self qqMessgaURLStrWithMessage:message forShareMessageType:shareMessageType];
                [self setupQQMessgaDataWithAppMessage:message];
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
        ZTAPPCOMMUNICATION.shareCompletionHandler = completionHandler;
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
        ZTAPPCOMMUNICATION.oauthCompletionHandler = completionHandler;
    } else {
        completionHandler(nil, nil, [NSError errorWithDomain:@"呼起微信失败" code:AppCommunicationErrorCodeOpenURL userInfo:nil]);
    }
}

/**
 支付
 
 @param platformType 信息接受者，APP平台
 @param payURLStr 支付请求
 @param completionHandler 回调处理
 */
+ (void)payWithAppPlatformType:(AppPlatformType)platformType payURLStr:(NSString *)payURLStr completionHandler:(PayCompletionHandler)completionHandler {
    
    NSString *urlStr = nil;
    switch (platformType) {
        case AppPlatformTypeWechat:
        {
            if ([self isAppInstalledWithAppPlatform:AppPlatformTypeWechat]) {
                urlStr = payURLStr;
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
        ZTAPPCOMMUNICATION.payCompletionHandler = completionHandler;
    } else {
        completionHandler(NO);
    }
}

/// 处理UIApplication的application:openURL:sourceApplication:annotation:方法
+ (BOOL)handleOpenURL:(NSURL *)url {
    
    NSString *urlScheme = url.scheme;
    if ([urlScheme hasPrefix:WeChatAppID]) {
        return [self handleWeChatOpenURL:url];
    } else if ([urlScheme hasPrefix:@"QQ"]) {
        return [self handleQQShareOpenURL:url];
    } else if ([urlScheme hasPrefix:@"tencent"]) {
        return [self handleQQOAuthOpenURL:url];
    }
    
    return NO;
}

#pragma mark - Private

/// 判断值为nil返回空字符串
+ (id)valueIsNilReturnEmptyString:(id)value {
    return value ? value : @"";
}

/// 判断值为nil返回NSNull
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

/// 调用UIApplication的openURL:方法
+ (BOOL)openURLStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    return NO;
}

/// 获取url的queryItem字典
+ (NSDictionary<NSString *, NSString *> *)queryDictionaryWithURL:(NSURL *)url {
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary<NSString *, NSString *> *dict = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        [dict setObject:queryItem.value forKey:queryItem.name];
    }
    return dict;
}

/// 压缩图片
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
+ (void)setupWeChatMessgaDataWithAppMessage:(ZTAppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType {
    
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
            [dict setObject:[self valueIsNilReturnEmptyString:message.url] forKey:@"mediaUrl"];
        }
            break;
        case AppMessageTypeAudio:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"3" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.url] forKey:@"mediaUrl"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.audioURL] forKey:@"mediaDataUrl"];
        }
            break;
        case AppMessageTypeVideo:
        {
            [dict setObject:@"1010" forKey:@"command"];
            [dict setObject:@"4" forKey:@"objectType"];
            [dict setObject:[self valueIsNilReturnEmptyString:message.videoURL] forKey:@"mediaUrl"];
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

/// 处理微信的OpenURL
+ (BOOL)handleWeChatOpenURL:(NSURL *)url {
    
    NSString *urlString = url.absoluteString;
    
    // 授权登录
    if ([urlString containsString:@"state=Weixinauth"]) {
        
        NSDictionary<NSString *, NSString *> *queryDict = [self queryDictionaryWithURL:url];
        id code = queryDict[@"code"];
        if (![code isKindOfClass:[NSString class]]) {
            return NO;
        }
        [self fetchWeChatOAuthInfoByCode:code completionHandler:^(NSDictionary * _Nullable dict, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            ZTAPPCOMMUNICATION.oauthCompletionHandler(dict, response, error);
        }];
        
        return YES;
    }
    
    // 支付
    if ([urlString containsString:@"://pay/"]) {
        
        NSDictionary<NSString *, NSString *> *queryDict = [self queryDictionaryWithURL:url];
        id ret = queryDict[@"ret"];
        if (![ret isKindOfClass:[NSString class]]) {
            return NO;
        }
        
        return ([ret isEqualToString:@"0"]);
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
    
    NSString *state = info[@"state"];
    NSInteger result = [info[@"result"] integerValue];
    BOOL success = (result == 0);
    if ([state isEqualToString:@"Weixinauth"]) {
        NSError *error = [NSError errorWithDomain:@"" code:AppCommunicationErrorCodeOAuth userInfo:nil];
        ZTAPPCOMMUNICATION.oauthCompletionHandler(nil, nil, error);
    } else {
        ZTAPPCOMMUNICATION.shareCompletionHandler(success);
    }
    
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

#pragma mark - QQ

/// 生成QQ平台的请求信息的URL
+ (NSString * _Nullable)qqMessgaURLStrWithMessage:(ZTAppMessage *)message forShareMessageType:(ShareMessageType)shareMessageType {
    
    NSInteger scene = 0x00;
    switch (shareMessageType) {
        case ShareMessageTypeQQFriend:
        {
            scene = 0x00;
        }
            break;
        case ShareMessageTypeQQZone:
        {
            scene = 0x01;
        }
            break;
        case ShareMessageTypeQQFavorites:
        {
            scene = 0x08;
        }
            break;
            
        default:
            break;
    }
    
    NSString *callBackName = [self qqCallBackName];
    NSString *bundleDisplayName = [[NSBundle zt_bundleDisplayName] zt_base64EncodedString];
    NSMutableString *urlStr = [NSMutableString stringWithString:@"mqqapi://share/to_fri?cflag=0"];
    
    [urlStr appendString:@"&callback_type=scheme&generalpastboard=1&objectlocation=pasteboard"];
    [urlStr appendFormat:@"&thirdAppDisplayName=%@", bundleDisplayName];
    [urlStr appendFormat:@"&version=1&shareType=%@", @(scene)];
    [urlStr appendFormat:@"&callback_name=%@", callBackName];
    [urlStr appendString:@"&src_type=app&shareType=0&file_type="];
    
    switch (message.messageType) {
        case AppMessageTypeText:
        {
            [urlStr appendString:@"text&file_data="];
            NSString *encodedURLContent = [[message.content zt_base64EncodedString] zt_urlEncodedString];
            if (encodedURLContent) {
                [urlStr appendFormat:@"%@", encodedURLContent];
            }
        }
            break;
        case AppMessageTypeImage:
        {
            [urlStr appendString:@"img"];
        }
            break;
        case AppMessageTypeURL:
        {
            [urlStr appendString:@"news"];
            NSString *encodedURLString = [[message.url zt_base64EncodedString] zt_urlEncodedString];
            if (encodedURLString) {
                [urlStr appendFormat:@"&url=%@", encodedURLString];
            }
        }
            break;
        case AppMessageTypeAudio:
        {
            [urlStr appendString:@"audio"];
            NSString *encodedURLString = [[message.audioURL zt_base64EncodedString] zt_urlEncodedString];
            if (encodedURLString) {
                [urlStr appendFormat:@"&url=%@", encodedURLString];
            }
        }
            break;
        case AppMessageTypeVideo:
        {
            [urlStr appendString:@"news"];
            NSString *encodedURLString = [[message.videoURL zt_base64EncodedString] zt_urlEncodedString];
            if (encodedURLString) {
                [urlStr appendFormat:@"&url=%@", encodedURLString];
            }
        }
            break;
        case AppMessageTypeFile:
        {
            [urlStr appendString:@"localFile"];
            NSString *filename = [[message.content zt_base64EncodedString] zt_urlEncodedString];
            [urlStr appendFormat:@"&fileName=%@", filename];
        }
            break;
            
        default:
        {
            return nil;
        }
            break;
    }
    
    NSString *title = [[message.content zt_base64EncodedString] zt_urlEncodedString];
    if (title) {
        [urlStr appendFormat:@"&title=%@", title];
    }
    NSString *content = [[message.content zt_base64EncodedString] zt_urlEncodedString];
    if (content) {
        [urlStr appendFormat:@"&description=%@", content];
    }
    
    return urlStr;
}

/// 设置QQ分享信息的数据
+ (void)setupQQMessgaDataWithAppMessage:(ZTAppMessage *)message {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (AppMessageTypeFile == message.messageType) {
        [dict setObject:message.fileData forKey:@"file_data"];
    } else {
        if (message.imgData) {
            [dict setObject:message.imgData forKey:@"file_data"];
        }
        if (message.thumbnailData) {
            [dict setObject:message.thumbnailData forKey:@"previewimagedata"];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:QQPasteboardType];
}

/// 处理QQ分享的OpenURL
+ (BOOL)handleQQShareOpenURL:(NSURL *)url {
    
    NSDictionary<NSString *, NSString *> *queryDict = [self queryDictionaryWithURL:url];
    id error = queryDict[@"error"];
    if ([error isKindOfClass:[NSString class]]) {
        BOOL success = [error isEqualToString:@"0"];
        ZTAPPCOMMUNICATION.shareCompletionHandler(success);
        return success;
    }
    
    return NO;
}

/// 处理QQ OAuth的OpenURL
+ (BOOL)handleQQOAuthOpenURL:(NSURL *)url {
    return NO;
}

/// 获取qqCallBackName
+ (NSString *)qqCallBackName {
    
    NSString *appIDStr = [NSString stringWithFormat:@"%02llx", [QQAppID longLongValue]];
    while (appIDStr.length < 8) {
        appIDStr = [@"0" stringByAppendingString:appIDStr];
    }
    return [@"QQ" stringByAppendingString:appIDStr];
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
