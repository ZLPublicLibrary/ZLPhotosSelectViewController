//
//  ZLPhotosSelectUnitModel.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectUnitModel.h"
#import "ZLPhotosSelectConfig.h"
#import "UIImage+ZLGIF.h"

@implementation ZLPhotosSelectUnitModel

/**根据图片asset获取照片
 * original 原图
 * results 处理下文   result照片
*/
- (void)getPhotosWithOriginal:(BOOL)original Results:(void(^)(UIImage * _Nullable result))results {
    __weak typeof(self)weakSelf = self;
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            /**指定最大缩略图获取的单倍像素标线
             * 该值非绝对值，但得到的单倍像素点一定会比该值小
             * 比如：在6s手机上，该设备是2倍屏，所得到的图片尺寸会比maxPoint * 2小。
             */
            
            CGFloat maxPoint = ZLPhotosSelectConfig.shared.thumbnailMaxPoint;//缩略图有效
            
            //配置参数
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            CGSize targetSize = CGSizeZero;
            if (!original) {
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                CGFloat scale = 1.0;
                CGFloat maxPointScale = maxPoint * UIScreen.mainScreen.scale;
                CGFloat number = maxPointScale + 1;
                while (number > maxPointScale) {
                    scale = scale + 0.01;
                    number = weakSelf.asset.pixelWidth / scale;
                }
                targetSize = CGSizeMake(weakSelf.asset.pixelWidth / scale, weakSelf.asset.pixelHeight / scale);
            }else {
                options.resizeMode = PHImageRequestOptionsResizeModeNone;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            }
            options.networkAccessAllowed = YES;
            options.synchronous = YES;
            
            //提取照片
            [[PHImageManager defaultManager] requestImageForAsset:weakSelf.asset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (results) {
                        results(result);
                    }
                });
            }];
        });
    }
}

/**根据图片asset获取gif数据
 * original 原图
 * results 处理下文   result gif数据
*/
- (void)getGifPhotosWithOriginal:(BOOL)original Results:(void(^)(NSData * _Nullable result))results {
    __weak typeof(self)weakSelf = self;
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //配置参数
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            if (!original) {
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            }else {
                options.resizeMode = PHImageRequestOptionsResizeModeNone;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            }
            options.networkAccessAllowed = YES;
            options.synchronous = YES;
            //提取照片
            [[PHImageManager defaultManager] requestImageDataForAsset:weakSelf.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSData *data = nil;
                if (!original) {
                    //缩略图处理
                    CGSize imageSize = CGSizeZero;
                    @autoreleasepool {
                        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
                        imageSize = [UIImage imageWithCGImage:image].size;
                        CGImageRelease(image);
                    };
                    CGFloat maxPoint = ZLPhotosSelectConfig.shared.thumbnailMaxPoint;
                    CGFloat maxPointScale = maxPoint * UIScreen.mainScreen.scale;
                    CGFloat scale = imageSize.height / imageSize.width;
                    CGSize size = CGSizeMake(maxPointScale, maxPointScale * scale);
                    data = [UIImage scallGIFWithData:imageData scallSize:size];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (results) {
                            results(data);
                        }
                    });
                }else {
                    //最大质量控制   500 KB
                    CGFloat maxQuality = 1024 * 500;
                    if (imageData.length < maxQuality) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (results) {
                                results(imageData);
                            }
                        });
                        return;
                    }
                    //压缩图处理
                    CGSize imageSize = CGSizeZero;
                    @autoreleasepool {
                        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
                        imageSize = [UIImage imageWithCGImage:image].size;
                        CGImageRelease(image);
                    };
                    CGFloat maxPoint = ZLPhotosSelectConfig.shared.thumbnailMaxPoint;
                    CGFloat maxPointScale = maxPoint * UIScreen.mainScreen.scale;
                    CGFloat scale = imageSize.height / imageSize.width;
                    CGSize size = CGSizeMake(maxPointScale, maxPointScale * scale);
                    data = [UIImage scallGIFWithData:imageData scallSize:size];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (results) {
                            results(data);
                        }
                    });
                }
            }];
        });
    }
}

@end
