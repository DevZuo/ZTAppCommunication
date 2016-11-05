//
//  UIImage+ZTCategory.h
//  YiCaXie
//
//  Created by zuoteng on 16/4/17.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZTCategory)

/// 等比压缩，scale表示为倍数
- (UIImage *)zt_compressedWithScale:(CGFloat)scale;

/// 等比压缩到指定大小内，inSize表示指定大小
- (UIImage *)zt_compressedInSize:(CGSize)inSize;

/**
 等比压缩图片数据

 @param maxSize 最大Size
 @param maxDateLength 最大内存
 @return 压缩后的图片
 */
- (UIImage *)zt_compressedWithMaxSize:(CGSize)maxSize maxDateLength:(NSInteger)maxDateLength;

/**
 将指定的图片数据等比压缩成新的图片数据
 
 @param imageData 原始图片数据
 @param maxSize 最大Size
 @param maxDateLength 最大内存
 @return 压缩后的图片数据
 */
+ (NSData *)zt_compressedWithImageData:(NSData *)imageData maxSize:(CGSize)maxSize maxDateLength:(NSInteger)maxDateLength;

@end
