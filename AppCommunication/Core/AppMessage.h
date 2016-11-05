//
//  AppMessage.h
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 消息类型

 - AppMessageTypeAuto: 自动判断
 - AppMessageTypeText: 文本
 - AppMessageTypeImage: 图片
 - AppMessageTypeURL: URL
 - AppMessageTypeAudio: 音频
 - AppMessageTypeVideo: 视频
 - AppMessageTypeFile: 文件
 */
typedef NS_ENUM(NSInteger, AppMessageType) {
    AppMessageTypeUnknown = 0,
    AppMessageTypeText,
    AppMessageTypeImage,
    AppMessageTypeURL,
    AppMessageTypeAudio,
    AppMessageTypeVideo,
    AppMessageTypeFile
};

/// APP通讯消息
@interface AppMessage : NSObject

/// 标题
@property (nullable, copy, nonatomic) NSString *title;
/// 内容
@property (nullable, copy, nonatomic) NSString *content;
/// 图片
@property (nullable, strong, nonatomic) NSData *imgData;
/// 缩略图
@property (nullable, strong, nonatomic) NSData *thumbnailData;
/// URL
@property (nullable, strong, nonatomic) NSURL *url;
/// 音频URL
@property (nullable, strong, nonatomic) NSURL *audioURL;
/// 视频URL
@property (nullable, strong, nonatomic) NSURL *videoURL;
/// 文件
@property (nullable, strong, nonatomic) NSData *fileData;
/// 消息类型
@property (nonatomic) AppMessageType messageType;

@end

NS_ASSUME_NONNULL_END
