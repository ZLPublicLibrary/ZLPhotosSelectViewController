//
//  ZLCompressionImageManager.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/5.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLCompressionImageManager.h"

@implementation ZLCompressionImageManager

/**压缩图片
 * image 将要压缩的图片
 * results 处理下文   result 压缩后的图片
 */
+ (void)compressionImage:(UIImage *)image Results:(void(^)(UIImage *result))results {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //最大质量控制   500 KB
            CGFloat maxQuality = 1024 * 500;
            
            //如果图片偏小，就不处理
            CGFloat minValue = image.size.width > image.size.height ? image.size.height : image.size.width;
            BOOL sizeIsBig = minValue > 1280 ? YES : NO;
            NSData *data = UIImageJPEGRepresentation(image, 0.5);
            BOOL qualityIsBig = data.length > maxQuality ? YES : NO;
            if (!sizeIsBig && !qualityIsBig) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    results(image);
                });
                return;
            }
            //高清大图，进行处理
            CGSize size = [self compressionSizeWithImage:image];
            @autoreleasepool {
                //缩尺寸
                UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
                UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];
                [newImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //压质量
                CGFloat compressionScale = (image.size.width * image.size.height) / (newImage.size.width * newImage.size.height);
                data = UIImageJPEGRepresentation(newImage, 1.0 / compressionScale);
            }
            //提交给外界
            dispatch_async(dispatch_get_main_queue(), ^{
                results([UIImage imageWithData:data]);
            });
        });
    };
}

/**压缩尺寸算法（该算法高仿微信）
 * image 将要压缩的图片
 */
+ (CGSize)compressionSizeWithImage:(UIImage *)image {
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat scale = image.size.height / image.size.width;
    //宽高均 <= 1280，图片尺寸大小保持不变
    if (image.size.width <= 1280 && image.size.height <= 1280) {
        width = image.size.width;
        height = image.size.height;
    }else if ((image.size.width > 1280 || image.size.height > 1280) && (image.size.width / image.size.height <= 2)) {//宽或高 > 1280 && 宽高比 <= 2，取较大值等于1280，较小值等比例压缩
        if (image.size.width > image.size.height) {
            width = 1280;
            height = width * scale;
        }else if (image.size.width < image.size.height) {
            if (image.size.height > image.size.width * 2.0) {//长图
                if (image.size.width < 1280) {
                    width = image.size.width;
                    height = image.size.height;
                }else {
                    width = 1280;
                    height = width * scale;
                }
            }else {
                height = 1280;
                width = height / scale;
            }
        }else {
            width = 1280;
            height = 1280;
        }
    }else if ((image.size.width > 1280 || image.size.height > 1280) && (image.size.width / image.size.height > 2) && (image.size.width < 1280 || image.size.height < 1280)) {//宽或高 > 1280 && 宽高比 > 2 && 宽或高 < 1280，图片尺寸大小保持不变
        width = image.size.width;
        height = image.size.height;
    }else if ((image.size.width > 1280 && image.size.height > 1280) && (image.size.width / image.size.height > 2)) {//宽高均 > 1280 && 宽高比 > 2，取较小值等于1280，较大值等比例压缩
        if (image.size.width > image.size.height) {
            height = 1280;
            width = height / scale;
        }else if (image.size.width < image.size.height) {
            width = 1280;
            height = width * scale;
        }else {
            width = 1280;
            height = 1280;
        }
    }
    return CGSizeMake(width, height);
}

@end
