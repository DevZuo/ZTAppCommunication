//
//  UIImage+ZTCategory.m
//  YiCaXie
//
//  Created by zuoteng on 16/4/17.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "UIImage+ZTCategory.h"

@implementation UIImage (ZTCategory)

/**
 按照压缩倍数等比压缩
 
 @param scale 压缩倍数
 @return 等比压缩后生成的新图片
 */
- (UIImage *)zt_compressedWithScale:(CGFloat)scale {
    
    CGSize scaleSize = CGSizeMake(floorf(self.size.width*scale), floorf(self.size.height*scale));
    UIGraphicsBeginImageContext(scaleSize);
    [self drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *scaleImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaleImg;
}

/**
 等比压缩到指定大小内
 
 @param inSize 指定大小
 @return 等比压缩后生成的新图片
 */
- (UIImage *)zt_compressedInSize:(CGSize)inSize {
    CGFloat scale = MIN(inSize.width/self.size.width, inSize.height/self.size.height);
    return [self zt_compressedWithScale:scale];
}

/**
 等比压缩图片数据
 
 @param maxSize 最大Size
 @param maxDateLength 最大内存
 @return 压缩后的图片
 */
- (UIImage *)zt_compressedWithMaxSize:(CGSize)maxSize maxDateLength:(NSInteger)maxDateLength {
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    if (!imageData) {
        return nil;
    }
    NSData *compressedImageData = [UIImage zt_compressedImageData:imageData maxSize:maxSize maxDateLength:maxDateLength];
    
    return [UIImage imageWithData:compressedImageData];
}

/**
 将指定的图片数据等比压缩成新的图片数据
 
 @param imageData 原始图片数据
 @param maxSize 最大Size
 @param maxDateLength 最大内存
 @return 压缩后的图片数据
 */
+ (NSData *)zt_compressedImageData:(NSData *)imageData maxSize:(CGSize)maxSize maxDateLength:(NSInteger)maxDateLength {
    
    if (!imageData) {
        return nil;
    }
    
    CGFloat compressionQuality = 0.7;
    CGFloat minCompressionQuality = 0.01;
    NSData *compressedImageData = nil;
    
    if(imageData.length <= maxDateLength) {
        
        UIImage *image = [UIImage imageWithData:imageData];
        if (!image) {
            return nil;
        }
        UIImage *compressedImage = [image zt_compressedInSize:maxSize];
        return UIImageJPEGRepresentation(compressedImage, 1);
    }
    
    while (compressionQuality > minCompressionQuality) {
        
        compressionQuality -= 0.1;
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:imageData];
            if (!image) {
                break;
            }
            UIImage *compressedImage = [image zt_compressedInSize:maxSize];
            compressedImageData = UIImageJPEGRepresentation(compressedImage, compressionQuality);
        }
    }
    
    return compressedImageData;
}

@end
